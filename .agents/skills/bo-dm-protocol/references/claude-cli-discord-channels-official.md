# Claude Code CLI Discord Channels & Gateway Presence Protocol

## Architecture
Claude Code CLI natively supports bidirectional Discord communication via the experimental channels plugin:
`--channels plugin:discord@claude-plugins-official`

### 1. Inbound Ingress
- Discord Gateway WebSocket messages arrive directly into the Claude session formatted as XML tags:
  `<channel source="plugin:discord:discord" chat_id="<channel/DM_id>" message_id="<msg_id>" user="<username>" user_id="<user_snowflake>" ts="<iso_ts>">...content...</channel>`
- Claude CLI automatically parses the tag and calls the injected MCP tool `mcp__plugin_discord_discord__reply(chat_id, text, reply_to)` to reply.

### 2. State & Access Control (`DISCORD_STATE_DIR`)
- Must pass `DISCORD_STATE_DIR=~/.claude/channels/<seat_name>` in the environment.
- Directory requirements:
  - `.env` containing `DISCORD_BOT_TOKEN=...` (mode 0600)
  - `access.json` defining `dmPolicy: "allowlist"` and `allowFrom: ["<bo_user_id>", ...]`
  - If `access.json` is missing or the user ID is omitted, inbound messages are discarded silently without error.

### 3. Presence Conflict Pitfall (Critical)
- **Problem**: Running a standalone Node.js presence daemon (`presence-<seat>.js`) at the same time as Claude CLI `--channels` creates twin WebSocket sessions on the same bot token. Discord Gateway distributes events erratically or drops typing/message events.
- **Rule**: Kill any standalone presence scripts (`pkill -f presence-<seat>`) before starting Claude CLI with `--channels`. The official Discord plugin manages its own gateway connection, presence, and typing indicators natively.
