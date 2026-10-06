# TUI + Gateway Session Unification & Window Naming Runbook

## Core Rules

1. **`HERMES_HOME` Alignment**:
   - Both Gateway and TUI pane for a seat MUST use the exact same `HERMES_HOME` (e.g. `~/.hermes-gmgrok`).
   - Do NOT use separate `-tui` home directories (`~/.hermes-gmgrok-tui`), as that splits SQLite `state.db` into two separate databases.

2. **Live Session Resume**:
   - TUI `--resume <session_id>` MUST point to a live Discord child session (`ended_at IS NULL`).
   - NEVER `--resume` a session with `end_reason = 'session_reset'`. Resuming a reset parent causes `Initializing...` hangs, session locks, and gateway state.db ballooning (~1.4GB).
   - Set `display.tui_auto_resume_recent: false` in `~/.hermes-<seat>/config.yaml` to prevent auto-grabbing corpse sessions on launch.

3. **Tmux Window Naming to Prevent Silent Loss (`maw hey`)**:
   - `maw hey` uses prefix-matching on tmux window names.
   - If a window is named bare `<seat>` (e.g. `gmgrok`), `maw hey` sends messages to window 0 (shell) instead of window 1 (agent pane). zsh attempts to evaluate `[node:seat]` as a glob pattern, throws `zsh: no matches found`, and silently drops the message.
   - **Enforce window naming**:
     - Window 0: `ops-shell` (zsh)
     - Window 1: `<seat>-oracle` (e.g. `gmgrok-oracle`)
     - Disable auto-rename: `tmux set-option -t <session> automatic-rename off` and `tmux set-window-option -t <session>:<win> automatic-rename off`.
     - Verify `.maw/fleet/<seat>.json` sets `"delivery_window": "<seat>-oracle"`.

4. **Multi-Seat Respawn Script Pattern**:
   To attach sibling seat TUIs (`no1`, `no4`, `no5`) to live DM sessions without restarting gateway daemons:
   - Query `state.db` for the latest live Discord DM session ID (`ended_at IS NULL`).
   - Run `/Users/admin/ClubS-Workspace/scripts/tui-resume-live-dm.sh <seat>` via an external `.command` script (`open /tmp/unify.command`) so gateway processes remain untouched.
