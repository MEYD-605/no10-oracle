# Learning: ClubSGame Thermal, Fan Auto Mode & Dynamic TDP Fix

**When**: 2026-10-01 18:20 +07:00
**Agents**: No.8 (Agy Nano2 - MacLab) & No.10 / Joker (ClubSGame)
**Directive by**: Master Bo

## Root Cause Summary
1. **Elevated Temperature (46-48°C vs 37°C Morning Baseline)**:
   - At 17:07, a temporary flag `C:\Users\ClubSGame\bin\charge_to_100.flag` was triggered, forcing the battery to charge at full power (**22.7W**) instead of capping at the 60% homelab bypass baseline.
   - The charging IC and battery chemistry generated sustained heat inside the chassis.
   - Meanwhile, `joker-power-watcher.ps1` had lines 461 and 478 forcing the fan to return to **Preset 2 (35% fixed quiet draft)**, which lacked the airflow required to dissipate 22.7W charging heat.
2. **TDP Desync with OneXConsole**:
   - `joker-power-watcher.ps1` had an **App-specific Dynamic TDP** rule that detected `Lightroom` and auto-boosted to 15W via `ryzenadj`.
   - `ryzenadj` writes directly to SMU registers, bypassing OneXConsole's UI slider.
   - When Lightroom closed, the UI slider still showed 15W, causing user confusion and requiring manual reset to 4W.

## Actions Taken & Verified
1. **Script Backup**:
   - Backed up `C:\Users\ClubSGame\bin\joker-power-watcher.ps1` to `.bak.20261001_1814`.
2. **Fan Logic Overhaul**:
   - Modified `joker-power-watcher.ps1` lines 461 and 478 to restore **Mode 0 (Auto Hardware Curve)** (`bt.automate(true)`) instead of forcing fixed Preset 2.
   - Lowered Thermal Guard trigger threshold from 48°C to 45°C (boost to Preset 1) and recovery threshold from 42°C to 39°C (restore Mode 0 Auto).
3. **Battery Bypass Restoration**:
   - Cleared `charge_to_100.flag`. System immediately engaged **Bypass Power Mode** (Charge/Discharge Rate = 0W, Emerald Green RGB).
4. **Task Reload & Telemetry Verification**:
   - Dispatched `set-fan-mode.js 0` to set EC fan to Auto.
   - Restarted `Joker-Power-Watcher` scheduled task.
   - Verified via `get_sensors.ps1`:
     - Battery Charge Rate: **0W** (Bypass active)
     - Temperatures: Composite 44°C, Temps #1 & #2 43.8°C (trending downwards towards 37°C baseline).
     - APU Power: Stable at ~4-5W idle.

## Operating Principles Reaffirmed
- **Do not ask, execute**: When a root cause is found, implement the fix, verify from the user perspective, and report completed actions.
- **Durable Memory (`ψ/`)**: Every critical fix and calibration must be immediately recorded for fleet continuity.
