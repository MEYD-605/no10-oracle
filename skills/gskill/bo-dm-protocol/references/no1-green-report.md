# No.1 GREEN host report (Bo DM phone-first)

Source: `lord-knight-oracle/ψ/writing/mini-books/2026-07-11_green-must-have-numbers/` + bo-dm-video-maclab-night.

## Iron rule
**Status without numbers = opinion, not a report.** Do not say GREEN from process alone.

## Minimum layers before “GREEN”
| Layer | Must see | Fail if |
|-------|----------|---------|
| load | load-guard OK + 1m/5m/15m | load-guard FAIL + unexplained spike |
| disk | `df -h` Data % + avail | Data > 90% |
| mem/swap | free GB + swap used | swap balloon + free low |
| Discord | REST `@me` HTTP 200 (curl + DiscordBot UA) | real 401/403 — not CF-1010 from urllib |
| ARRA | vector connected + doc count | remote dead |
| federation | N/M + offline peer **names** | local maw dead |
| sessions | tmux core lanes + relay/gateway pids | primary lane missing |

Peer offline with names ≠ local RED. Report counts + names; keep local GREEN if stack is live.

## Order of work
1. **Deliver** if Bo already asked for an artifact (file/video/reply).
2. Then survey — do not survey so long that Bo waits while nothing arrives.
3. Report in **natural Thai paragraphs** (phone-first). Tables stay in vault/booklet, not DM walls.

## 8-step body shape (host survey)
1. Open: overall GREEN / not GREEN in one plain sentence  
2. Host + load + power  
3. Disk + RAM  
4. Network + federation (name offline peers)  
5. Discord + ARRA  
6. tmux / relay / Hermes  
7. One-sentence summary  
8. Status line only: `🤖 gmgrok · maclab · <model> · ctx <N>%`

### Good open
`เช็คสถานะ maclab ละเอียดแล้วครับบอส — ภาพรวม GREEN พร้อมลุย`

### Bad open
```
· GREEN
· disk ok
· fed 5/7
```

## 30-second checklist (copy)
```bash
uptime
df -h /System/Volumes/Data | tail -1
bash ~/Code/github.com/MEYD-605/gmgrok-oracle/ψ/tools/load-guard.sh
tmux ls | head -20
pgrep -fl 'discord-relay|hermes.*gateway' | head -15
maw federation | head -30
# Discord REST: curl + User-Agent only — never print token
# arra_stats via MCP
```

## When NOT to say GREEN
| Signal | Action |
|--------|--------|
| Discord REST 401 | PENDING Bo · no token thrash |
| Data disk > 90% | say it + point big paths |
| load-guard FAIL | show top processes first |
| local maw down | RED local · don’t blame peers |
| peers offline, local ok | GREEN local + fed collapse named |

## Care / service GREEN (different bar)
Host GREEN ≠ care GREEN. For peer gateway care (e.g. No.5), also require **live DM reply prove** — see `references/no5-hermes-care.md`.

## Related
- `oracle-exec-methods` skill — STV, survey, QA gates  
- `references/discord-rest-probe.md` · `references/no1-health-pong.md`
