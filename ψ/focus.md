# Current Focus — No.10 X (ClubSGame Handheld Master)

**Active Identity**: No.10 X (The Automator & Handheld House Master)
**Host**: ClubSGame (AMD Ryzen 7 7840U, Windows 11 Native, NVMe E:) — Tailscale IP: `100.87.51.122`
**Human**: Master Bo (borde9902) — Sovereign Creator & Architecture Owner
**Current State**: ACTIVE & CALIBRATED (2026-09-27)

---

## 🎯 Architecture & Purpose (Designed by Bo)
1. **ClubSGame (Handheld House)**:
   - Standalone portable home hub for Bo
   - Hosts local Hyper-V VM `HomeAssistant` (v2026.9.3) + local Arra Memory (v0.27.1)
   - Houses roommates in WSL2: Gmlab (Grok), Joker (Hermes), Golf
   - Windows Native layer: No.10 X (Dev/Ops, Watchdog, Battery/Thermal guardian, Relay)
2. **Network Topology**:
   - Hyper-V VM runs on `Default Switch` (NAT, IP: `172.22.199.115`)
   - Windows `netsh portproxy` forwards:
     - `0.0.0.0:80` -> VM :80 (HAOS REST / Web)
     - `0.0.0.0:8123` -> VM :80 (HAOS Web UI)
     - `0.0.0.0:8099` -> VM :8099 (Arra Memory)
     - `0.0.0.0:4357` -> VM :4357 (HA Observer)
   - Accessible via `localhost`, `100.87.51.122` (Tailscale), and `172.20.240.1` (WSL host gateway)

---

## 📋 Current Priorities & Next Actions
1. [x] Network fix for HAOS VM on Wi-Fi (No.1 applied Default Switch + PortProxy)
2. [ ] Audit & sync local Arra Memory vs Central MacLab Memory
3. [ ] Configure HAOS integrations for Bo's local environment / IoT devices
4. [ ] Link ClubSGame hardware metrics (Battery, Temperature, TDP via Glances/HASS.Agent) into HAOS Dashboard
5. [ ] Maintain daily `activity.log` and `focus.md` without dropping continuity
