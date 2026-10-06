# Shared Discord MCP Server Token Fallback Diagnostics & Multi-Bot Hierarchy

**Discovered / Verified**: 2026-08-20 during No.2 High Wizard (Claude CLI + 9router + Discord Channels) revival on maclab.

## Problem Description
When multiple AI bot seats (e.g. No.1, No.2, No.6, No.8) share a single centralized Discord MCP server script (e.g. `/Users/admin/ClubS-Workspace/tools/discord-engine/discord-mcp.ts`), the script uses a fallback token resolver `resolveToken()` when `process.env.DISCORD_BOT_TOKEN` is not directly exported in the subagent's execution environment.

```typescript
function resolveToken(): string {
  if (process.env.DISCORD_BOT_TOKEN && process.env.DISCORD_BOT_TOKEN.trim().length > 0) {
    return process.env.DISCORD_BOT_TOKEN.trim();
  }

  const candidatePaths = [
    process.env.DISCORD_STATE_DIR ? join(process.env.DISCORD_STATE_DIR, ".env") : "",
    join(homedir(), ".claude", "channels", "discord-no2", ".env"),
    join(homedir(), ".claude", "channels", "discord-no6", ".env"),
    join(homedir(), ".claude", "channels", "discord-no8", ".env"),
    join(homedir(), ".claude", "channels", "discord-no1", ".env"),
  ].filter(Boolean);
  ...
}
```

## Symptoms of Token Hierarchy Omission
1. **Silent Fallback to First Valid `.env`**: If a newly provisioned bot seat (such as `discord-no2`) is missing from `candidatePaths` or `DISCORD_STATE_DIR` is not set, `discord-mcp.ts` reads the first available `.env` (e.g., `discord-no6`).
2. **Discord API 403 Forbidden / Cloudflare Error 1010**: The bot uses Bot A's token to post to a channel/DM opened by Bot B. Discord API rejects the cross-channel request with 403 Forbidden (Missing Access / Error code 1010).
3. **Ghost / Impersonation Responses**: Bot A replies with Bot B's name or fails completely while the CLI/TUI session claims the reply succeeded.

## Verification & Remediation Procedure
1. **Check Central MCP Resolver**:
   Inspect `tools/discord-engine/discord-mcp.ts` to ensure all active fleet channels are listed in `candidatePaths`:
   ```bash
   grep -n "candidatePaths" -A 10 tools/discord-engine/discord-mcp.ts
   ```
2. **Validate Bot Token Match via REST API**:
   Verify that each channel's `.env` token resolves to the expected bot identity:
   ```bash
   python3 -c "
   import urllib.request, json
   token = '...'
   req = urllib.request.Request('https://discord.com/api/v10/users/@me', headers={'Authorization': f'Bot {token}', 'User-Agent': 'DiscordBot'})
   with urllib.request.urlopen(req) as resp:
       print(json.loads(resp.read()))
   "
   ```
3. **E2E Tool Test**:
   Execute a mock JSON-RPC `reply` call through `bun run discord-mcp.ts` with the specific bot token before declaring the seat operational.
