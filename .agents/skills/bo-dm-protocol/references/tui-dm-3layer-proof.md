# 3-Layer Proof Protocol for TUI + DM Unification

When verifying whether a Hermes TUI pane and Discord DM session are unified:

1. **DB Verification**:
   ```bash
   sqlite3 $HERMES_HOME/state.db \
     "SELECT id, source, user_id, message_count FROM sessions WHERE source='discord' ORDER BY started_at DESC LIMIT 1;"
   ```
   Confirm that `source` is `discord` and `id` matches the target session.

2. **Process Command-Line Verification**:
   ```bash
   ps -ww -p <tui_pane_pid> -o command=
   ```
   Must contain `--resume <discord_session_id>`. A bare `hermes chat --tui --yolo` means un-resumed / separate session state.

3. **Live Sync Increment Test**:
   Send a test message via `maw hey` or Discord DM. Verify:
   - `message_count` in `state.db` increments by 2 (user msg + agent reply).
   - Text appears on the TUI screen.
