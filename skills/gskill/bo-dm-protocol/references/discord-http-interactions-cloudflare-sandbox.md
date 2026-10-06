# Discord HTTP Interactions on Cloudflare Edge Sandbox

## Architecture Overview
When connecting Discord Slash Commands to Cloudflare Workers / MicroVM Sandboxes (`@cloudflare/sandbox`):
1. **Interactions Endpoint URL (HTTP POST)**: Discord delivers slash command invocations (`/clubs`) via HTTP POST requests to `https://<worker>.workers.dev/interactions`.
2. **Ed25519 Signature Verification**: Requires validating `x-signature-ed25519` and `x-signature-timestamp` against `DISCORD_PUBLIC_KEY` using `verifyKey()` from `discord-interactions`.
3. **Registration**: Commands must be registered via Discord REST API (`POST /applications/{id}/commands`) with `Authorization: Bot <TOKEN>`.

---

## Critical Traps & Solutions

### 1. Interactions Endpoint URL Hijacking Hermes Native Slash Commands (CRITICAL)
- **Trap**: When you set `Interactions Endpoint URL` in Discord Developer Portal for a bot that also connects via Hermes Gateway (WebSocket), **Discord hijacks ALL slash commands** (including Hermes built-ins: `/model`, `/reset`, `/restart`, `/status`). Discord sends them as HTTP POSTs to the external URL instead of over WebSocket.
- **Symptom**: Discord users receive `Unknown integration` (การผสานการทำงานที่ไม่รู้จัก) or `Unknown command` on ALL native Hermes slash commands.
- **Remediation**:
  1. If a bot uses Hermes Gateway WebSocket, **do NOT set Interactions Endpoint URL** on that Bot Application.
  2. Clear it via Discord API: `PATCH /applications/{id}` with `{"interactions_endpoint_url": ""}`.
  3. If custom commands like `/clubs` need to trigger external MicroVMs/Cloudflare Workers, handle them via Hermes Custom Skills, quick scripts, or a dedicated standalone Bot Application.

### 2. The 3-Second Timeout Trap
- **Issue**: Discord enforces a strict **3.0 second** timeout on HTTP interaction responses. If the Worker tries to await a cold MicroVM boot or long-running command (`sandbox.exec(...)`) synchronously, Discord fails with `"The application did not respond"`.
- **Fix**:
  - For immediate short responses: Return `type: 4` (`InteractionResponseType.CHANNEL_MESSAGE_WITH_SOURCE`) immediately with cached/instant metrics.
  - For long-running sandbox tasks: Return `type: 5` (`InteractionResponseType.DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE`) within <1.5s, then follow up via webhook (`PATCH /webhooks/{application_id}/{interaction_token}/messages/@original`) once execution finishes.

### 3. Verification Evidence & Chat Cleanliness (Bo Discipline)
- **Issue**: Pasting raw English test summaries (`Verification Evidence Summary`, `tsc --noEmit`, Vitest output) into Discord DM triggers user frustration ("ชอบส่งอะไรมาแบบนี้วะกูจะเข้าใจไหมเนี่ย").
- **Fix**: Internalize all verification steps behind the scenes. Present final status to Bo in clean, concise, natural Thai without dumping raw CLI logs.
