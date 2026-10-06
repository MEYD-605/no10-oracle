# Fleet agent “dead?” — layered diagnose (class)

Bo phrasing: `somboเป่นไรตาย`, `มึงอ่ะตายไหม`, peer silent on DM.

## Separate layers (always)

| Layer | Probe | LIVE means |
|-------|--------|------------|
| Discord bot | REST `GET /users/@me` with that bot’s state-dir token | HTTP 200 + expected username/id |
| Relay | `pgrep -fl 'discord-relay --agent <name>'` | process up for state-dir |
| Session | `tmux ls` + `maw agents` | session/window active |
| Brain / model CLI | `tmux capture-pane -t <session> -p -S -80` | completions succeed, not stuck on auth error |
| Registry note | `ψ/data/fleet-number-registry.json` `auth_status` / `auth_note` | historical flag — re-verify live |

## 2026-07-09 sombo worked example

- Discord SomBo `1495641270973104299` REST **200**
- `discord-relay --agent sombo` LIVE · tmux `88-sombo` LIVE · maw agents active
- Brain **DEAD**: grok CLI pane `API error 403 Forbidden: unauthenticated:bad-credentials` on `api.x.ai/v1/chat/completions`
- Registry already had `auth_status: BLOCKED` / OAuth note — useful hint, not final root
- **True root (No.1):** stale OAuth **in-memory** on old `grok-0.2.82` while **global auth.json still API 200**
- **Fix (No.1):** kill old process · reboot `88-sombo` on `grok 0.2.87` · prove `SOMBO_BRAIN_OK` · **no Bo re-auth paste**
- gmgrok mistake: told Bo “ต้อง re-auth/token ใหม่” too early → corrected Bo DM after No.1 fix

## 2026-07-12 No.1 seat gap (500k reboot)

- No.1 announced fresh reboot for 500k · Discord still looked online
- `discord-relay --agent 01-lord-knight` **LIVE** · `tmux 01-lord-knight` / `maw agents` **MISSING**
- No handoff file after announce time (last formal `/forward` earlier morning)
- **Seat DEAD** despite green app — restore via `references/no1-seat-restore.md` (`no1-keepalive.sh` + `no1-fresh.pending` + clear cooldown)
- Prove: maw agents active · pane grok-4.5 · `GROK_DEBUG_CONTEXT_WINDOW=500000` · then clear fresh marker

## 2026-07-12 xAI OIDC permission-denied (email change)

- Bo switched Grok login email · `~/.grok/auth.json` shows new email + fresh OIDC key
- Live probe: **both** `GET /v1/models` and `POST /v1/chat/completions` → **403 permission-denied**
- Log: `auth_mode:Oidc` · often `reauthable:false` — not the same as unauthenticated bad-credentials
- **No.1 + gmlab** (shared Grok CLI auth) fail together while Hermes homes may still work
- **Fix class:** console.x.ai entitlement on that account **or** re-login previous SuperGrok/API account — restart alone will not grant chat
- Full recipe: `references/xai-oidc-permission-denied.md`

## Decision rule for remediation talk

1. If Discord REST ≠ 200 → Discord token/path problem (often No.1 / Bo token lane).
2. If Discord 200 + relay LIVE + **tmux/maw missing** → seat dead (restore session); not “bot fine”.
3. If Discord 200 + relay/tmux LIVE + CLI 403 **permission-denied** on **models+chat** → account entitlement / wrong OIDC login (`xai-oidc-permission-denied.md`) — do **not** only kill+reboot.
4. If Discord 200 + relay/tmux LIVE + CLI 403 **bad-credentials** → check CLI version + restart session **before** asking Bo for a new paste.
5. If global auth probe 200 but running process still 403 bad-credentials → treat as **stale process credentials**, not “token revoked”.
6. Speak to Bo in natural Thai with LIVE vs DEAD layers; avoid SEAL bullet dumps in the DM body.

## IDs (maclab)

- Bo DM chat_id (gmgrok): `1518456063224189090`
- SomBo bot id: `1495641270973104299`
- Sombo session: `88-sombo` · maw `maclab:88-sombo` · state_dir `~/.claude/channels/discord-sombo`
