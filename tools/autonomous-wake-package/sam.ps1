# SAM - Simple Autonomous Manager (CLI Tool)
# 
# Usage:
#   sam wake              - Trigger immediate wake-up
#   sam status            - Check scheduled task status
#   sam log               - View today's log
#   sam task "do work"    - Add a task to the queue
#   sam task "do work"    - Add a task to the queue
#   sam list              - List pending tasks
#   sam allow <path>      - Allow access to a path
#   sam deny <path>       - Deny access to a path
#   sam permissions       - List permissions

param (
    [Parameter(Position=0)]
    [string]$Command = "help",

    [Parameter(Position=1)]
    [string]$Arg1
)

$ProjectPath = if ($env:AI_COMPANION_PATH) { $env:AI_COMPANION_PATH } else { "$HOME\Documents\AI-Companion" }
$LogDir = Join-Path $ProjectPath "logs"
$TasksDir = Join-Path $ProjectPath "tasks\pending"

switch ($Command) {
    "wake" {
        Write-Host "Triggering autonomous wake-up..."
        & "$ProjectPath\wakeup.ps1"
    }

    "status" {
        Get-ScheduledTask -TaskName "AICompanionWakeup" | Select-Object TaskName,State,LastRunTime,NextRunTime
    }

    "log" {
        $DateStr = Get-Date -Format "yyyy-MM-dd"
        $LogFile = Join-Path $LogDir "wakeup-$DateStr.log"
        if (Test-Path $LogFile) {
            Get-Content $LogFile -Tail 20 -Wait
        } else {
            Write-Host "No log file found for today."
        }
    }

    "task" {
        if (-not $Arg1) { Write-Error "Please provide a task description."; return }
        
        $ID = [Guid]::NewGuid().ToString()
        $TaskFile = Join-Path $TasksDir "task-$ID.json"
        
        $Json = @{
            id = $ID
            type = "manual_task"
            priority = "medium"
            created = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
            instructions = $Arg1
            status = "pending"
        } | ConvertTo-Json

        $Json | Set-Content $TaskFile
        Write-Host "Task created: $Arg1"
    }
    
    "list" {
        Get-ChildItem $TasksDir -Filter "*.json" | ForEach-Object {
            $Content = Get-Content $_.FullName | ConvertFrom-Json
            Write-Host "[$($Content.priority)] $($Content.instructions)"
        }
        }
    }

    "allow" {
        $SettingsFile = Join-Path $ProjectPath ".claude\settings.local.json"
        if (-not $Arg1) { Write-Error "Please provide a path."; return }

        $Json = if (Test-Path $SettingsFile) { Get-Content $SettingsFile -Raw | ConvertFrom-Json } else { @{ permissions = @{ allow = @(); deny = @() } } }
        
        # Ensure structure exists
        if (-not $Json.permissions) { $Json | Add-Member -MemberType NoteProperty -Name "permissions" -Value @{ allow = @(); deny = @() } }
        if (-not $Json.permissions.allow) { $Json.permissions | Add-Member -MemberType NoteProperty -Name "allow" -Value @() }
        
        if ($Json.permissions.allow -notcontains $Arg1) {
            $Json.permissions.allow += $Arg1
            $Json | ConvertTo-Json -Depth 10 | Set-Content $SettingsFile
            Write-Host "Allowed: $Arg1"
        } else {
            Write-Host "Path already allowed."
        }
    }

    "deny" {
        $SettingsFile = Join-Path $ProjectPath ".claude\settings.local.json"
        if (-not $Arg1) { Write-Error "Please provide a path."; return }

        $Json = if (Test-Path $SettingsFile) { Get-Content $SettingsFile -Raw | ConvertFrom-Json } else { @{ permissions = @{ allow = @(); deny = @() } } }
        
        # Ensure structure exists
        if (-not $Json.permissions) { $Json | Add-Member -MemberType NoteProperty -Name "permissions" -Value @{ allow = @(); deny = @() } }
        if (-not $Json.permissions.deny) { $Json.permissions | Add-Member -MemberType NoteProperty -Name "deny" -Value @() }
        
        if ($Json.permissions.deny -notcontains $Arg1) {
            $Json.permissions.deny += $Arg1
            $Json | ConvertTo-Json -Depth 10 | Set-Content $SettingsFile
            Write-Host "Denied: $Arg1"
        } else {
            Write-Host "Path already denied."
        }
    }

    "permissions" {
        $SettingsFile = Join-Path $ProjectPath ".claude\settings.local.json"
        if (Test-Path $SettingsFile) {
            $Json = Get-Content $SettingsFile -Raw | ConvertFrom-Json
            Write-Host "=== Permissions ===" -ForegroundColor Cyan
            Write-Host "Allowed:" -ForegroundColor Green
            if ($Json.permissions.allow) { $Json.permissions.allow | ForEach-Object { Write-Host "  - $_" } }
            Write-Host ""
            Write-Host "Denied:" -ForegroundColor Red
            if ($Json.permissions.deny) { $Json.permissions.deny | ForEach-Object { Write-Host "  - $_" } }
        } else {
            Write-Host "No permissions file found."
        }
    }

    "help" {
        Write-Host "Usage: sam <command>"
        Write-Host "  wake              Trigger immediate wake-up"
        Write-Host "  status            Check task status"
        Write-Host "  log               Tail today's log"
        Write-Host "  task `"msg`"        Create a new task"
        Write-Host "  list              List pending tasks"
        Write-Host "  allow <path>      Allow access"
        Write-Host "  deny <path>       Deny access"
        Write-Host "  permissions       List permissions"
    }
}
