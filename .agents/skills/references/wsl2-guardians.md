# WSL2 guardians on ClubSGame

Ubuntu-26.04 hosts the joker hermes gateway (`hermes-gateway-*.service`), `maw-serve.service`, docker. Three Windows scheduled tasks keep the VM alive:

| Task | Trigger | Action | Notes |
|---|---|---|---|
| `WSL-Ubuntu-Boot` | boot | `wsl -d Ubuntu-26.04 -u root -- sleep infinity` | FRAGILE: fires before WslService is ready → LastTaskResult=1, no retry |
| `WSL-Joker-Hold-User` | logon | same sleep-infinity holder | can be killed (0xC000013A) and left un-re-armed |
| `Oracle-WSL-KeepAlive2` | every 1 min | `~/bin/wsl-joker-keepalive.ps1` | boots VM, starts gateway + joker-vm-hold + maw-serve, re-arms holder, re-points portproxy 3456/3457 |

`.wslconfig`: `vmIdleTimeout=2147483647` (VM never idle-times-out — if it died, something killed it), memory=3GB, 2 CPUs, no swap. Task XML backups live in `~/bin/task-backup/`.

## Debugging a dead/unreachable WSL (proven order)
1. `wsl.exe -l -v` → Stopped/Running; `Get-Service WslService, vmcompute`.
2. Wake with `wsl -d Ubuntu-26.04 -u root -- /bin/true`, then inside: `uptime -s` (last VM boot = when it died), `systemctl is-active hermes-gateway-*.service maw-serve.service joker-vm-hold.service`, `free -h`.
3. Event-log forensics: `Get-WinEvent` provider `Microsoft-Windows-Hyper-V-VmSwitch` — Id 67/232 (port/NIC create) and 69/234 (delete) pairs are vswitch teardowns; a create/delete burst every few minutes = something CYCLING the VM, not idle timeout. TaskScheduler/Operational log is frequently empty — never conclude "no evidence" from it alone.
4. `Get-ScheduledTaskInfo` codes: 267009/0x41301 = task still running; 3221225786/0xC000013A = holder process was terminated — needs the keepalive to re-arm it.
5. Gaps in `~/bin/wsl-keepalive.log` = windows where the guardian itself was asleep; those gaps are the real outage, not the VM state.

## Structural pitfall
The 1-minute keepalive is a single guardian with no shield (interactive-token principal, one-shot trigger from days earlier). If IT stops, nothing revives it — when WSL "mysteriously" dies, verify all three tasks, not just the VM.
