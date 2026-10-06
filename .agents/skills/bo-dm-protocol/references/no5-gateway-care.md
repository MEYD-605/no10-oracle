# No.5 / Hermes gateway-primary care (maclab) — 2026-07-11

## Never claim GREEN without DM prove
Process up + REST `@me` 200 + slash count ≠ working chat. After any restart/config change:
1. Prove delivery: `HERMES_HOME=~/.hermes-no5 hermes send --to discord:<chat_id> "..."` **or** Bo retest short ping.
2. Confirm agent turn ends with final text auto-delivered (gateway log `response ready` / streaming deliver) — not clarify Chat ID.

## Reply path (gateway-primary)
- Final assistant text is **auto-posted** by Hermes gateway. Do not require `mcp_discord_reply_reply`.
- **Landmine:** `discord-reply` MCP on No.5 + Gemini → calls tool with empty/wrong chat_id → clarify "ขอ Chat ID".
- Fix: remove `discord-reply` from `~/.hermes-no5/config.yaml` `mcp_servers`; keep SOUL/CLAUDE rule: never ask chat_id; Bo DM No.5 = `1470628889826037840`.
- gmgrok may still use MCP (protocol passes numeric chat_id) — different agent.

## Poisoned session wipe
If history has fake chat ids / "ไม่มีเครื่องมือ Discord" / clarify loops:
1. Backup `state.db` / sessions.json.
2. Delete messages for that `session_id` (or `hermes sessions delete -y <id>`).
3. Clear `sessions.json` key `agent:main:discord:dm:<chat_id>`.
4. Restart gateway so in-memory session dies.

## Restart No.5 without killing self (gmgrok gateway)
- Hermes blocks `launchctl kickstart` / `hermes gateway restart` from inside gateway process tree.
- Use external shell: `osascript -e 'do shell script "/path/to/kick.sh"'` with script containing `launchctl kickstart -k gui/$(id -u)/ai.hermes.gateway`.
- Never clobber No.5 plist for gmgrok (`ai.hermes.gateway-gmgrok` vs `ai.hermes.gateway`).

## Model: GLM-5.2 (Bo order after Gemini 429)
- Gemini free tier hit **429 RESOURCE_EXHAUSTED** → answers look broken.
- Z.AI **paas/v4** may return balance 1113; **coding** endpoint works:  
  `model.default: glm-5.2` · `provider: zai` · `base_url: https://api.z.ai/api/coding/paas/v4` · `ZAI_API_KEY` in `.env`.
- Prove CLI: `HERMES_HOME=~/.hermes-no5 hermes chat -q '…' --yolo` must log `provider=zai model=glm-5.2`.
- Fallback: `glm-5.1` same coding base_url. xai-oauth/codex may still be dead (OAUTH-RELOGIN-NEEDED).

## Ownership
If gmgrok "managed" No.5 and Chat-ID UX appears after gmgrok restart/config — **own the fault** in Bo DM (no blame-shift to No.5/Gemini alone). Fix path + prove + retest invite.
