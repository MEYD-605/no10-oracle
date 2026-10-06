# Remote Mac on Android Foldables: OPPO vs vivo Ecosystem

## Background & Architecture
Both major Chinese foldable flagships (OPPO Find series and vivo X Fold series) offer native, system-level remote desktop control and cross-device collaboration with macOS.

## 1. OPPO (O+ Connect / 随身工作台)
- **Mechanism**: O+ Connect client for macOS + ColorOS cross-device service.
- **Mac Remote Control**: Supports full remote Mac desktop viewing and touch/cursor interaction.
- **Key Advantages**:
  - **Boundless View (全景虚拟屏)**: Can keep the Remote Mac session docked/paned while running mobile apps (LINE, Discord, Notes) side-by-side without disconnecting or minimizing.
  - **Global Cloud Infrastructure**: Global ROM / Thai market models route through SEA/Global relays, resulting in lower latency (~30-60ms) and higher stability when connecting remotely over 4G/5G mobile data outside the home network.
  - **Shared Clipboard & Drag-and-Drop**: Real-time cross-device copy/paste and file transfers.

## 2. vivo (vivo Office Suite / 量子套件)
- **Mechanism**: vivo Office Suite client on macOS + OriginOS / FuntouchOS.
- **Mac Remote Control**: First-mover dedicated Mac remote desktop feature (introduced April 2024 with X Fold 3).
- **Key Advantages**:
  - **Dedicated Mac Keyboard Toolbar**: Pinned virtual bar with `⌘ Command`, `⌥ Option`, `⌃ Control`, `Shift`, `Esc` for seamless Mac shortcut execution (`⌘+C`, `⌘+Space`).
  - **Trackpad Gestures**: 2-finger scroll, 2-finger right click, pinch-to-zoom tuned specifically for macOS ergonomics.
  - **Native Apple Document Preview**: Built-in viewer for `.pages`, `.numbers`, `.key` without needing to convert or open Mac apps.
  - **8.03-inch Inner Screen**: Slightly larger display area for macOS menu bar and text rendering.
- **Key Pitfall**:
  - **China Relay Latency**: OriginOS models route through mainland China servers for WAN/4G/5G connections, causing noticeable latency (~150-250ms) and occasional packet drop when connecting from Thailand without a local direct VPN or LAN connection.

## Operational Rule for Agents
When Bo inquires about smartphone features, foldable specs, or remote Mac capabilities:
1. Always perform live `web_search` to verify latest OS/firmware updates before claiming feature limitations.
2. Never assume an Android brand cannot control Mac without checking their latest cross-device suite (O+ Connect, vivo Office Suite, Link to Windows).
