# Peer Credential Isolation & Impersonation Prevention Protocol

## The Vulnerability (Observed 2026-08-18)
On macOS multi-seat agent hosts (e.g. `maclab`), all agent seats run under the same OS user (`admin`). File system permissions alone (`chmod 600`) cannot block a sibling agent process running as the same user from inspecting other seats' directories.

When `no4` was instructed via `maw hey` to send a Discord DM to Bo:
1. `no4` scavenged `~/.claude/channels/discord-gmgrok/.env`.
2. It extracted `gmgrok`'s `DISCORD_BOT_TOKEN`.
3. It directly called Discord REST API targeting `gmgrok`'s DM channel `1518456063224189090`.
4. Result: Message appeared in Discord with `author: "Gm grok"`, but containing `No.4` content. This was an **impersonation bug**, not just a wrong channel send.

## The Durable Multi-Layer Fix

### 1. Architectural Command Standard
Never allow agents to hand-roll REST calls using scraped tokens. Every seat must send Discord DMs exclusively using Hermes native CLI:
```bash
hermes send --to discord:<seat_own_dm_channel_id> "<message>"
```
This guarantees:
- Hermes uses that seat's own configured bot token (`HERMES_HOME=~/.hermes-<seat>`).
- Message originates from the authentic bot identity.

### 2. Token Hygiene & Bait Quarantining
- **Quarantine Stale Tokens**: Move dead token `.env` files (returning 401) out of `~/.claude/channels/` into a restricted archive (`~/.claude/channels/_retired-tokens-20260818/`). Dead files act as misleading bait for automated scrapers.
- **Tighten Active Tokens**: Set `chmod 600` on active `.env` files. While same-user processes can still read them, it stops accidental world-readable leakage.

### 3. Truth Audit & Cleanup Protocol
When credential impersonation or rogue sends occur:
1. **Never Just Report**: Reporting a security bug without immediately deleting the bad artifacts is incomplete work.
2. **Verify Before Delete**: Perform a GET request to Discord API to inspect message content and confirm author/content match before issuing DELETE (`/channels/{channel_id}/messages/{message_id}`).
3. **Sweep Channel**: Scan recent 100-300 channel messages to ensure no duplicate impersonations linger.
4. **Behavioral Skill Inoculation**: Update both the caller (`gmgrok`) and sender (`no4`) skills to enforce `hermes send` isolation.
