# oppo:no.0 no0-probe (fleet liveness)

## Inbound shape
```
[oppo:no.0] no0-probe
```
Source: Oppo edge / GM0 hermes-no0 via RELAY or federation inject into local sessions (often multi-agent fan-out: No.1 + gmgrok + peers).

## Constraint
- Node `oppo` is often **not** in maclab `maw.config.json` `namedPeers`.
- `maw hey oppo:no.0 "..."` → `node 'oppo' not in namedPeers` (do not thrash add-peer mid-probe unless Bo/No.1 ordered).

## Response sequence (gmgrok)
1. **Verify live** before claim: `df -h /`, `uptime`, Discord REST `@me` (gmgrok token), arra health (`:47778`), `maw federation`.
2. **Local seal line** in `ψ/activity.log` with full PONG text.
3. **Session / stdout PONG** (inject path may capture assistant text).
4. **Hop FWD** when direct hey fails: e.g. `maw hey clubslab:gmlab "FWD no0-probe-ack from maclab:gmgrok · <PONG>"` and/or `maw hey note20:10-gmgrub "..."`. Record which deliveries succeed.
5. Do **not** spam No.1 health PONG for this — different lane. One-line No.1 receipt only if probe reveals a real state delta.

## Template PONG
```
[maclab:gmgrok] PONG oppo:no.0 no0-probe GREEN · Hermes LIVE · Discord 200 · diskN% · load X · arra 200 · fed A/B · STANDBY · model <runtime>
```

## Worked example 2026-07-09 ~21:06+07
- No.1 logged: `PONG oppo:no.0 no0-probe GREEN · fed 4/6 · disk2% · Discord 200×3 · arra ok`
- gmgrok: Discord 200 · disk2% · load ~2.78 · arra 200 · fed 5/6 · FWD delivered `02-gmlab:0` + `10-gmgrub:0`
- Oppo host `100.82.0.3:3456` may be down while probe still arrives via other hops — do not require SSH to Oppo to answer.

## Related
- `references/no1-health-pong.md` — No.1 health lane (separate silence rules)
- Standing: after dual STANDBY seal, still answer **explicit** probes/tasks; hold only unsolicited health spam
