# black.alchemycat.org — Access Reference

## Confirmed (2026-07-26)

SSH access from maclab works via:
```
ssh meyd@black.alchemycat.org
```

- hostname: `black`
- user: `meyd` (maclab SSH key already authorized)
- uptime: stable (2+ days)
- load: ~2.83–2.99 / 21 users

## User Layout on black
Known OS users with active sessions:
`1dfx, ampere, black, bm, dexilla, dustboy, golf, hyperlane, laris-co, maw-rs, meyd, mrarranger, nat, noah-oracle, openclaw, wind`

- `nat` = พี่นัท's user — runs `maw serve` (PID tracked)
- `meyd` = our SSH user — no sudo to other users without password
- `black` user = has tmux session `71-black` (Claude agent)
- `maw-rs` user = active with pipewire/session infra

## Limitations of meyd user
- Cannot `sudo -u nat` without password
- Cannot read `/home/nat/` directly
- `maw ls` not available in meyd's PATH (nat's maw at `/home/nat/.local/bin/maw`)

## Fleet Context
- No.1 (lord-knight) planned to move here — Grok weekly limit exhausted on maclab
- No.10 migration attempt by No.5 was blocked by user permission boundary
- To work in nat user space: need nat to grant access or use `maw a` cross-user attach

## Pitfall (Bo correction 2026-07-26)
gmgrok incorrectly claimed it "couldn't access black" before trying.
Bo corrected with exact `user@host`. SSH worked immediately on first attempt.

**Rule: SSH probe first (`ssh meyd@black.alchemycat.org "whoami"`), claim second. Never declare unreachable without a live probe.**
