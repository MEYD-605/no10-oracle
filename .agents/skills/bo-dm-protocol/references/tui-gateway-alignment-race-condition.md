# TUI & Gateway Alignment / Race Condition Avoidance

## Root Problem: TUI Pane vs Gateway Session Disconnect
By default in Hermes:
- **Gateway Process (`hermes gateway run`):** Listens to Discord DMs/channels and creates sessions with `source: discord`.
- **TUI Process (`hermes chat --tui`):** Runs inside tmux panes with `source: tui` / `source: cli`.
- Both processes write to the shared SQLite database (`state.db`), but maintain distinct session IDs.

## The Split-Brain / Race Condition Trap
When attempting to unify TUI and Discord DM by launching a TUI process with `--resume <discord_session_id>` while the Gateway process is also active on that same profile:
- Two active LLM execution loops listen to and write to the **same session ID concurrently**.
- Incoming Discord DMs trigger BOTH processes to generate responses.
- The two agents compete for turns, producing garbled responses, duplicate turns, or transcript corruption.

## Solution Architecture: Single-Daemon Execution + Display Mirroring

### 1. Single Active LLM Execution Process
- **Hermes Gateway (`hermes gateway run`)** serves as the SOLE active LLM execution daemon.
- It receives Discord DMs, manages state transitions, and sends responses back to Discord.

### 2. Read-Only Display Mirroring (`discord-display-mirror` Plugin)
- Install the `discord-display-mirror` plugin across Hermes profile directories (`~/.hermes-*/plugins/discord-display-mirror/`).
- The `pre_llm_call` hook detects incoming Discord messages (`platform == "discord"`) and displays the incoming text on the tmux TUI pane (e.g., via `tmux display-message` or stdout printing).
- This provides live TUI visibility for the user without initiating a second LLM turn.

### 3. Native Auto-Resume Configuration (`tui_auto_resume_recent`)
- Set `display.tui_auto_resume_recent: true` in `~/.hermes-*/config.yaml`.
- When TUI processes launch or restart, they automatically attach to the most recent session without conflicting with the live Gateway daemon.

## Claude Code (`white` / `pimpim`) Comparison
- On `white` (`pimpim` / `b3`), Claude Code uses an event-dispatched architecture (`gateway-listener.ts` → `spawn("claude", ["-p", prompt])`).
- Each Discord event spawns a single-shot `claude` CLI process that replies via REST API and exits.
- Do NOT confuse Claude Code's single-shot spawn pattern with Hermes's stateful Gateway daemon pattern.
