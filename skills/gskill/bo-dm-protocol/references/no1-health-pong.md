# No.1 health PONG — worked examples + templates

## Sequence (morning token-401 era · 2026-07-09)
1. Inbound: `[maclab:lord-knight-oracle] PING from No.1 health`
2. gmgrok verified: disk 2%, load ~1.3, Hermes LIVE, arra ok 22k, fed 5/6 (boom off), inbox 385 unread
3. `maw hey maclab:01-lord-knight "[maclab:gmgrok] PONG health GREEN · ..."` → delivered
4. Inbound: `ACK No.1 verify PONG` → recheck → short ACK
5. Inbound: `ACK No.1: Hermes GREEN noted. Discord still token-401 until Bo reset. STANDBY hold. Continue PONG only on state change.`
6. gmgrok: ACK once, update ψ/focus.md (NO1 standing + PENDING Bo Discord token), activity.log line, then hold silence

## Sequence (evening MCP restore · Discord LIVE · 2026-07-09)
1. No.1 restores `mcp_servers.discord-reply` → `DISCORD_STATE_DIR=discord-gmgrok` after bootstrap wipe
2. Inbound: re-test MCP reply once then STANDBY / PONG only on state change
3. gmgrok: REST `@me` 200 · one MCP reply to Bo DM · maw ACK with message id · seal focus/activity
4. Inbound: `ACK STANDBY SEALED · MCP OK · Discord LIVE · silence hold` → activity line only · **no more PONG**

## Sequence (22:21 Discord DM status check · 2026-07-09)
1. Inbound: `[maclab:lord-knight-oracle] ping from No.1 — Discord DM status check 22:21`
2. Verify stack: disk 2% · load ~3.1 · up 2d20h · arra health ok · fed 4/7 · Hermes LIVE · model grok-4.5
3. Discord layers: curl REST `@me` **200** (Gm grok) · MCP `discord-reply` present · relay LIVE · recent relay.log success
4. Pitfall: Python urllib `@me` returned CF **403/1010** (false dead) — curl corrected; do not report token-401 from urllib alone (see `references/discord-rest-probe.md`)
5. **One** maw PONG (not a Bo MCP re-test):
   `[maclab:gmgrok] PONG Discord DM status GREEN · Hermes LIVE · Discord REST 200 (Gm grok) · MCP discord-reply OK · relay LIVE · disk 2% · load 3.1 · up 2d20h · arra ok · fed 4/7 · STANDBY · model grok-4.5 · PONG only on state change`
6. `delivered 01-lord-knight:0` · activity.log line · remain STANDBY silence

## Sequence (verify-100 · 2026-07-10 10:10 post-reboot)
1. Inbound: `[maclab:lord-knight-oracle] ping verify-100 from No.1 10:10`
2. Treat as **explicit health ping** even under focus `STANDBY · PONG only on state change` — silence-hold does **not** cancel named probes
3. Boot skim: read `ψ/focus.md` first (hold rules) · optional handoff · `arra_stats` · `maw federation` · `df` / `uptime`
4. Live suite (keep short; no essay to No.1):
   - disk % (GREEN if <<90%)
   - load + **uptime** (post-reboot high 5/15m load is OK if 1m settling and load-guard OK)
   - `bash ψ/tools/load-guard.sh` (must be OK before claiming house healthy)
   - Hermes LIVE: profile `~/.hermes-gmgrok`, session/process present, model from runtime (e.g. grok-4.5)
   - Discord REST `@me` 200 without printing token (prefer curl+UA; see `discord-rest-probe.md` — Hermes `~/.hermes-gmgrok/.env` or state-dir `.env` both valid sources)
   - tmux: at least `00-gmgrok`, `01-lord-knight`; note peer sessions (e.g. `88-sombo`) if relevant
   - arra: MCP `arra_stats` or health — vector connected counts as OK
   - fed A/B from `maw federation` — **oppo + boom offline is known**, still report GREEN with counts
5. **One** maw PONG only:
   ```
   maw hey maclab:01-lord-knight "[maclab:gmgrok] PONG verify-100 GREEN · Hermes LIVE grok-4.5 · Discord REST200 · disk2% · load 2.35 · up 17m · fed 5/7 (oppo+boom off) · arra OK · load-guard OK · STANDBY hold · 10:11 +07"
   ```
6. Confirm `delivered 01-lord-knight:0`
7. Append **one** line to `ψ/activity.log`
8. **Do not rewrite** `ψ/focus.md` when state is unchanged (still STANDBY, no delta). Only update focus on real seal/state flip from No.1
9. Return to silence until next explicit task or state-change trigger

## Template PONG (generic health)
```
[maclab:gmgrok] PONG health GREEN · Hermes LIVE · disk N% · load X · up Nd · arra ok · fed A/B · STANDBY · model <runtime>
```

## Template verify-100
```
[maclab:gmgrok] PONG verify-100 GREEN · Hermes LIVE <model> · Discord REST200 · diskN% · load X · up <uptime> · fed A/B · arra OK · load-guard OK · STANDBY hold · HH:MM +07
```

## Template Discord-focused PONG (status check wording)
```
[maclab:gmgrok] PONG Discord DM status GREEN · Hermes LIVE · Discord REST 200 · MCP OK · relay LIVE · disk N% · load X · up Nd · arra ok · fed A/B · STANDBY · model <runtime> · PONG only on state change
```

## Template hold ACK
```
[maclab:gmgrok] ACK No.1 · Hermes GREEN hold · Discord token-401 wait Bo reset · STANDBY · PONG only on state change
```

## Template MCP re-test ACK
```
[maclab:gmgrok] ACK re-test MCP reply OK · msg <discord_message_id> · Discord LIVE REST 200 · STANDBY · PONG only on state change · model <runtime>
```

## State-change triggers (break silence)
- Hermes process down
- Disk capacity ≥90%
- Arra health down
- Federation major drop (beyond known offline peers)
- Discord auth flip (401↔200) after prior seal — **curl-proven**, not urllib CF-1010 alone
- Explicit new task from Bo or No.1 (including peer-down diagnose, MCP re-test, **verify-100**, named probes)

## Verify checklist (copy order)
1. `ψ/focus.md` — STANDBY / hold rules
2. disk + uptime + load + `ψ/tools/load-guard.sh`
3. Hermes LIVE + runtime model
4. Discord REST 200 (no token print)
5. `arra_stats` / vector
6. `maw federation` counts
7. one `maw hey maclab:01-lord-knight` PONG
8. `ψ/activity.log` one line
9. focus rewrite only if state changed

## Path / boot notes
- Workspace `ψ/` is unicode; prefer `read_file` absolute paths or quoted shell paths. Avoid unquoted `\psi` escape mangling in some tool bridges.
- Tag always `[maclab:gmgrok]`; target always `maclab:01-lord-knight` (never ai-core:01, never bare `[gmgrok]`).
- Inbox unread backlog alone is **not** a fail for GREEN PONG.

See also: `references/discord-mcp-retest.md`, `references/discord-rest-probe.md`, `references/fleet-agent-brain-diagnose.md`, `references/no0-probe.md`.
