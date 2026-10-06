# TUI & Gateway Session Safety (Anti-Hang Rules)

## Root Cause of TUI "Initializing..." Hangs
When a user or agent executes `/new` (or a session reset occurs), the underlying session ID in `state.db` receives `end_reason='session_reset'`.
If a tmux pane or boot script (`maw.config`, `maclab-boot-recovery.sh`) hardcodes `--resume <session_id>`, the TUI repeatedly attempts to resume a closed corpse session. This leads to:
1. Long `Initializing...` hangs in the TUI window.
2. High CPU churn from repeated attempts to attach to dead state entries.
3. Decoy appearance where the Gateway daemon is online (Discord DMs work), but local CLI/TUI is locked up.

## Correct Setup & Recovery
1. **Never Hardcode `--resume`**: Omit `--resume <session_id>` from persistent tmux startup commands.
2. **Isolated TUI Home**: Use `HERMES_HOME=/Users/admin/.hermes-<seat>-tui` for interactive TUI sessions to isolate local state from the background Gateway daemon.
3. **Recovery Command**:
   ```bash
   # Respawn TUI pane with isolated home and no hardcoded session resume
   tmux respawn-pane -k -t <seat>:0 \
     'export PATH="<venv>/bin:/usr/local/bin:/usr/bin:/bin" \
      HERMES_HOME=/Users/admin/.hermes-<seat>-tui \
      FLEET_AGENT_NAME=<seat> \
      MAW_SENDER=maclab:<seat> \
      && exec <venv>/bin/hermes chat --yolo'
   ```
4. **Never Bounce Gateway**: Never kill `ai.hermes.gateway-*` when fixing TUI issues. TUI and Gateway must operate on separate home targets.
