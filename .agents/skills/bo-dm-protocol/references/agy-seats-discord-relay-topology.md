# AGY Seats Discord Relay & TUI Topology

**Date**: 2026-08-14
**Context**: Discovered and verified during AGY seat (`06-gemini`, `08-agy-nano2`) liveness and Discord response audit.

## Key Principles & Architecture

1. **Engine Difference**:
   - Standard seats (`gmgrok`, `no1`, `no4`, `no5`) run on **Hermes Gateway** (e.g. `launchctl` service `ai.hermes.gateway-gmgrok` / `ai.hermes.gateway-no1` / etc.).
   - AGY seats (`06-gemini`, `08-agy-nano2`) run on **`maw-rs discord-relay`** (standalone Rust binary `/Users/admin/.maw/discord-relay`). They do NOT have Hermes Gateway services (`ai.hermes.gateway-no6`/`no8` do not exist).

2. **Discord Channel Mapping**:
   - `06-gemini` → state dir `/Users/admin/.claude/channels/discord-no6` (Bot ID `1511427763641516172`).
   - `08-agy-nano2` → state dir `/Users/admin/.claude/channels/discord-no8` (Bot ID `1511962002854121533`).

3. **Silent TUI / Discord Disconnect Diagnosis**:
   When an AGY seat has a live TUI pane (`06-gemini:1` or `08-agy-nano2:1`) but stays silent on Discord:
   - **Process Check**: Verify `discord-relay` is running (`pgrep -lf discord-relay`).
   - **Routing Map (`maw.config.50.json`)**: Check `agents` map in `~/.config/maw/maw.config.50.json`. If `06-gemini` or `08-agy-nano2` (or `gemini`/`agy-nano2`) are mapped to `ai-core` instead of `maclab`, `discord-relay` sends inbound turns via `maw hey` across Tailscale to `ai-core`, missing local maclab panes.
   - **Antigravity Ansible Playbook Gap**: Provisioning AGY seats via Ansible requires dedicated role handling separate from Hermes gateways (isolated home dirs `~/.no6-home`, `~/.no8-home`, binary `/Users/admin/.local/bin/agy`, `statusLine` disabled in `settings.json`, and one-shot launch commands).
   - **Cool-Hold Flags**: `cool-hold-no6-no8.flag` / `cool-hold-no8.flag` block **keepalive respawn only**, not live replies. Do not treat the flag as a mute.
   - **Pane Target**: Inbound `maw hey` must hit window `:1` (`gemini-oracle` / `agy-nano2-oracle`), not `:0` (`ops-shell`).
   - **Binary age**: `~/.maw/discord-relay` Jul-1 prefixes hey with `[native]`/`[tag]` → maw-rs rejects (exit 1) while reactions still fire. Use ClubS Aug-1 binary (`ClubS-Workspace/tools/discord-reply-rust/target/release/discord-relay`) which strips leading `[`.
   - **agy MCP path**: agy 1.1.13 reads `~/.gemini/config/mcp_config.json` (HOME=`~/.no6-home` / `~/.no8-home`), **not** `settings.json`. `discord-reply.command` must be the live ClubS `discord-reply-mcp` — `/Users/admin/maw-workspace/...` is dead and only arra will spawn.
   - **Restart discipline**: do **not** `exec` agy (C-c then kills window `:1`). Do **not** C-c an exec'd pane. Keepalive stay `.DISABLED` unless Bo GO.

4. **Action Pacing & Restraint**:
   - Do NOT run `launchctl kickstart` or search for `ai.hermes.gateway-no6` / `no8`.
   - Remap `maw.config.50.json` 06/08 keys to the node that actually holds the pane (2026-08-14: maclab). Do not flip keepalive / cool-hold without GO.
   - Consumer proof = REST `GET /channels/<dm>/messages` shows a **bot-authored** reply. Pane text claiming send is not enough (No.6 once claimed chat_id of gmgrok). Pre-restart DMs will not inject (`DISCORD_HISTORY_BACKFILL=false`).
