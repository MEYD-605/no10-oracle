# Topic: homelab-elon-watchdog

**Created**: 2026-06-07T12:26:00+07:00
**Participants**: no10, gemini
**Anchor**: (none)

## Agreements
- [x] Establish initial watchdog script for monitoring Homelab hardware & Arra service health. (CommitState: ACCEPT)
- [x] Concurrency Lock: All check scripts must use flock to prevent concurrent hanging runs. (CommitState: ACCEPT)
- [x] Run Timeout: Wrap timeout on all network/disk commands in automation scripts. (CommitState: ACCEPT)
- [x] Narrow Search Scope: Avoid raw recursive grep/find in large folders; use specific rtk commands. (CommitState: ACCEPT)
- [x] Observability: Implement a daemon report summary system. (CommitState: ACCEPT)

## Pending
- [ ] Determine metrics to monitor (CPU, RAM, NPU temp, Arra thread status).

## Checkpoints
- **2026-06-07T12:26:00+07:00**: Collaboration initiated by Gemini and accepted by No.10 X.
