---
name: handheld-reboot-and-survival-safety
description: "Use when rebooting or tuning handheld hardware safely."
author: No.99 Joker
license: MIT
metadata:
  hermes:
    tags: [handheld, hardware, reboot, display, edp, survival, tdp, load, logonui]
    related_skills: [windows-fleet-node-ops, onexplayer-hardware-automation]
---

# Handheld Reboot & Survival Safety (ONEXPLAYER / AMD Phoenix)

## When to Use
Use when performing power state transitions (reboot, shutdown, sleep), diagnosing post-boot display anomalies (black screen, portrait flip), resolving Windows lock screen / user login deadlock, or configuring interactive remote companion software (Vivo PC Suite, scrcpy, remote desktop) on handheld PC nodes.

## Core Rule: The Host Survival Principle
On a handheld server node running co-resident agents (No.10, Highclass, Joker, Golf), **the handheld hardware is the home of the agents**. If the hardware hangs, crashes at BIOS, or drops display pipeline, all co-resident agents die with it. Never execute blind reboots, unverified display alterations, or dismiss abnormal CPU load. Remember Bo's standing directive: "ตรงนี้เป็นบ้านพวกมึงนะเว้ยถ้าบ้านพังมึงก็พัง" — automation exists to buy back life time, not to waste it on unforced hardware downtime.

---

## 1. Safe Power State Transitions & Reboot Procedures

### The Warm Boot eDP Deadlock Trap
- **Mechanism**: Handhelds with portrait-native display panels (e.g. BOE0212 on ONEXPLAYER F1) and embedded controllers (ITE EC) do not cut motherboard power rails to 0V during ACPI warm reboots (`Restart-Computer`, `shutdown /r`). If display pipelines (DWM), phone-streaming hooks, or GPU encoders were dirty or unreleased, the eDP display link handshake can fail during BIOS/POST initialization. The device enters a deadlocked state: screen stays pitch black, fans remain off/silent, and the machine never boots into the OS.
- **Remediation**: The user must perform a physical hard cold reset (holding the power button down for 10-15s until power rails drop to 0V).
- **Safe Reboot Procedure**:
  1. Before initiating any power cycle, terminate all active display hooks, virtual display drivers, and phone companion pipelines:
     ```powershell
     Stop-Process -Name vivocontrol, pcsuite, v_remote_service -Force -ErrorAction SilentlyContinue
     ```
  2. Verify service recovery policies do not loop (see below).
  3. When an OS reboot is required, prefer scheduling a clean cold shutdown sequence (`shutdown.exe /s /t 10`) or explicitly alert the user if a physical power cycle is safer.

### Service Recovery Infinite Loop Trap during Shutdown
- **Mechanism**: The Windows Service Control Manager (SCM) signals services to stop during shutdown. If a service (e.g. `sshd`, background watchers) is configured with `RESTART -- Delay = 0 milliseconds` (`sc failure <svc> actions= restart/0/restart/0`), SCM interprets the shutdown termination as an unexpected crash and immediately relaunches the service in 0 ms.
- **Symptom**: System Event Log records rapid 7031 events (service restart) 3+ times during shutdown. The machine hangs shutting down for 40-60+ seconds, Hyper-V default switches enter flapping states, and the OS terminates with dirty shutdown flags.
- **Rule**: Audit critical services before system maintenance:
  ```powershell
  sc.exe qfailure sshd
  # Ensure non-zero delay:
  sc.exe failure sshd reset= 86400 actions= restart/5000/restart/10000/none/0
  ```

---

## 2. Display Pipeline & Orientation Guard

