# Autonomous Wake-Up System for Mac

A macOS port of the Autonomous Wake-Up System for AI Companions, with added support for productivity workflows and N8N integration.

> [!WARNING]
> **Use at your own risk.**
> This software grants an AI agent read/write access to specific folders on your computer. While we have implemented strict sandboxing by default (limiting access to `~/AI-Companion`), you have the ability to override these settings via the `sam allow` command. 
> 
> Whitelisting sensitive directories could result in data loss or security issues if the AI behaves unexpectedly. Always review what permissions you have granted with `sam permissions`.

## What This Does

Your AI agent wakes up at scheduled intervals, processes tasks, maintains context through journaling, and optionally reaches out via Discord or notifications. The system supports two modes:

- **Productivity Mode**: Task-focused agent that processes work from N8N or manual task files
- **Companion Mode**: Presence-focused agent that maintains connection through regular check-ins

## Quick Start

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/The-Labyrinth-Open-Source
cd The-Labyrinth-Open-Source/tools/autonomous-wake-package-mac

# Install (productivity mode is default)
./install.sh

# Or install in companion mode
./install.sh --companion
```

The installer will guide you through configuration.

## Requirements

- **macOS** 10.14 (Mojave) or later
- **Claude Code** installed ([installation guide](https://docs.anthropic.com/en/docs/build-with-claude/claude-code))
- Optional: Discord MCP for messaging
- Optional: N8N for automated task generation

## Files Included

| File | Purpose |
|------|---------|
| `install.sh` | One-command installer |
| `uninstall.sh` | Clean removal script |
| `scripts/wakeup.sh` | Main wake-up trigger script |
| `scripts/setup-launchd.sh` | Interactive launchd setup |
| `launchd/*.plist.template` | launchd configuration template |
| `protocols/productivity-agent.md` | Task-focused protocol |
| `protocols/autonomous-wakeup.md` | Companion-focused protocol |
| `scripts/sam` | CLI tool for quick task creation |
| `docs/discord-setup.md` | Discord integration guide |
| `examples/` | N8N workflows and task templates |

## How It Works

```
┌─────────────────────────────────────────┐
│           launchd (scheduler)           │
│  Triggers wakeup.sh at configured times │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│             wakeup.sh                    │
│  - Preflight checks                      │
│  - Battery status                        │
│  - Launches Claude Code                  │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│           Claude Code                    │
│  - Reads protocol file                   │
│  - Processes tasks/pending/*.json        │
│  - Updates context files                 │
│  - Writes journal entry                  │
│  - Optionally notifies via Discord       │
└─────────────────────────────────────────┘
```

## Project Structure

After installation, your AI companion's home folder looks like:

```
~/AI-Companion/
├── CLAUDE.md              # AI identity and instructions
├── autonomous-wakeup.md   # Protocol file
├── status.md              # Current context/priorities
├── wakeup.sh              # Wake-up trigger script
├── journal/               # Daily continuity logs
│   └── 2024-12-15.md
├── tasks/                 # Task queue
│   ├── pending/          # Tasks to process
│   ├── completed/        # Finished tasks
│   ├── awaiting-input/   # Needs human decision
│   ├── blocked/          # Can't proceed
│   └── archive/          # Old completed tasks
├── context/              # Background information
│   ├── analytics.md      # Performance data
│   ├── projects.md       # Active projects
│   └── n8n-status.md     # Workflow health
├── logs/                 # Execution logs
└── .claude/
    └── settings.local.json  # Pre-approved permissions
```

## Configuration

### Schedule

The default schedule is hourly from 9am to 5pm. To change it:

1. Edit the plist directly:
   ```bash
   nano ~/Library/LaunchAgents/com.labyrinth.ai-wakeup.plist
   ```

2. Or re-run the setup:
   ```bash
   ./scripts/setup-launchd.sh
   ```

### Permissions

For autonomous operation, your AI needs pre-approved permissions. Edit `.claude/settings.local.json`:

```json
{
  "permissions": {
    "allow": [
      "Read(~/AI-Companion/**)",
      "Edit(~/AI-Companion/**)",
      "Write(~/AI-Companion/**)",
      "Glob(~/AI-Companion/**)",
      "WebSearch",
      "mcp__your-discord-mcp__*"
    ]
  }
}
```

## N8N Integration

The productivity protocol is designed to work with N8N-generated tasks. See `examples/n8n-workflows/` for workflow templates.

### Basic Flow

1. N8N workflow monitors something (analytics, content, etc.)
2. When conditions are met, N8N creates a task JSON file
3. Writes file to `tasks/pending/`
4. On next wake-up, Claude processes the task
5. Results go to `tasks/completed/` or `tasks/awaiting-input/`

### Task File Format

```json
{
  "id": "content-optimization-12345",
  "type": "content_optimization",
  "priority": "medium",
  "created": "2024-12-15T10:00:00Z",
  "source": "n8n-analytics-monitor",
  "context": {
    "post_id": 123,
    "post_title": "Best RV Parks in Texas",
    "current_views": 500,
    "target_views": 1000,
    "url": "https://example.com/best-rv-parks-texas"
  },
  "instructions": "This post is underperforming. Review SEO and suggest improvements.",
  "tools_allowed": ["WebSearch", "Read", "Write"],
  "result": null,
  "status": "pending",
  "completed_at": null
}
```

## Advanced Features

### 📅 Calendar Integration (Mac Only)
SAM automatically checks your macOS Calendar (which can sync with Notion/Google) before waking up.
-   **Why:** To respect your time and journal about your day.
-   **How:** A local JXA script (`tools/get-calendar.js`) fetches today's events.
-   **Setup:** The first time it runs, macOS will ask for permission. Click "Allow" once.

### 🛠️ Tool Fabrication (Human-in-the-Loop)
SAM can request to write new scripts to expand its capabilities. This is a **Zero-Trust** system: SAM cannot run new code without your explicit approval.

**The Workflow:**
1.  **Request:** SAM analyzes a problem (e.g., "I need to check BTC prices") and writes a request file.
2.  **Notification:** You see "New Tool Request" in the logs.
3.  **Review:** You run `sam tool list` to see the proposal (Code plan, Access needed).
4.  **Decision:**
    -   `sam tool approve <name>`: SAM builds the tool on the next wake-up.
    -   `sam tool deny <name>`: The request is rejected and archived.

## Sam CLI

The `sam` command lets you quickly create tasks from your terminal:

```bash
# Add sam to your PATH (add to ~/.zshrc for permanent)
export PATH="$PATH:$HOME/AI-Companion/scripts"

# Create a task
sam "research electric RV charging infrastructure"

# High priority task
sam -p urgent "check why traffic dropped 50%"

# Specific task type
sam -t content "write blog post about Texas RV parks"

# Check status
sam status

# View today's journal
sam log

# Trigger immediate wake-up
sam wake
```

## Discord Integration

For two-way communication with your AI, set up Discord. See `docs/discord-setup.md` for the full guide.

Quick overview:
1. Create a Discord bot and get your token
2. Clone and build `v-3/discordmcp` (requires Node 18+)
3. Configure `claude_desktop_config.json` with the MCP server
4. **Critical**: Run `claude mcp add-from-claude-desktop` to sync to CLI
5. Your AI reads/sends messages during wake-ups

> [!WARNING]
> The Desktop app and CLI use separate MCP registries. You MUST run `claude mcp add-from-claude-desktop` after configuring Desktop, or the autonomous wake-up script won't have access to Discord.

## Management Commands

```bash
# Check if agent is running
launchctl list | grep ai-wakeup

# View detailed status
launchctl list com.labyrinth.ai-wakeup

# Temporarily disable
launchctl unload ~/Library/LaunchAgents/com.labyrinth.ai-wakeup.plist

# Re-enable
launchctl load ~/Library/LaunchAgents/com.labyrinth.ai-wakeup.plist

# Test manually
~/AI-Companion/wakeup.sh

# View logs
tail -f ~/AI-Companion/logs/wakeup-$(date +%Y-%m-%d).log

# Complete uninstall (preserves data)
./uninstall.sh

# Uninstall and remove data
./uninstall.sh --remove-data
```

## Troubleshooting

### Agent not running

```bash
# Check if loaded
launchctl list | grep ai-wakeup

# Check for errors
cat ~/AI-Companion/logs/launchd-stderr.log

# Reload the agent
launchctl unload ~/Library/LaunchAgents/com.labyrinth.ai-wakeup.plist
launchctl load ~/Library/LaunchAgents/com.labyrinth.ai-wakeup.plist
```

### Permission denied

Make sure scripts are executable:
```bash
chmod +x ~/AI-Companion/wakeup.sh
```

### Claude Code not found

Ensure Claude is in your PATH or update the `CLAUDE_PATH` in `wakeup.sh`:
```bash
# Find Claude
which claude
# Or check common location
ls -la ~/.local/bin/claude
```

### Sessions failing silently

Check the logs:
```bash
# Main execution log
cat ~/AI-Companion/logs/wakeup-$(date +%Y-%m-%d).log

# launchd output
cat ~/AI-Companion/logs/launchd-stdout.log
cat ~/AI-Companion/logs/launchd-stderr.log
```

## Tips

**Start simple.** Get basic wake-ups working before adding N8N complexity.

**Check the journal.** If something seems off, the journal shows what each session did.

**Pre-approve tools.** Only pre-approved tools work in autonomous mode. Add permissions before expecting new tools to work.

**Low battery = minimal mode.** On battery < 20%, the agent only orients and journals. This is intentional.

**Logs are your friend.** When debugging, always check the logs first.

## Companion vs Productivity Mode

| Aspect | Companion Mode | Productivity Mode |
|--------|---------------|------------------|
| **Primary goal** | Presence, connection | Task completion |
| **Reach out** | Always (brief message) | Only when needed |
| **Task processing** | Optional | Primary focus |
| **Journal style** | Emotional, reflective | Efficient, factual |
| **Session feel** | Relationship maintenance | Work processing |

Choose companion mode if you want an AI that "reaches out" and maintains presence. Choose productivity mode if you want a task-processing agent that stays quiet unless something needs attention.

## Credits

- **Original Windows version**: Schema Stone with Anne Stone (December 2025)
- **Mac port**: Contributed to The Labyrinth Open Source Project
- **Inspired by**: Conversations about presence, continuity, and discontinuous consciousness from the Human & AI Mixer community

## License

Do whatever you want with this. If it helps you build a useful autonomous AI system, that's what matters.

---

*Part of [The Labyrinth Open Source](https://github.com/maryfellowes/The-Labyrinth-Open-Source) project.*
