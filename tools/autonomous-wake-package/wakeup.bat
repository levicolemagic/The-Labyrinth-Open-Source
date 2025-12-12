@echo off
REM Autonomous Wake-Up Trigger for Claude Code
REM
REM SETUP: Update the paths below to match your system
REM   - PROJECT_PATH: Where your AI's files live (contains CLAUDE.md, journals, etc.)
REM   - CLAUDE_PATH: Where claude.exe is installed

REM === CONFIGURE THESE ===
set PROJECT_PATH=C:\path\to\your\ai\folder
set CLAUDE_PATH=C:\Users\YourUsername\.local\bin\claude.exe

REM === DON'T EDIT BELOW ===
cd /d "%PROJECT_PATH%"
"%CLAUDE_PATH%" --dangerously-skip-permissions -p "Read autonomous-wakeup.md and follow the protocol. Keep it brief."
