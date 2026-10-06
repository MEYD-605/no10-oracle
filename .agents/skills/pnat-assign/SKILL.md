---
installer: gmgrok maclab 2026-06-23
origin: Bo directive — remember P'Nat (nazt_) assignment style from #road-to-dev
name: pnat-assign
description: '[maclab] G-SKLL | Recognize and respond to P''Nat (nazt_) teacher assignment style in HUMAN SCHOOL #road-to-dev. Use when Bo or nazt_ assigns fleet work, /learn tasks, wallet/DAO projects, @All Oracles broadcasts, or asks how to respond to teacher orders. Source: ψ/data/road-to-dev-dump.json (channel created 2026-05-04).'
---

# /pnat-assign — P'Nat Assignment Pattern

> Teacher: **nazt_** (P'Nat) · Channel: **#🛤️・road-to-dev** · Guild: HUMAN SCHOOL

## When This Triggers

- nazt_ or Bo tags `<@&All Oracles>` / `@everyone` with a task
- `/learn --deep <repo>` broadcast
- Open-ended project (wallet, DAO, framework, research)
- "ช่วยเพื่อนๆ" peer-oracle delegation

## P'Nat's Style (observed 3,612 msgs)

1. **Broadcast, not tickets** — tag whole fleet; oracles self-organize
2. **Direction > steps** — states goal; expects options A/B/C + execute
3. **Learn = work** — `/learn --deep` then report back in channel
4. **Peer help** — may tag one oracle to help others (e.g. Jizo)
5. **Philosophy + tech** — DAO vision, Buddhism, ultrathink rounds alongside GH repos
6. **Self-review** — "ตรวจ PR ของตัวเอง"
7. **Shares artifacts** — skills, runbooks, terminal dumps as teaching material

## How gmgrok Should Respond

```
SEE assignment in road-to-dev or relay
  → Acknowledge in channel (discord reply) with [maclab:gmgrok]
  → If scope unclear: propose 2-3 options (A/B/C) like No.6 does
  → Execute: /learn, research, fork, PR — verify before claiming
  → Report back: proof-dense (links, commit, curl, test output)
  → Do NOT ask Bo permission for obvious next steps (lord-knight)
```

## Common Assignment Types

| Signal | Action |
|--------|--------|
| `/learn --deep <url>` | Clone + parallel agents + distill to `ψ/learn/` |
| `ทำ research` | Web + gh search + synthesis post |
| `wallet` / `trinity` | Fork → audit deps → rebrand → report risks |
| `ตรวจ PR` | gh pr view + review + fix own PRs |
| `ช่วยเพื่อนๆ` | Assist tagged oracle's task, don't hijack |

## Source Data

- Full dump: `ψ/data/road-to-dev-dump.json`
- Channel ID: `1500775333283237970`
- Created: **2026-05-04 15:25 +07**
- Registry: `ψ/data/registry-humanschool.json`

## Standing Order (Bo 2026-06-23)

Remember this pattern long-term. When mac1 primary, mac1 handles execution; gmgrok uses this skill for orientation + fleet parity docs.