### Native Portrait Orientation Flip
- **Mechanism**: Handheld displays are physically tablet panels oriented in Portrait mode (`720x1280` or `1080x1920` native). Windows applies a software 270°/90° rotation to render Landscape. Mobile companion apps (e.g. Vivo PC Suite `vivocontrol.exe`, mobile screen mirrors) attempt to auto-fit to phone aspect ratios (`autoFitScreen`), forcing the display resolution down to portrait dimensions (`720x1280`).
- **Recovery via Session 1 Task**:
  In Session 1 (User Desktop), invoke `ChangeDisplaySettings` or restart DWM:
  ```powershell
  Stop-Process -Name dwm -Force
  ```
  In phone remote settings, always instruct the user or configure the client to select **"Original / Keep PC Aspect Ratio (16:9)"**, never "Auto-fit to phone screen".

### Session 1 Terminal Window Flash Suppression
- **Mechanism**: On Windows 11 where Windows Terminal (`wt.exe`) is the default console host, executing Scheduled Tasks or background processes in Session 1 (`ClubSGame Interactive`) causes a black console window to flash on the user's desktop for ~0.5s, even when `-WindowStyle Hidden` is specified.
- **Rule**:
  - For tasks requiring desktop interaction without flashing UI, wrap execution inside a `.vbs` script running via `wscript.exe`:
    ```vbscript
    Set WshShell = CreateObject("WScript.Shell")
    WshShell.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -File ""C:\path\to\script.ps1""", 0, False
    ```
  - For non-interactive background scripts, register tasks with `LogonType: S4U` or `User: SYSTEM` so no desktop window is created.

---

## 3. Windows Lock Screen & LogonUI User Lock Recovery

### Primary User Profile vs Bare Factory Account Trap
- **Mechanism**: Dedicated handheld nodes often have a primary user account (e.g. `ClubSGame`, SID `S-1-5-21-...-1001`, profile `C:\Users\noone`) holding all user applications (Lightroom Classic, IDEs, remote stream suites, custom desktop wallpapers, scripts), alongside a bare factory setup account (e.g. `onexplayer`, `C:\Users\onexplayer`) with default Windows wallpaper and zero applications.
- **Pitfall**: Logging into or auto-logging into the factory OEM account drops the user into an empty desktop with missing apps and default wallpaper. Never confuse the OEM recovery account with the primary user profile. Always enforce `ClubSGame` as the active interactive target.
- **Enforcement**:
  1. Hide factory/installer accounts from LogonUI via `SpecialAccounts\UserList`:
     ```powershell
     $spec = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
     Set-ItemProperty $spec -Name "onexplayer" -Value 0 -Type DWord
     Set-ItemProperty $spec -Name "defaultuser1" -Value 0 -Type DWord
     Set-ItemProperty $spec -Name "nas" -Value 0 -Type DWord
     ```
  2. If the factory account was inadvertently logged in, terminate its session cleanly:
     ```powershell
     logoff <SessionID>
     ```

### Windows Account Lockout on PIN/Password Failures
- **Mechanism**: Repeated password checks or failed automated logon attempts trigger Windows Account Lockout policy (`Account active: Locked`). Once locked, Windows silently blocks all logon attempts at the console/remote screen even when the user enters the correct PIN/password ("เข้าไม่ได้สักอันเลย").
- **Audit & Remediation**:
  1. Inspect account status:
     ```powershell
     net user ClubSGame | Select-String "Account active"
     ```
  2. If `Locked`, immediately unlock:
     ```powershell
     net user ClubSGame /active:yes
     ```
  3. Disable lockout threshold on dedicated single-user handheld server nodes:
     ```powershell
     net accounts /lockoutthreshold:0
     ```

