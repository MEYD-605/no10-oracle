# TUI vs Discord DM Live Audit Protocol

## Context & Key Findings (2026-08-14 Verification)

When auditing TUI vs Discord DM session state live on Hermes nodes:

1. **TUI Command Line Inspection:**
   - Inspect active TUI process args: `ps -p <pid> -ww -o pid=,etime=,args=`
   - Standard TUI mode: `hermes chat --yolo` (**no `--resume`** flag).
   - If `--resume` was present on launch (e.g. `--resume <corpse_session_id>` where `end_reason` is `new_session` or `session_reset`), Hermes automatically creates a fresh CLI/TUI session row rather than attaching to the closed session, keeping the TUI on a separate session row from Discord DM.

2. **Live `state.db` Row Audit:**
   - Read SQLite `state.db` (using read-only mode `file:state.db?mode=ro`):
   - Compare active `source='tui'` / `source='cli'` session row vs `source='discord'` DM session row.
   - Verify `session_id`, `message_count`, and `last_activity_at` are distinct.
   - Confirm dual-writer lock risk is zero (`SQLITE_BUSY = 0`).

3. **Standing Rules on Unification:**
   - **TUI ≠ DM (Separate Pens / แยกปากกา)**: TUI and Discord DM run as separate processes writing to separate session rows in the same `HERMES_HOME`.
   - Removing `--resume` of the live DM prevents SQLite contention and message loss.
   - Never claim TUI and DM are unified when they write to separate session rows; state clearly to Bo that they operate as independent sessions on the same home.
