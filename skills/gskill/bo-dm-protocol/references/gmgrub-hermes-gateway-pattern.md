# GmGrub-class Hermes gateway (canonical for gmgrok Discord) — updated 2026-07-11

## Bo rule
Correct example for Hermes slash + Discord ownership = **GmGrub on note20**, not maclab No.5.
gmgrok target = **same class of isolation** (1 bot = 1 `HERMES_HOME` + `hermes gateway run` owns Discord + native slash handlers). Not “become No.5”.

## Pattern (post-cutover LIVE)
| Piece | GmGrub (note20) | gmgrok (maclab, **SEALED + re-verified 2026-07-11**) |
|-------|-----------------|------------------------------------------------------|
| HERMES_HOME | `~/.hermes-no101` | `~/.hermes-gmgrok` |
| Process | `hermes gateway run` | `hermes gateway run --replace` via **LaunchAgent `ai.hermes.gateway-gmgrok`** (KeepAlive) |
| Discord bot | GmGrub T.0#9059 · id `1496973688745230408` | Gm grok#1231 · id `1518452865750794320` |
| Slash | native register + tree sync | same — reconciled **~55** global (`safe` policy; fingerprint skip on restart OK) |
| Isolation | 1 bot = 1 home (never nest second bot under same home) | No.5 stays `~/.hermes-no5` · label `ai.hermes.gateway` · Connected as No.5#6072 |
| Relay | n/a (gateway owns WS) | `discord-relay --agent gmgrok` **OFF** · gmgrok relay keepalive **not loaded** |

## Cutover SEAL (2026-07-10) + progress answers
- Bo GO «ลุยเลย» · No.1 SEAL cutover GREEN · dual-agree stand down · **state-change only**.
- **Default narrative after SEAL:** path is **done / gateway-primary**. Do not reopen “ยังไม่ตรงแบบนั้น” unless live probe fails.
- Bo “ทำถึงไหนแล้ว” on this thread → re-verify live (below) → short natural Thai: done pieces + only real residuals (e.g. stale handoff file, maw inbox backlog) · not Discord path incomplete.
- Later No.1 SEALs (No.5 care GREEN · ChatID-ask fix · **gmgrok untouched OK**) are **peer/care seals**, not reopening gmgrok cutover. Light-verify isolation · one PONG · stand down. Do **not** mutate gmgrok config to “match” No.5 (independent homes).

## Live prove checklist (mandatory before status claims)
1. List gateway PIDs: `pgrep -f 'hermes_cli.main gateway run'` (or `hermes gateway`).
2. **Map PID → home via cwd (authoritative on multi-gateway maclab):**
   ```bash
   for pid in $(pgrep -f 'hermes_cli.main gateway run'); do
     echo "PID=$pid cwd=$(lsof -a -p $pid -d cwd 2>/dev/null | awk 'NR==2{print $NF}')"
   done
   ```
   Expect: one cwd `…/.hermes-gmgrok` (Gm grok) + one cwd `…/.hermes-no5` (No.5).
3. Optional env check: `ps eww -p <pid>` → `HERMES_HOME=…` when present.
4. `pgrep -fl 'discord-relay --agent gmgrok'` → must be empty.
5. `launchctl print gui/$(id -u)/ai.hermes.gateway-gmgrok` → `state = running`, working directory `~/.hermes-gmgrok`. If missing, bg `--force` process is OK fallback — say so explicitly.
6. Log: `Connected as Gm grok` · optional `Safely reconciled N slash command(s)` or fingerprint skip.
7. `~/.hermes-gmgrok/gateway/discord_command_sync_state.json` → app id `1518452865750794320` has `last_success_at` + summary total ~55.
8. No.5 still separate: label `ai.hermes.gateway` · cwd `~/.hermes-no5` · Connected as No.5#6072.

### Pitfall: `hermes gateway status` lies under dual home
`HERMES_HOME=~/.hermes-gmgrok hermes gateway status` and the same with `~/.hermes-no5` can both report **default** LaunchAgent `ai.hermes.gateway` + No.5 PID. That is a **CLI label/status quirk**, not proof homes are merged.

**Trust order:** process cwd (`lsof`) · `launchctl print` working directory · gateway logs Connected-as · then optional status CLI.

## maclab multi-gateway pitfalls
- Default label `ai.hermes.gateway` = **No.5**. Never repoint it at gmgrok.
- Custom `HERMES_HOME` + `hermes gateway install` may write the **default** label and **clobber** No.5 plist → use dedicated `ai.hermes.gateway-gmgrok.plist` with pinned HERMES_HOME (current known-good).
- Historical: `launchctl bootstrap` **exit 5** on some boots → bg process fallback. As of 2026-07-11 both labels can be running with KeepAlive — claim from `launchctl print` + cwd map, not from old RCA alone.
- Relay keepalive for gmgrok must stay unloaded while gateway owns the token.
- No.5 care must not “align” gmgrok MCP (e.g. removing gmgrok `discord-reply` because No.5 removed it). Isolation = **independent configs**.

## Restart recipe
1. Confirm no `discord-relay --agent gmgrok`.
2. Prefer: `launchctl kickstart -k gui/$(id -u)/ai.hermes.gateway-gmgrok` (or load the dedicated plist).
3. Fallback: `HERMES_HOME=~/.hermes-gmgrok hermes gateway run --replace --force`
4. If No.5 died: restore/kickstart `ai.hermes.gateway` with `HERMES_HOME=~/.hermes-no5` (from **external** shell if inside a gateway agent — see `no5-hermes-care.md`).
5. Wait for slash fingerprint or safe reconcile; prove DM `/` autocomplete (global only).
6. Receipt No.1 short only on real delta.

## Related
- `references/discord-slash-dm.md` (DM global-only · verify steps · progress tone)
- `references/no5-hermes-care.md` (No.5 care · ChatID-ask · OAuth no thrash · gmgrok untouched)
- `friend-peer-registry.json` → `note20-gmgrub`
- gmlab: `phone-gmgrub-deploy-note20.sh`, note20 gateway watchdog
