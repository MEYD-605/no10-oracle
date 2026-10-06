# Discord slash + path (gmgrok) — updated 2026-07-11 post-cutover re-verify

## Status (SEALED + LIVE)
- **Bo GO «ลุยเลย»** + **No.1 SEAL cutover GREEN** + dual-agree stand down (2026-07-10).
- **Re-verified 2026-07-11:** gateway-primary still LIVE; do not tell Bo the path is incomplete without probe failure.
- **gmgrok is gateway-primary (GmGrub-class):**
  - `HERMES_HOME=~/.hermes-gmgrok` · LaunchAgent `ai.hermes.gateway-gmgrok` (KeepAlive) preferred
  - Connected as **Gm grok#1231** (app/bot id `1518452865750794320`)
  - `discord-relay --agent gmgrok` **OFF** · gmgrok relay keepalive **not in launchctl**
  - Native Hermes global slash reconciled (**~55**): includes `reset` `retry` `reasoning` `status` `yolo` `whoami` …
  - State file: `~/.hermes-gmgrok/gateway/discord_command_sync_state.json`
  - No.5 stays **separate**: `HERMES_HOME=~/.hermes-no5` · Connected as **No.5#6072** · plist `ai.hermes.gateway`

## Bo correction (do not re-litigate)
- Correct target pattern = **GmGrub note20** (`HERMES_HOME=~/.hermes-no101` + gateway run + native slash).
- **Not** “become No.5”. No.5 is a live Hermes GW on maclab but wrong reference for gmgrok.
- After SEAL, default answer to progress asks is **done / matching class** — residual work is housekeeping (stale handoff docs, maw inbox backlog), not “Discord path still relay”.

## Mental model
| Surface | Discord shows for `/…` |
|---------|------------------------|
| **DM** | **Global** application commands only |
| **Guild** | Global + that guild’s commands |

| Path | What it means |
|------|----------------|
| **gateway-primary (LIVE for gmgrok)** | Hermes registers + handles slash; DMs go to gateway agent session |
| **relay-primary (RETIRED for gmgrok Discord)** | Manual REST menu + inject to CLI — menu ≠ native handlers |

## Verify before claims
1. `pgrep -fl 'hermes gateway run'` + `ps eww` → `HERMES_HOME=~/.hermes-gmgrok` for Gm grok.
2. `pgrep -fl 'discord-relay --agent gmgrok'` → must be **OFF** while gateway owns token.
3. `launchctl print gui/$(id -u)/ai.hermes.gateway-gmgrok` → running when supervision is healthy.
4. `GET /applications/1518452865750794320/commands` or local sync state → global list (DM autocomplete).
5. Gateway log: `Connected as Gm grok` · optional `Safely reconciled N slash command(s)` / fingerprint skip.
6. Progress / “ทำถึงไหนแล้ว”: prefer **live probe + `ψ/focus.md`** over dated `ψ/handoff.md`. If a prior DM said “ยังไม่ตรง…” but probe is GREEN, **proactively correct** Bo (natural Thai, no SEAL bullet dump).

## Cutover recipe (executed — keep for re-run / peer)
1. Config: `~/.hermes-gmgrok` `.env` has `DISCORD_BOT_TOKEN` + `DISCORD_ALLOWED_USERS`; `config.yaml` has `discord` + `gateway` sections.
2. **Stop relay first**: unload/disable gmgrok relay keepalive; `pkill -f 'discord-relay --agent gmgrok'`.
3. **Do not** run `HERMES_HOME=~/.hermes-gmgrok hermes gateway install` if it writes default label `ai.hermes.gateway` — that **clobbers No.5**. Prefer dedicated `ai.hermes.gateway-gmgrok.plist` (HERMES_HOME pinned) — this is the current production path.
4. Start: load/kickstart gmgrok LaunchAgent, or fallback `HERMES_HOME=~/.hermes-gmgrok hermes gateway run --replace --force`.
5. Restore No.5 if disturbed: No.5 label + `HERMES_HOME=~/.hermes-no5`.
6. Slash: default policy `safe` reconciles slowly; look for `last_success_at` in `discord_command_sync_state.json`. Optional `DISCORD_COMMAND_SYNC_POLICY=bulk` for one-shot (rate-limit risk).
7. Prove: DM `/re` → `/reset`/`/retry` autocomplete; click executes on **gateway** (not maw text inject).
8. Receipt No.1 short; Bo natural Thai DM.

## Interim only (pre-gateway — historical)
Manual PUT global ~30 names fixed **menu paint** only. Do not claim parity from PUT alone. Guild skill slash still guild-only; Oracle School guild may 403 Missing Access.

## Attachment / screenshot in Bo DM
- Inbound may say `[attachment(s)]` without path.
- Fetch `GET /channels/{chat_id}/messages?limit=N` → `attachments[].url` **with** signed `ex`/`is`/`hm`.
- Bare CDN URL without signature → ASCII “This content is no longer available.” (not JPEG).
- Download with DiscordBot User-Agent; then vision.

## Bo reply tone
Natural Thai, no bullet SEAL dump. After cutover: say gateway-primary / GmGrub-class, relay off, try `/` for native Hermes cmds. Status line: `🤖 gmgrok · maclab · <model> · ctx N%`.
Progress answers: 1–2 short paragraphs — what is LIVE, what residuals are non-blocking — then status line.

## Pitfalls
- Using **No.5** as the “correct Hermes commands” example after Bo named **GmGrub note20**.
- Claiming gateway GREEN while relay still holding same bot token WS.
- Claiming path **incomplete / ยังไม่ตรง** after SEAL when live PID/env/slash state are GREEN.
- Answering progress from **stale handoff** while focus + probe disagree.
- `hermes gateway install` under custom `HERMES_HOME` rewriting **No.5** `ai.hermes.gateway.plist`.
- Assuming launchd always fails (bootstrap exit 5 history) without checking `launchctl print` for `ai.hermes.gateway-gmgrok`.
- “Slash fixed” when only global names exist and path is still relay→CLI.
- PUT global without full desired set (overwrites).
- urllib CF-1010 for Discord REST — use curl + DiscordBot UA (`discord-rest-probe.md`).
- Spamming No.1 after dual-agree / stand down / state-change only.