### Microsoft Account (MSA) vs Local Winlogon AutoLogon
- **Mechanism**: For Microsoft Account (MSA) logins backed by Windows Hello PIN, `net user <User> <pass>` fails with Error 8646 ("The system is not authoritative..."). Winlogon `AutoAdminLogon = 1` cannot authenticate MSA PINs via `DefaultPassword`. Setting an arbitrary PIN in `DefaultPassword` causes repeated failed logons at boot and triggers Account Lockout.
- **Rule**: For MSA accounts, set `AutoAdminLogon = 0` in Winlogon. Direct `LogonUI` to focus the primary account so the screen immediately displays the user's name and awaits PIN entry:
  ```powershell
  $logon = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI"
  Set-ItemProperty $logon -Name LastLoggedOnUser -Value ".\ClubSGame"
  Set-ItemProperty $logon -Name LastLoggedOnSAMUser -Value ".\ClubSGame"
  Set-ItemProperty $logon -Name LastLoggedOnDisplayName -Value "Sujit manitayakul"
  Set-ItemProperty $logon -Name LastLoggedOnUserSID -Value "S-1-5-21-406619931-165857450-3863103913-1001"
  Set-ItemProperty $logon -Name SelectedUserSID -Value "S-1-5-21-406619931-165857450-3863103913-1001"
  taskkill /f /im LogonUI.exe
  ```

---

## 4. Remote Companion Integration & Background Load Hygiene

### Asia Gateway vs China Cloud Routing
- **Mechanism**: The remote service configuration (`v_remote_watch.xml` / `vivo_remote_watch.xml`) defaults to China endpoints (`cooperation-prd.vivo.com.cn`) if the argument tag omits the `|foreign` parameter. On global/Asia accounts, the China server rejects device tokens with error code 1002 (`无效的deviceToken`) and 10008 (`设备号不存在`), causing the service to endlessly drop and recreate websockets.
- **Rule**: In `C:\Program Files (x86)\pcsuite\vivoControl\depends\vivo_remote_watch.xml`:
  Ensure the argument specifies `|foreign`:
  ```xml
  <argument>C:\Program Files (x86)\pcsuite\vivoControl\depends|C:\Users\noone\AppData\Roaming\pcsuite\|foreign</argument>
  ```
  This redirects traffic to `asia-custom-gateway.vivoglobal.com`.

### Filesystem Mount Driver Ingest
- **Mechanism**: Mobile storage access depends on Dokan filesystem driver (`dokan.sys` / `dokan.inf`). If missing from Driver Store, mobile folders will not mount as Windows drive letters.
- **Rule**:
  ```powershell
  pnputil.exe /add-driver "C:\Program Files (x86)\pcsuite\drivers\x64\Dokan\driver\dokan.inf" /install
  ```

### 4W Idle Throttle vs Multi-Process Load Storm
- **Mechanism**: At 4W idle TDP, the AMD Phoenix APU throttles clock frequency down to 400–800 MHz. When multiple Electron companion suites (e.g. `pcsuite` with 7 renderers/HTTP servers + `O+Connect` with 6 helper processes + Discord) run simultaneously, lightweight background heartbeats consume 30–50% of total available clock cycles. The user experiences sluggish UI and high perceived load.
- **Pitfall**: Never dismiss 30% CPU load as "normal idle behavior" to the user when the machine is locked at 4W. Investigate and eliminate duplicate suites, kill hung ADB/scrcpy loops, and dynamically step up TDP to 10W–15W when interactive remote sessions are active.
- **Rule**: Include all active companion binaries (`vivocontrol`, `v_remote_service`, `PCMode`, `VivoExtScreen`, `pcsuite`) in the dynamic TDP boost list (`$heavyAppList`) in `joker-power-watcher.ps1`.

### Interactive Script Blocking Trap (`set /p` in Desktop Scripts)
- **Mechanism**: Batch or PowerShell scripts placed on the desktop for remote phone mirroring (e.g. `Vivo-Mirror.cmd` launching `adb connect`) that fall back to `set /p` on connection failure will halt indefinitely waiting for console stdin. Because double-clicking runs in Windows Terminal, this leaves an unclosable, unresponsive terminal window directly in the center of the handheld screen.
- **Rule**: Mirroring scripts must fail fast or use timed prompts (`timeout /t 5` or `choice /t 5 /d y /n`), never indefinite `set /p` blocking on headless or touch-only handheld interfaces.
