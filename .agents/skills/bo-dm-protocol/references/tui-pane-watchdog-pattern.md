# TUI Pane Watchdog & Bare Shell Auto-Healing

## The Problem
When Hermes agents in tmux crash or complete a run, tmux leaves the window open with an interactive shell (`zsh`/`bash`). 
- `maw hey` continues reporting `delivered → <seat>:0` because the pane exists.
- The delivered message enters the shell prompt as arbitrary input (getting swallowed or failing with `zsh: no matches found`), while the agent never sees it.

## Architecture of `~/.maw/tui-pane-ensure.sh`
1. Read active seat definitions dynamically from `~/.maw/fleet/*.json`.
2. Inspect `#{pane_current_command}` on each pane. If the process is `zsh`/`bash`/`sh` instead of `python3.11`/`hermes`, treat the seat as **dead**.
3. Cleanly kill the corrupted window and respawn `hermes chat --yolo` with correct `HERMES_HOME` and `MAW_SENDER`.
4. Run periodically every 5 minutes via LaunchAgent `com.maclab.tui-pane-ensure`.

## Detached Installation from Hermes Gateway
Gateway sessions block direct `launchctl bootstrap` calls. To install:
Write a detached `.command` script (`~/.maw/install-tui-watchdog.command`) and trigger it via `open`:
```bash
open ~/.maw/install-tui-watchdog.command
```
This isolates registration from the gateway execution tree.
