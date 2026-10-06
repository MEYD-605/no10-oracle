---
name: handheld-companion-purge-and-hygiene
description: "Use when purging or tuning handheld companion suites."
author: No.99 Joker
license: MIT
metadata:
  hermes:
    tags: [handheld, hardware, purge, pcsuite, oplus, drivers, survival, tdp, load]
    related_skills: [handheld-reboot-and-survival-safety, windows-fleet-node-ops]
---

# Handheld Companion Purge & Host Hygiene (ONEXPLAYER / AMD Phoenix)

## When to Use
Use when removing or purging invasive OEM mobile companion software (e.g. Vivo PC Suite, OnePlus/OPlus Connect), eliminating hung desktop mirroring scripts (scrcpy, `set /p` traps), cleaning up injected virtual display drivers (`vvd.inf`) causing screen orientation flips, remediating high CPU load storms on low-TDP (4W) handheld nodes, or configuring allowed companion suites (O+ Connect) for low-power streaming.

## Core Rule: The Host Survival Principle
On a handheld server node running co-resident agents (No.10, Highclass, Joker, Golf), **the handheld hardware is the home of the agents**. Any software that destabilizes the display pipeline, triggers BIOS hang, or starves the CPU on 4W idle threatens the existence of all agents ("ตรงนี้เป็นบ้านพวกมึงนะเว้ยถ้าบ้านพังมึงก็พัง").

---

## 1. Invasive Mobile Companion Suite Complete Purge Protocol

When an OEM mobile companion suite causes persistent CPU storms, injects virtual display drivers that flip screen orientation, or leaves hung terminal prompts:
1. **Kill all active suite processes**:
   ```powershell
   taskkill.exe /F /IM pcsuite.exe /IM pcsuite_.exe /IM vivocontrol.exe /IM vivoesService_x64.exe /IM vivoSyncService.exe /IM v_remote_service.exe /IM vivo_remote_service.exe /IM v_remote_watch.exe /IM vivo_remote_watch.exe /IM adb.exe
   ```
2. **Stop & delete background services**:
   ```powershell
   sc.exe stop vivoesService; sc.exe delete vivoesService
   sc.exe stop vivoSyncService; sc.exe delete vivoSyncService
   sc.exe stop v_remote_watch.exe; sc.exe delete v_remote_watch.exe
   ```
3. **Delete interactive Scheduled Tasks**:
   ```powershell
   schtasks.exe /delete /tn Launch-PCSuite-Interactive /f
   schtasks.exe /delete /tn ShowVivoSuite /f
   ```
4. **Purge virtual display and filesystem drivers**:
   ```powershell
   # Find published OEM driver names (e.g. vvd.inf, dokan.inf):
   pnputil.exe /enum-drivers | Select-String -Pattern "vvd\.inf|dokan\.inf" -Context 2,4
   # Uninstall and delete package:
   pnputil.exe /delete-driver <oem#.inf> /uninstall /force
   ```
5. **Silent application uninstall & AppData wipe**:
   ```powershell
   Start-Process -FilePath 'C:\Program Files (x86)\pcsuite\uninst.exe' -ArgumentList '/S' -Wait -NoNewWindow
   Remove-Item -Path "$env:APPDATA\pcsuite", "$env:APPDATA\vivoClipdata" -Recurse -Force -ErrorAction SilentlyContinue
   ```

---

## 2. Low-TDP (4W) Load Storm Diagnostics

### 4W Idle Throttle vs Multi-Process Load Storm
- **Mechanism**: At 4W idle TDP, the AMD Phoenix APU throttles clock frequency down to 400–800 MHz. When multiple Electron companion suites (e.g. `pcsuite` with 7 renderers/HTTP servers + `O+Connect` with 6 helper processes + Discord) run simultaneously, lightweight background heartbeats consume 30–50% of total available clock cycles. The user experiences sluggish UI and high perceived load.
- **Rule**: Never dismiss 30% CPU load as "normal idle behavior" when the machine is locked at 4W. Cleanly remove duplicate suites and hung ADB loops; on an optimized idle handheld at 4W, CPU utilization must be < 2%.

### Interactive Script Blocking Trap (`set /p` in Desktop Scripts)
- **Mechanism**: Batch or PowerShell scripts placed on the desktop for remote phone mirroring (e.g. `Vivo-Mirror.cmd` launching `adb connect`) that fall back to `set /p` on connection failure will halt indefinitely waiting for console stdin. Because double-clicking runs in Windows Terminal, this leaves an unclosable, unresponsive terminal window directly in the center of the handheld screen.
- **Rule**: Mirroring scripts must fail fast or use timed prompts (`timeout /t 5` or `choice /t 5 /d y /n`), never indefinite `set /p` blocking on headless or touch-only handheld interfaces. Remove dead desktop scripts immediately.

---

## 3. Agent Architecture Lessons: Context Compaction & Safety Gates

### Lossless Context Pruning (75% Threshold + 64 Fresh Tail)
- **Mechanism**: In long debugging sessions, accumulating multi-turn tool output without proactive pruning causes total context to exceed token limits (~200k-300k tokens), resulting in API 400 Bad Request errors.
- **Rule**:
  - Do not wait for 90%+ saturation to compact context. Initiate compaction at **75% capacity** (`contextThreshold: 0.75`).
  - Always preserve the **64 most recent messages** (`freshTailCount: 64`) untouched so the agent maintains immediate situational awareness and conversational coherence.
  - Drop transient failed tool retries and error stack traces during compaction; retain only final working configurations, core user directives, and stable file paths.
  - **RTK vs DAG vs Compaction Roles**:
    - **RTK (Recall ToolKit)**: Manages per-turn output size by paging large tool results (>50 lines) to disk cache (`cache/spillover/`), keeping immediate context lightweight.
    - **DAG (Directed Acyclic Graph) Context**: Manages conversation history topology; prunes dead-end trial-and-error branches while anchoring core user directives.
    - **Compaction**: Semantic summarization triggered only when pruned DAG approaches the 75% boundary.

