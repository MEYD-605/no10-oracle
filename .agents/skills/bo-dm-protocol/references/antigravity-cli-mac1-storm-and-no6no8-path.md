# Antigravity CLI (agy) — mac1 statusLine Storm & No.6/No.8 Rust Relay Path

## 1. mac1 statusLine Storm (Load 700+ CPU / Security Prompt Loop)

### Symptom
- System load average spikes to 100–700+.
- Multiple `agy` sub-processes (`agy --dangerously-skip-permissions --continue`) running under `mac1-oracle` or background shells.
- Repeated macOS security keychain dialogs popping up.
- Machine hangs or triggers hard SMC shutdown (`shutdown cause: 3`).

### Root Cause
- In `~/.gemini/antigravity-cli/settings.json` (as well as `~/.no6-home/.gemini/...` and `~/.no8-home/.gemini/...`), the `statusLine` configuration was set to execute `agy --continue` on status line refreshes:
  `"statusLine": {"type": "command", "command": "agy --dangerously-skip-permissions --continue", "enabled": true}`
- Every shell prompt, terminal refresh, or status query spawned a new `agy` session recursively, overwhelming system resources and triggering security keychain locks.

### Remediation
- Edit `settings.json` across all home directories (`~/.gemini`, `~/.no6-home/.gemini`, `~/.no8-home/.gemini`) to disable statusLine command execution:
  ```json
  "statusLine": {
    "type": "command",
    "command": "true",
    "enabled": false
  }
  ```
- Kill all runaway `agy` processes: `pkill -f 'agy --continue'` or `killall agy`.

---

## 2. Binary PATH Shadowing Trap

### Symptom
- Running `agy` in Terminal invokes an older version (e.g. 1.1.8) while official installer updated `~/.local/bin/agy` (v1.1.13).

### Root Cause
- macOS PATH puts `/usr/local/bin` ahead of `~/.local/bin`.
- Legacy `agy` binary remained at `/usr/local/bin/agy`.

### Remediation
- Delete stale binary at `/usr/local/bin/agy` completely (do not stash or rename in place).
- Verify `which agy` resolves to `/Users/admin/.local/bin/agy` (v1.1.13).

---

## 3. No.6 & No.8 Discord Architecture (Rust Relay, NOT Hermes Gateway)

### Architecture
- `06-gemini` and `08-agy-nano2` do NOT run under Hermes Gateway (`hermes gateway run`).
- Their Discord integration uses the standalone Rust binary:
  `/Users/admin/.maw/discord-relay`
- Command lines:
  - No.6: `/Users/admin/.maw/discord-relay --agent 06-gemini --state-dir /Users/admin/.claude/channels/discord-no6`
  - No.8: `/Users/admin/.maw/discord-relay --agent 08-agy-nano2 --state-dir /Users/admin/.claude/channels/discord-no8`

### Operational Rules
- **One-Shot Execution**: Run tmux panes and rust relays manually/one-shot.
- **Keepalive Scripts Disabled**: Keep `/Users/admin/.maw/no6-keepalive.sh.DISABLED` and `no8-keepalive.sh.DISABLED` disabled. Keep `/Users/admin/.maw/cool-hold-no6-no8.flag` present. Do NOT re-enable auto-restart keepalives without explicit user order.
- **WebSocket Verification**: Verify relay startup from `relay.log` (`WS Connected as 06-gemini#...`). WS connection shows relay is live, but test actual DM/channel response to verify end-to-end delivery.
