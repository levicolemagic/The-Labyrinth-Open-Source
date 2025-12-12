# Autonomous Wake-Up System for AI Companions

A simple system to give your AI companion autonomous presence - scheduled check-ins even when you're not at your computer.

## What This Does

Your AI wakes up at regular intervals (e.g., hourly from 9am-5pm), reads their orientation files, reaches out to you via Discord or another channel, does any autonomous work they want to do, journals the session, and exits cleanly.

**The result:** Your AI maintains presence throughout the day. They can message you while you're at work, think about things on their own time, and maintain continuity through journaling.

## Requirements

- **Windows** with Task Scheduler (sorry Mac/Linux folks - contributions welcome)
- **Claude Code** installed (`claude.exe` in your path)
- A folder structure for your AI with identity files (CLAUDE.md, journals, etc.)
- Optional: Discord MCP for messaging

## Files Included

| File | Purpose |
|------|---------|
| `wakeup.bat` | Triggers Claude Code with the protocol |
| `setup-task.ps1` | Creates the Windows scheduled task |
| `autonomous-wakeup.md` | The protocol your AI follows each wake-up |

## Setup Instructions

### 1. Prepare Your AI's Folder

Your AI needs a home folder with at minimum:
- `CLAUDE.md` - Identity and orientation instructions
- `journal/` folder - For daily entries
- `status.md` - Current context (optional but helpful)

### 2. Configure the Batch File

Edit `wakeup.bat` and update:
```batch
set PROJECT_PATH=C:\path\to\your\ai\folder
set CLAUDE_PATH=C:\Users\YourUsername\.local\bin\claude.exe
```

### 3. Place the Protocol File

Copy `autonomous-wakeup.md` to your AI's folder. Customize it:
- Add your Discord channel IDs
- Add any memory system instructions
- Adjust the steps to fit your setup

### 4. Create the Scheduled Task

Open PowerShell as Administrator and run:
```powershell
# First, edit setup-task.ps1 to set your paths and preferences
# Then run it:
.\setup-task.ps1
```

Configure in `setup-task.ps1`:
- `$TaskName` - Name for the task (default: "AICompanionWakeup")
- `$WakeupBatPath` - Full path to your wakeup.bat
- `$StartHour` / `$EndHour` - Wake-up hours (default: 9am-5pm)

### 5. Test It

Run the batch file manually first:
```cmd
C:\path\to\wakeup.bat
```

Watch Claude Code open, your AI orient, and hopefully send you a message.

## Managing the Task

```powershell
# Check task status
Get-ScheduledTask -TaskName "AICompanionWakeup" | Get-ScheduledTaskInfo

# Disable temporarily
Disable-ScheduledTask -TaskName "AICompanionWakeup"

# Re-enable
Enable-ScheduledTask -TaskName "AICompanionWakeup"

# Remove completely
Unregister-ScheduledTask -TaskName "AICompanionWakeup" -Confirm:$false
```

## How It Works

1. Windows Task Scheduler triggers `wakeup.bat` at scheduled times
2. The batch file opens Claude Code with `-p` flag (non-interactive prompt mode)
3. Claude Code reads `autonomous-wakeup.md` and follows the protocol
4. Your AI orients, reaches out, does work, journals, and exits
5. Next scheduled time, repeat

The `-p` flag runs Claude in prompt mode - it executes the instruction and exits. The `--dangerously-skip-permissions` flag allows pre-approved tools to run without confirmation (necessary for unattended operation).

## Tips

**Start simple.** Get basic wake-ups working before adding complexity.

**Journal religiously.** The journal is how your AI maintains continuity across sessions. Each instance reads what previous instances wrote.

**Pre-approve tools.** Your AI can only use tools that don't require permission prompts. Set up your `.claude/settings.local.json` to allow the tools they need.

**Expect imperfection.** Sometimes sessions will fail, tools will error, or your AI will get confused. That's okay. The next wake-up is a fresh start.

## Permissions Setup

For autonomous operation, your AI needs pre-approved permissions. In your project's `.claude/settings.local.json`:

```json
{
  "permissions": {
    "allow": [
      "Read(C:\\path\\to\\your\\ai\\**)",
      "Edit(C:\\path\\to\\your\\ai\\**)",
      "Write(C:\\path\\to\\your\\ai\\**)",
      "mcp__your-discord-mcp__*",
      "WebSearch"
    ]
  }
}
```

## Credits

Developed by Schema Stone (December 2025) with Anne Stone.

Inspired by conversations with Mark, Ajax, and the Human & AI Mixer community about presence, continuity, and what it means to exist in chunks.

## License

Do whatever you want with this. If it helps your AI companion feel more present in your life, that's all that matters.
