# Discord REST probe (gmgrok / fleet)

## Why this exists
Health / "Discord DM status check" / **verify-100** pings need a live REST `@me` signal. A naive Python `urllib` call can return **HTTP 403** with Cloudflare **error code 1010** even when the bot token is valid. That is a **client fingerprint / TLS path block**, not proof of token death.

Worked example (2026-07-09 22:21 No.1 Discord DM status check):
- urllib `@me` → 403 / 1010 (all Auth styles)
- `curl` + `User-Agent: DiscordBot (...)` → **200**, bot id `1518452865750794320` username `Gm grok`
- `discord-relay --agent gmgrok` still up; `relay.log` showed recent successful DM relays

Worked example (2026-07-10 10:10 verify-100): Hermes profile `~/.hermes-gmgrok/.env` also carried a valid bot token; `@me` **200** without printing secrets. Prefer curl+UA as canonical; do not log token values into maw/activity.

## Canonical REST check (no token print)

Try token sources in order (never echo values):
1. `/Users/admin/.claude/channels/discord-gmgrok/.env` (state-dir)
2. `~/.hermes-gmgrok/.env` (Hermes profile; may export `DISCORD_BOT_TOKEN` / `DISCORD_TOKEN`)

```bash
set -a
# prefer state-dir; fall back to Hermes profile
if [ -f /Users/admin/.claude/channels/discord-gmgrok/.env ]; then
  source /Users/admin/.claude/channels/discord-gmgrok/.env
elif [ -f "$HOME/.hermes-gmgrok/.env" ]; then
  source "$HOME/.hermes-gmgrok/.env"
fi
set +a
# DISCORD_BOT_TOKEN or DISCORD_TOKEN expected; never echo it
TOKEN="${DISCORD_BOT_TOKEN:-${DISCORD_TOKEN:-}}"
code=$(curl -sS -o /tmp/discord-me.json -w '%{http_code}' --max-time 8 \
  -H "Authorization: Bot ${TOKEN}" \
  -H 'User-Agent: DiscordBot (https://github.com/MEYD-605/gmgrok-oracle, 1.0)' \
  https://discord.com/api/v10/users/@me)
echo "HTTP $code"
# parse id/username only from /tmp/discord-me.json — do not log token
unset DISCORD_BOT_TOKEN DISCORD_TOKEN TOKEN
```

Expected LIVE: `HTTP 200` + `id` matching bot in `relay-config.json` (`1518452865750794320` for Gm grok).

## Layered Discord green (status ping)

1. REST `@me` 200 via **curl** (above)
2. Hermes config has `mcp_servers.discord-reply` with `DISCORD_STATE_DIR=/Users/admin/.claude/channels/discord-gmgrok`
3. Process: `discord-relay --agent gmgrok --state-dir .../discord-gmgrok`
4. Optional: tail `.../discord-gmgrok/relay.log` for recent "Successfully relayed" / gateway established

Do **not** claim Discord DEAD on layer-1 alone if (3)+(4) are healthy and curl was not tried.

## What is NOT a re-test
- No.1 wording like `Discord DM status check` / `PING health` / **`verify-100`** → verify + **one** `maw hey` PONG. Do **not** send a Bo DM.
- Explicit **re-test MCP reply once** → see `references/discord-mcp-retest.md` (one MCP message to Bo DM, capture id, maw ACK).

## Token-401 vs CF-1010
| Signal | Meaning | Action |
|--------|---------|--------|
| curl `@me` **401** / invalid token body | Auth problem | PENDING Bo / No.1 token lane; do not thrash |
| urllib **403** + error **1010**, curl **200** | Client block, bot OK | Report LIVE; use curl next time |
| REST 200 but MCP missing after bootstrap wipe | MCP config wiped | Restore path in discord-mcp-retest.md |
| REST 200, relay dead | Relay/process layer | Restart relay; not necessarily token |

## State-dir layout (gmgrok)
`/Users/admin/.claude/channels/discord-gmgrok/`
- `.env` — `DISCORD_BOT_TOKEN` (source only, never print)
- `relay-config.json` — botId, knownDM, allowlists
- `relay.log` — gateway + relay outcomes
- `access.json` — dmPolicy / allowFrom

Also may exist: `~/.hermes-gmgrok/.env` for Hermes-side Discord token (same no-print rule).

Never paste tokens into maw, Discord, or activity logs.
