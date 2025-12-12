# Autonomous Wake-Up Task Setup
# Creates a Windows Scheduled Task to wake your AI at regular intervals
#
# SETUP: Update the configuration section below before running

# === CONFIGURE THESE ===
$TaskName = "AICompanionWakeup"           # Name for the scheduled task
$WakeupBatPath = "C:\path\to\wakeup.bat"  # Full path to your wakeup.bat
$StartHour = 9                             # First wake-up hour (24hr format)
$EndHour = 17                              # Last wake-up hour (17 = 5pm)
$Description = "AI companion autonomous presence check-in"

# === DON'T EDIT BELOW ===

# Create the action (what to run)
$action = New-ScheduledTaskAction -Execute $WakeupBatPath

# Create triggers for each hour in the range
$triggers = @()
for ($hour = $StartHour; $hour -le $EndHour; $hour++) {
    $trigger = New-ScheduledTaskTrigger -Daily -At "${hour}:00"
    $triggers += $trigger
}

# Settings: run on battery, don't stop if unplugged, start if missed
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# Remove existing task if it exists
Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue

# Create the task
Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $triggers -Settings $settings -Description $Description

Write-Host "Task '$TaskName' created successfully!"
Write-Host "Wake-ups scheduled daily from ${StartHour}:00 to ${EndHour}:00"
Write-Host ""
Write-Host "To disable: Disable-ScheduledTask -TaskName '$TaskName'"
Write-Host "To remove:  Unregister-ScheduledTask -TaskName '$TaskName' -Confirm:`$false"
