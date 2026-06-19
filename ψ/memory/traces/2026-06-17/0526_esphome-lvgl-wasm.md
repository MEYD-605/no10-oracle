---
query: "esphome wasm simulator lvgl jc3248"
target: "no10-oracle"
mode: deep
timestamp: 2026-06-17 05:26
friction_score: 1.0
coverage: [oracle, files]
confidence: high
---

# Trace: esphome wasm simulator lvgl jc3248

**Target**: no10-oracle
**Mode**: deep | **Friction**: 1.0 | **Confidence**: high
**Time**: 2026-06-17 05:26

## Oracle Results
None (Searched via grep)

## Files Found
- `/root/Code/github.com/MEYD-605/jc3248-buddy-lvgl/` (PlatformIO C++ project for JC3248 smart display board using LVGL)
- `/root/Code/github.com/MEYD-605/sombo-oracle/scripts/sunton-buddy/` (ESP32 Smart Display UI files and NUS BLE bridge)

## Git History
None (skipped or already incorporated in files)

## GitHub Issues/PRs
None

## Cross-Repo Matches
- `/root/Code/github.com/Soul-Brews-Studio/maw-js/`

## Oracle Memory
- `/root/ψ/inbox/school_knowledge/deleted_channels_history.md` (Mentions JC3248W535C screen AXS15231B QSPI driver, SPI clock 16MHz, and building mockup PNG for it)
- `/root/ψ/memory/learnings/2026-06-04_esp32-buddy-adapt-for-sunton-esp32-4827s043c-480x.md` (Details porting UI from portrait 320x480 JC3248 to landscape 480x272 Sunton, display pinout DE/HSYNC/VSYNC/PCLK, ST7262 RGB driver and GT911 touch)
- `/root/ψ/memory/learnings/2026-06-04_sunton-esp32-3048s043-43in-800x480-cyd-st7262-r.md` (Describes using rzeldent esp32-smartdisplay lib, GT911 Touch INT pin setup, and screen tearing prevention)
- `/root/ψ/memory/learnings/2026-06-05_sunton-claude-buddy-fleet-ble-bridge-end-to-end.md` (Explains Nordic UART service BLE bridge to feed fleet status to LVGL UI)
- `/root/ψ/incubate/opensource-nat-brain-oracle/ψ-backup-opensource-nat-brain-oracle/active-distilled.md` (Explores ESPHome firmware mapped to Oracle concepts: configurations = learnings, updates = /learn, sensor values = traces)

## Friction Analysis
**Score**: 1.0 — Frictionless (well-indexed, highly visible in central vault)
**Coverage**: oracle, files
**Goal check**: Yes, this trace successfully located past implementations, hardware definitions (AXS15231B, ST7262, GT911) and conceptual notes on ESPHome + LVGL simulation within our homelab.

## Summary
- **JC3248 Specifications**: Uses `AXS15231B` QSPI driver (320x480) with 16MHz SPI clock.
- **Sunton Board**: Uses `ST7262` RGB parallel driver (480x272 or 800x480) with `GT911` touch screen.
- **ESPHome Integration**: Previously researched under "esphome-fw" (v1.2.2) and WT32-SC01 configuration, aligning ESPHome YAML patterns with Oracle `CLAUDE.md` structures.
- **LVGL Simulation**: We have a working PlatformIO workspace (`jc3248-buddy-lvgl`) and Python-based VNC/mockup tools. The simulation of LVGL via WebAssembly (WASM) would allow in-browser preview of these layouts.