### Local File Search Hygiene (Everything CLI / Port 13210)
- **Mechanism**: Recursive filesystem searches (`Get-ChildItem -Recurse`, `find`, or deep Python traversals) over massive storage volumes (SSD C:\, NAS E:\) at 4W TDP throttle the CPU to 100% and lag interactive sessions.
- **Rule**: Never run blind filesystem walk loops. Utilize the local Everything search service (`es.exe` CLI or HTTP API on port 13210). Everything queries master file tables (MFT) in memory, returning results across millions of files in < 50ms with 0% CPU impact.

### Pre-Execution Safety Hook (`before_tool_call`)
- **Mechanism**: Agents executing autonomous shell commands can inadvertently trigger machine lockups (e.g. running unbuffered warm reboots, modifying graphics driver registry entries, or deleting essential runtime directories).
- **Rule**: Intercept host-critical commands (`Restart-Computer`, `shutdown`, `reg delete`, `diskpart`, `Stop-Process -Name dwm`) through a pre-tool evaluation step. Verify the target host, dependencies, and recovery path before sending the command to the OS terminal.

---

## 4. Configuring & Stabilizing Allowed Companion Suites (O+ Connect / ColorOS)

When the user intentionally uses a companion suite (e.g. O+ Connect / PC Connect) for mobile collaboration:

### Firewall & Network Profile Gateways (`d2d failed`)
- **Mechanism**: Virtual switch/bridge adapters (e.g. `vEthernet (HA-External)`) often default to the `Public` network profile, causing Windows Defender Firewall to drop incoming P2P / D2D packets from phones (`10.x.x.x`) on discovery ports (`10150`, `10152`, `64000`), generating repeated `d2d failed` handshake errors in `datatrans_message.txt`.
- **Rule**: Set network profiles on active adapters to `Private`:
  ```powershell
  Set-NetConnectionProfile -InterfaceAlias 'vEthernet (HA-External)' -NetworkCategory Private
  ```
  Explicitly create inbound rules for all suite binaries:
  ```powershell
  New-NetFirewallRule -DisplayName 'Oplus_Remote_Service_In' -Direction Inbound -Program 'C:\Program Files\OplusConnect\daemon\oplus_remote_service.exe' -Action Allow -Profile Any
  New-NetFirewallRule -DisplayName 'Oplus_Remote_UI_In' -Direction Inbound -Program 'C:\Program Files\OplusConnect\daemon\oplus_remote_ui.exe' -Action Allow -Profile Any
  New-NetFirewallRule -DisplayName 'Oplus_SLDesktopAgent_In' -Direction Inbound -Program 'C:\Program Files\OplusConnect\daemon\SLDesktopAgent.exe' -Action Allow -Profile Any
  ```

### Active-Only Dynamic TDP Boost (Do NOT Include Background Daemons)
- **Pitfall**: Putting persistent background daemons (`O+Connect`, `devicespace`, `oplus_remote_ui`) into `$heavyAppList` pins TDP at 15W permanently because they start minimized on boot (`--openAsHidden`).
- **Rule**: Only include ACTIVE streaming processes in `$heavyAppList`:
  - `phoneCast` (Phone mirroring window)
  - `screenshare` (Active screen collaboration stream)
  - `SLDesktopAgent` (Active remote desktop session)
- **TDP Floor & Recovery Hygiene**:
  - The hourly sync and exit recovery logic in `joker-power-watcher.ps1` must enforce a floor of 4W (`if ($dbTdp -lt 4) { $dbTdp = 4 }`), never an artificial 10W clamp.
  - When active streaming processes exit, explicitly execute `ryzenadj` with base idle targets (`--stapm-limit=4000 --fast-limit=6000 --slow-limit=4000 --apu-slow-limit=4000`) so APU drops back to 4W and 42°C immediately.

### Platform Feature Parity & Remote Desktop Modes (macOS vs Windows on ColorOS)
- **Mechanism**: Handshake payload capabilities differ between operating systems:
  - **macOS (MacLab)**: Lacks Windows remote control services; ColorOS exposes **"การแชร์หน้าจอ" (Screen Share)** allowing Mac display mirroring/extension to the phone/tablet.
  - **Windows (ClubSGame)**: For phones (`deviceType: 8`), ColorOS sends `ScreenShareAbility: "0"`, which hides "การแชร์หน้าจอ" and provides **"เดสก์ท็อประยะไกล" (Remote Desktop)** via `oplus_remote_service.exe` instead. Screen casting from phone to PC (**"การแคสต์หน้าจอ"**, `CastAbility: 1000`) is supported across both platforms.
- **Remote Desktop Authentication Modes**:
  1. **Same-Account Connection (Default & Zero-Touch)**: When both PC and phone are signed into the same HeyTap/OPPO account (e.g. `MEYD605`), no password is required. The phone connects directly via `Settings -> Device Connect -> PC -> Remote PC Control`.
  2. **Password Connection (Cross-Account)**: Defaults to disabled (`allowPasswordConnect: "n"`, showing "Connection using password not allowed"). To allow other devices to connect, the user must toggle "Allow connection using password" on the PC, which reveals the 8-digit Device Code and password.
