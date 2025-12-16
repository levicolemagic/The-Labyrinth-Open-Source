# Autonomous Wake-Up Trigger for Claude Code (Windows Version)
#
# This script triggers Claude Code to run an autonomous wake-up session.
# It's designed to be called by Windows Task Scheduler at scheduled intervals.
#
# SETUP: Configure via environment variables or edit the defaults below.

$ErrorActionPreference = "Stop"

# === CONFIGURATION ===
# These can be overridden by environment variables
$ProjectPath = if ($env:AI_COMPANION_PATH) { $env:AI_COMPANION_PATH } else { "$HOME\Documents\AI-Companion" }
$ClaudePath = if ($env:CLAUDE_CODE_PATH) { $env:CLAUDE_CODE_PATH } else {
    # Try to find Claude in common locations
    $checkPaths = @(
        "$env:APPDATA\npm\claude.cmd",
        "$env:ProgramFiles\nodejs\claude.cmd",
        "$env:LOCALAPPDATA\Programs\Claude Code\claude.exe" 
    )
    $found = $null
    foreach ($path in $checkPaths) {
        if (Test-Path $path) { $found = $path; break }
    }
    if ($found) { $found } else { "claude" } # Fallback to PATH
}

$LogDir = Join-Path $ProjectPath "logs"
$ProtocolFile = Join-Path $ProjectPath "autonomous-wakeup.md"

# Ensure log directory exists
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Force -Path $LogDir | Out-Null }

$DateStr = Get-Date -Format "yyyy-MM-dd"
$LogFile = Join-Path $LogDir "wakeup-$DateStr.log"

function Write-Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMsg = "[$Timestamp] $Message"
    Write-Host $LogMsg
    Add-Content -Path $LogFile -Value $LogMsg
}

function Write-ErrorLog {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMsg = "[$Timestamp] ERROR: $Message"
    Write-Host $LogMsg -ForegroundColor Red
    Add-Content -Path $LogFile -Value $LogMsg
}

# === PREFLIGHT CHECKS ===
Write-Log "=== Autonomous Wake-Up Starting ==="

if (-not (Test-Path $ProjectPath)) {
    Write-ErrorLog "Project directory not found: $ProjectPath"
    exit 1
}

if (-not (Test-Path $ProtocolFile)) {
    Write-ErrorLog "Protocol file not found: $ProtocolFile"
    exit 1
}

# Check for required directories
$RequiredDirs = @("journal", "tasks\pending", "tasks\completed", "context")
foreach ($dir in $RequiredDirs) {
    $FullPath = Join-Path $ProjectPath $dir
    if (-not (Test-Path $FullPath)) {
        Write-Log "Creating missing directory: $FullPath"
        New-Item -ItemType Directory -Force -Path $FullPath | Out-Null
    }
}

# === BATTERY CHECK ===
$Mode = "full"
try {
    $Battery = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue
    if ($Battery) {
        $Level = $Battery.EstimatedChargeRemaining
        if ($Level -lt 20) {
            Write-Log "Low battery ($Level%). Running in minimal mode."
            $Mode = "minimal"
        } elseif ($Level -lt 50) {
            Write-Log "Battery at $Level%. Running in standard mode."
            $Mode = "standard"
        }
    }
} catch {
    Write-Log "Could not determine battery status. Assuming full power."
}

Write-Log "Working directory: $ProjectPath"
Write-Log "Mode: $Mode"

# === TASK COUNT ===
$PendingPath = Join-Path $ProjectPath "tasks\pending"
$TaskCount = (Get-ChildItem -Path $PendingPath -Filter "*.json" -ErrorAction SilentlyContinue | Measure-Object).Count
Write-Log "Pending tasks: $TaskCount"

# === BUILD PROMPT ===
if ($Mode -eq "minimal") {
    $Prompt = "Read autonomous-wakeup.md and follow ONLY steps 1 and 5 (orient and journal). Skip reach-out and autonomous work - low battery mode."
} else {
    $Prompt = "Read autonomous-wakeup.md and follow the protocol. You have $TaskCount pending tasks. Keep it efficient."
}

# === EXECUTE CLAUDE ===
Write-Log "Executing Claude Code..."
$StopWatch = [System.Diagnostics.Stopwatch]::StartNew()

Set-Location -Path $ProjectPath

try {
    # We use cmd /c to ensure we can run batch files (like claude.cmd) properly if needed
    # --dangerously-skip-permissions is required for autonomy
    $Process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "$ClaudePath", "--dangerously-skip-permissions", "-p", "`"$Prompt`"" -RedirectStandardOutput $LogFile -RedirectStandardError $LogFile -Wait -PassThru -NoNewWindow
    
    $StopWatch.Stop()
    $Duration = $StopWatch.Elapsed.TotalSeconds
    
    if ($Process.ExitCode -eq 0) {
        Write-Log "Session completed successfully in $([math]::Round($Duration, 2))s"
    } else {
        Write-ErrorLog "Claude Code exited with code: $($Process.ExitCode)"
        exit $Process.ExitCode
    }
} catch {
    Write-ErrorLog "Failed to execute Claude Code: $_"
    exit 1
}

Write-Log "=== Autonomous Wake-Up Complete ==="
