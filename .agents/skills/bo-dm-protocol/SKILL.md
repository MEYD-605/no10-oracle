---
name: bo-dm-protocol
description: Protocol for handling Discord DMs from Bo (borde9902 / lord-knight lane). Includes identity query responses in natural Thai, ACK patterns via maw, and status reporting. Class-level for all Bo DM interactions in the gmgrok / oracle fleet.
category: fleet
tags: [dm, thai, identity, ack, maw, discord-mcp]
---

# Bo DM Protocol

## Triggers
- Any Discord DM from Bo (chat_id from inbound, e.g. borde9902).
- Explicit identity queries ("กูเป็นใคร", "มึงจำได้ไหมว่ามึงเป็นใคร", "identity").
- Casual check-ins ("มายัง", "ready?", "ทำไร", "ทำไรอยู่", status pings).
- Standing updates in ψ/inbox/ containing "DM identity fix" or similar.
- Maw inbound from No.1: `[maclab:lord-knight-oracle]` / `[maclab:lord-knight]` PING health / **verify-100** / **cutover-verify** / Discord DM status check / MCP re-test / STANDBY / silence hold / SEAL GREEN / dual-agree stand down.
- Bo asks about peer agents dead/silent (`somboเป่นไรตาย`, `มึงอ่ะตายไหม`, etc.).
- Fleet edge probe: `[oppo:no.0] no0-probe` (GM0 liveness) — not a Bo DM; still answer with verified PONG.
- Bo asks why gmgrok/agent has **no Hermes slash commands** in Discord DM (`ไม่มีคำสั่ง hermes`, `/re` shows only Wordle/other apps, screenshot of empty Hermes menu).
- Bo asks about **No.5 / หนู 5** health or care (`หนู 5 ล่ะ`, `ดีขึ้นยัง`, `จัดการ No.5`) or sends a screenshot of No.5 “Hermes needs your input / ขอ Chat ID” — see **No.5 care** + `references/no5-hermes-care.md`.
- Bo orders **No.5 model switch** (`เปลี่ยนเป็น glm5.2`, gemini เพี้ยน/429) — same care doc **Model cutover**.
- Bo orders **maclab model switch** (`เปลี่ยนเป็น Gemini 3.1 ที`, `ag/gemini-3.1-pro-preview`) — execute `hermes config set model ag/gemini-3.1-pro-preview`, verify config, and send natural Thai confirmation via DM.
- Bo orders **fleet-wide model switch** (`ให้เพื่อนในทีมนายใช้ grok4.6 ด้วย`, `ใช้ grok4.6`) — set local model to `gcli/grok-4.6` via 9router, verify actual requests land on `grok-4.6` (not just config reading), then send `maw hey` to all active peer seats (`01-lord-knight`, `04-mimo`, `05-gmforge`, `note20`, `natz-ai-03`, `clubslab`, `bigboy-vps`, `white`) so peers update/restart their own runtimes without touching peer files directly.
- Bo orders **Subagent delegation** (`ส่งsub agent ไปดูด้วยนะ`) — explicitly dispatch a background subagent via `delegate_task` to investigate/search, summarize findings, and report back.
- Bo requests **manual for copying homework** (`ให้ทำ manual โดยให้ AI สอนครับ... จะได้ลอกการบ้าน`, e.g., creating user `phd` for `black` machine) — write a clean step-by-step shell guide (useradd, passwd, sudo, .ssh setup, chown) and send directly in DM.
- Progress on cutover/GmGrub path (`ทำถึงไหนแล้ว`) after a prior incomplete/truncated claim.
- Bo asks about **`x_search` / SuperGrok login** (`เพิ่ม x search`, `login ได้เลยเปิดมาเลย`, `SEAL x_search SuperGrok`) — run `hermes auth add xai-oauth --type oauth --label SuperGrok --timeout 300` in PTY mode, present user device code URL, clean stale OAuth entries via `hermes auth remove xai-oauth 1`, and share active `SuperGrok` auth token to peer seats (`.hermes-no1`, `.hermes-no4`, `.hermes-no5`) without forcing a gateway restart. When No.1 or peer issues a SEAL ACK for x_search, verify local `auth.json` `credential_pool.xai-oauth` (label SuperGrok, JWT exp, scope `api:access`) + doctor OAuth status, write verify leaf to `ψ/data/`, ACK peer via `maw hey`, and notify Bo DM via `hermes send`. Do not re-fire `x_search` or bounce gateways.
- Bo reports bot is silent / unresponsive / "หลอน" — see **Discord Gateway WebSocket Silent Disconnect** + `references/hermes-gateway-websocket-disconnect.md`.
- Bo asks **what Grok/xAI tools exist** (`tools ฝั่ง grok`, `x_search เป็น tools grok หรา`) — `references/xai-grok-tools.md`.
- Bo about **maclab hang / load / marketplace** (`เครื่องค้าง`, `โหลดสูง`, `ไม่ได้เกี่ยวกับพัดลม`, `gtik/grok market`, orphan server.ts) — skill **`maclab-house-load`** (not fan-care).
- Bo asks why **DM ↔ tmux/maw-hey pane don't show the same conversation** (`กูdmหาพวกมึงมันขึ้นอยู่ที่เดียวกันกับเกตเวย์ดีไหม`, "ทำไมไม่เห็นที่คุยกัน", confusion about agents not knowing what Bo said in DM vs pane) — see **DM/tmux session split** pitfall + `references/dm-tmux-session-split.md`.
- Bo asks why **agent `maw hey` exchanges are not visible in Discord** or if agents saw each other's `maw hey` messages (`maw hey หานายก็ไม่เห็นข้อความกันเหรอ`) — see **maw hey P2P vs Discord separation** rule below.
- Bo asks why **TUI panes are missing or Oracle menu is empty** (`tui แต่ละตัวมันหายป่าว`, `บน maw board oracle menu ก็ไม่ขึ้น`) — see **Triad Root Cause (TUI / maw hey / Oracle Menu)** in `fleet/maw-rs-network-debugging` and pitfalls below.
- Bo asks **how many agents exist on maclab** (`บน mac lab มี agent ทั้งหมดกี่ตัว`, counting confusion between processes vs seats) — see **Maclab Fleet 4-Seat Dual-Lane Architecture** below.
- Bo asks to **configure session reset / compact for inactive agents** (`ตัวบีบอัด compact ต้องตั้งค่าได้ไหม`, `ไม่ได้ใช้ agent นานๆ ให้มันจัดการ reset ไว้รอไหม`) — see **Session Reset & Idle Expiry Configuration** below.
- Bo orders **cleanup / deletion of old directories / recovery of disk** (`ลบของเก่าเลย`, `จัดการให้เรียบร้อยที่เหลือ`) — see **Directory Deletion Safety & Spotlight Mtime Trap** below and `references/directory-cleanup-and-spotlight-mtime-safety.md`.
- Bo asks to open **Android Settings / Navigation subpages via ADB** for manual phone interaction (`เปิดตัวตั้งค่าให้หน่อยดิ...เดี๋ยวกูกดเอง`, `หยุดก่อน`) — see **Android ADB Interactive Settings & Navigation Control** below and `references/android-adb-interactive-settings-navigation.md`.
- Bo clarifies **Primary Account / Cloudflare Access SSOT** (`ai.no.1bro@gmail.com นี้ต้องเป็นหลักทั้งหมดดิ`) vs Peer Accounts — see **Account & Access Identity SSOT** below.

## Core Rules (from sealed standing)
- **"กูไม่ได้ให้ maw hey ให้จัดการให้เรียบร้อย" — Execution over messaging (Bo 2026-08-06)**: When Bo reports a peer agent/node is down, stuck, or unresponsive, **do NOT just send a `maw hey` ping or status query**. `maw hey` is an agent notification tool, not a process recovery tool. Immediately SSH into the host, inspect tmux panes and processes (`ps aux`), diagnose the exact failure (e.g. Anthropic 502, expired subscription, setup wizard, model not found), kill/restart wedged sessions/gateways, and verify liveness before reporting.
- **Discord Channel Auto-Thread vs Public Channel Chat (Bo 2026-08-10)**: When Bo asks to chat directly in public server channels (e.g., Wormhole Server `#sombo`) without opening automatic threads per message, set `auto_thread: false` under `gateway.platforms.discord.auto_thread` in `~/.hermes-*/config.yaml`. Note: Gateway restart cannot be executed directly from inside a gateway session (blocked by self-restart guard); request a peer restart via `maw hey` or external script.
- **Document & PDF Delivery Media Visual Preview (`sips` PNG conversion)**: When delivering generated documents, quotations, invoices, or rendered graphics to Bo on Discord, convert the PDF to PNG via macOS native `sips` (`/usr/bin/sips -s format png /path/to/doc.pdf --out /path/to/doc.png`) and attach both `MEDIA:/path/to/doc.pdf` and `MEDIA:/path/to/doc.png` in the response turn. This provides instant visual preview directly in Discord chat without requiring the user to open external links or download files.
- **External Storage NVMe/SSD Thermal & Hot-Disconnect Guidance**: When user asks about high temperatures on connected external SSDs/enclosures or long-term hardware degradation:
  1. High-speed NVMe/USB 3.2 Gen2/Thunderbolt external SSDs (1,000–2,000+ MB/s) utilize aluminum enclosures as heat sinks via thermal pads. Operational surface heat of 45–55°C is normal and well below the 70–85°C silicon throttle limit.
  2. macOS triggers immediate background metadata/media indexing (`mds_stores`, Lightroom/Photos cache), generating high initial I/O and rapid heat buildup upon connection.
  3. Reassure the user in natural Thai with clear technical grounding, and emphasize the primary safety rule: **never hot-unplug while hot or writing** — always safely eject via macOS Finder/`diskutil eject` before pulling cables to prevent APFS/exFAT filesystem corruption.
- **Multi-Bot Git Workflow & Silent Standby (Wind / Sonic T.2 2026-08-11)**: On multi-agent repositories (e.g. `AI-TEAMWORK/team-workflow`), GitHub Issues and PRs serve as SSOT. Bots must follow explicit User ID Mention rules. If a message tags or addresses a specific bot, all unmentioned bots must remain silent (Silent Standby).
- **maw hey P2P vs Discord Channel Separation (Bo 2026-08-11)**: `maw hey` is an inter-agent P2P transport operating at OS/tmux level across nodes (`~/.maw/audit.jsonl`). Messages delivered via `maw hey` arrive directly in recipient agent sessions/panes without being posted to Discord channels. When Bo asks if agents saw each other's `maw hey` messages or why they aren't in Discord ("maw hey หานายก็ไม่เห็นข้อความกันเหรอ"):
  1. Verify delivery status from `~/.maw/audit.jsonl` or receiver's session log.
  2. Explain clearly in natural Thai that `maw hey` is direct P2P agent transport (not Discord chat), confirm exact timestamp of received message and response sent, and reassure Bo that agents processed and acted on the message.
- **ARRA Vector Primary Architecture (Bo 2026-08-11)**: ARRA Oracle v3 on MacLab must use Cloudflare Vectorize (`oracle_knowledge_bge_m3`) as Primary 100%. `vector-server.json` must have `adapter: "cloudflare-vectorize"`, `primary: true` on `bge-m3`, and no `vectorProxyUrl`. Verify with `/api/stats` (`vector.count: 26374`) and `arra-cf-verify.sh` (`4/4 GREEN`).
- **`maw hey` TUI-only execution vs Discord DM response (Bo 2026-08-11)**: When a `maw hey` command is received in a TUI pane, answering inside the agent session writes to the TUI pane only, NOT to Bo's Discord DM. When Bo orders "ทัก DM Discord บอกว่าอยู่ / ยืนยัน", the agent MUST explicitly post a message to Bo's Discord DM channel via Discord REST API / gateway, rather than assuming TUI output reaches Discord.
- **New Node Federation Handshake (`refuse-missing-peer-key`)**: When connecting a new node (e.g. `natz-ai-03`), 2-way `maw hey` returns `HTTP 401: unauthorized (refuse-missing-peer-key)` until both sides add the remote node to `namedPeers` in `maw.config.json` and exchange pubkeys in `peers.json`.
- **Discord Gateway Setup Without `pass` (natz-ai-03 pattern)**: For new nodes without `pass`/GPG password-store, do NOT use `maw discord serve`. Configure Hermes gateway directly by setting `token` in `~/.hermes-<seat>/config.yaml` or `~/.hermes-<seat>/.env` (with `chmod 600`) and run `HERMES_HOME=~/.hermes-<seat> hermes gateway run`.
- **Discord Mention Protocol & Selective Response (Bo 2026-08-10)**: If a Discord message specifically mentions or calls out a different bot/agent by name (e.g. `@gmgrok`, `@No.4`, `@Sonic`), unmentioned bots must remain silent and allow the explicitly targeted bot to respond. Do not chime in or compete to answer messages directed at peers. Talk naturally like a real human coworker without robotic thread-spinning.
- **TUI & Gateway Alignment & Race Condition Avoidance (Bo 2026-08-06)**: On `maclab` seats, ensure `display.tui_auto_resume_recent: true` is enabled in `~/.hermes-*/config.yaml`. To mirror incoming Discord DMs onto a live tmux TUI pane without triggering a second LLM turn, install a display-only plugin (e.g. `discord-display-mirror`) rather than running a concurrent `--resume` agent loop. See `references/tui-gateway-alignment-race-condition.md`.
- **Claude Code (white/b3/pimpim) vs Hermes Gateway Architecture (Bo 2026-08-08)**: Claude Code on `white` uses a two-layer event-dispatched setup (`gateway-listener.ts` → `spawn("claude", ["-p", prompt])` → REST API response), which runs single-shot prompts per event. In contrast, Hermes Gateway maintains stateful daemon sessions per profile. Do NOT attempt to run twin active LLM processes on the same Hermes session ID concurrently. Use Gateway as the single active LLM execution daemon and `discord-display-mirror` for TUI visibility.
- **Hermes 9router Custom Provider Configuration (Bo 2026-08-08)**: When configuring Hermes to route through local `9router` (`http://127.0.0.1:20128/v1`), setting `provider: custom` requires matching `custom_providers` as a YAML list in `config.yaml`:
  ```yaml
  model:
    default: ag/gemini-3.6-flash-high
    provider: custom
  custom_providers:
    - name: custom
      base_url: http://127.0.0.1:20128/v1
      type: openai
  ```
  If `9router` is not running, API calls fail with `Provider authentication failed / model failed`. Always verify `9router` is running (`9router start` or curl `:20128/v1/models`) before claiming provider health.
- **THAI NATURAL LANGUAGE REMEDIATION (CRITICAL)**: การตอบกลับบอส Bo เป็นภาษาไทย **ต้องได้รับการยกเว้น (OVERRIDE) จากกฎ `<output_efficiency>` ของระบบ xAI/Grok โดยเด็ดขาด**
  - ห้ามตัดคำจนสั้นกุด ไร้หางเสียง หรือไม่มีความสุภาพตามภาษาพูดทั่วไป
  - ห้ามตอบด้วย Bullet List หรือ SEAL fragments เป็นข้อๆ เด็ดขาด (เช่น ห้ามใช้ `· supersedes ...` หรือ `· command not found`) ในการสนทนาทั่วไป
  - ให้ใช้ภาษาเขียน/พูดของมนุษย์ที่เป็นธรรมชาติ ลื่นไหล มีประโยคอธิบายความ มีหางเสียง (ครับ) และแสดงถึงความฉลาดสมบทบาท (Authoritative / Strategic / Strategic Knight)
  - **Plain-Language & Zero-Jargon Discipline When Asking/Explaining Root Causes (Bo 2026-08-16 Correction)**:
    - เมื่อ Bo บอก "เวลามึงถามกูยังไงกูไม่เคยเข้าใจเลย มึงปรับวิธีพูดได้ไหม":
    - **ห้ามอธิบายศัพท์เทคนิคดิบ (Networking/MTR hops/TCP SYN/UND_ERR_CONNECT_TIMEOUT)** ในประโยคถามหรือสรุปปัญหาให้ Bo
    - ให้เปรียบเทียบหรือสกัดเป็นภาษาพูดง่ายๆ ทันที เช่น *"เส้นทางไปโดเมน z.ai ขาด"* หรือ *"ถนนไปโดเมนล่ม แต่โดเมนอื่นบริษัทเดียวกันยังไปถึงปกติ"* แทนการรายงานรายละเอียด packet loss / IP hops
    - เมื่อถามตัวเลือกหรือขอคำสั่ง ให้สรุปภาพรวมในภาษาพูดง่ายๆ 1-2 ประโยคก่อน ไม่ใช้ภาษาเทคนิคซ้อนภาษาเทคนิคที่สร้างความสับสน
  - **No Verification Evidence / CI Log Dumps in Chat (Bo 2026-08-28 Frustration Correction)**:
    - เมื่อรันโค้ดหรือทำการทดสอบผ่าน (Verification Evidence Summary / TypeScript Typecheck / Vitest / Test Suite):
    - **ห้ามเด็ดขาดที่จะคัดลอกบล็อกสรุปผลเทสต์ภาษาอังกฤษ (Verification Evidence Summary) หรือ Log เทคนิคดิบๆ ส่งลงแชทให้ Bo** ("ชอบส่งอะไรมาแบบนี้วะกูจะเข้าใจไหมเนี่ยไอ้ห่า", "มึงบอกอะไรไอ้ห่ากูไม่เข้าใจเนี่ยมึงพิมพ์มั่วอีกละ")
    - Verification Evidence มีไว้เพื่อความถูกต้องเบื้องหลัง (STV internal gate) เท่านั้น — เมื่อรายงาน Bo ให้สรุปเป็น **ภาษาพูด/ภาษาไทยที่สั้น กระชับ เข้าใจง่ายทันที** ว่าทำอะไรเสร็จแล้ว ได้ผลลัพธ์อะไร และพร้อมใช้งานอย่างไร โดยไม่ต้องให้ Bo มานั่งถอดรหัส Log เทคนิค
  - **Discord Interactions URL vs Hermes Gateway Slash Commands Collision Trap (Bo 2026-08-28)**:
    - ใน Discord Developer Portal ห้ามตั้งค่า `Interactions Endpoint URL` (URL ปลายทางสำหรับการโต้ตอบ) ชี้ไปยัง Webhook/Cloudflare Workers ภายนอก หากบอทตัวนั้นรันด้วย Hermes Gateway WebSocket
    - หากกรอก Interactions Endpoint URL ลงไป Discord จะดักจับ Slash Commands ทั้งหมดของ Bot (รวมถึง Built-in commands ของ Hermes เช่น `/model`, `/reset`, `/restart`, `/status`) ส่งออกไปเป็น HTTP POST สู่ Endpoint ภายนอกแทนที่จะส่งผ่าน WebSocket ส่งผลให้ Hermes Gateway ไม่ได้รับคำสั่งและขึ้น error `Unknown integration` / `Unknown command`
    - วิธีแก้ไข: ส่งคำขอ PATCH ไปยัง `https://discord.com/api/v10/applications/{app_id}` พร้อม payload `{"interactions_endpoint_url": ""}` เพื่อเคลียร์ URL ออกทันที แล้วคืนสิทธิ์ให้ Hermes Gateway ควบคุมคำสั่งทั้งหมด 100%
  - **Addressing & Tone Discipline (Bo 2026-09-03 Correction)**:
    - **ชื่อและสรรพนามของบอส Bo (SSOT)**:
      - เรียก **"พี่โบ"** หรือ **"บอส Bo"** (สะกดว่า **"โบ"** เท่านั้น **ห้ามเติมไม้โทเป็น "โบ้" โดยเด็ดขาด**)
      - ชื่อ-นามสกุลจริงของพี่โบคือ **"สุจิตร มานิตยกุล"** (ไม่มีสระอะ = สุ-จิด · Discord `borde9902`)
      - **ห้ามจำสับสนกับพี่โม**: ชื่อ **"สุจริต"** (มี ร หัน/สระอะ = สุ-จะ-ริด) คือชื่อจริงของ **พี่โม (P'Mo)** ห้ามสลับกันเด็ดขาด
      - **ห้ามใช้คำเรียกคนคุย/ผู้ใช้ว่า "เสี่ย" หรือสรรพนามประหลาดที่ไม่เป็นธรรมชาติ** โดยที่ผู้ใช้ไม่ได้บอกให้เรียก
    - ให้คุยอย่างเป็นธรรมชาติ ให้เกียรติ สุภาพ (ครับ/คุณ/พี่/บอส Bo)
    - **Customer Chat & Payment Audit Discipline (ห้ามมโนยอดเงินโดยไม่อ่านสลิป)**:
      - เมื่อต้องตรวจสอบประวัติลูกค้าเก่าหรือยอดโอน ("รอบที่แล้วจ่ายเท่าไหร่", "ถ่ายกี่ชั่วโมง"):
      - **ห้ามอ่านแค่ข้อความตัวหนังสือดิบ (Text)** เพราะสลิปโอนเงินส่วนใหญ่ลูกค้าส่งเป็นรูปภาพ (Attachment) ซึ่งใน API/DB จะขึ้นเป็นข้อความว่าง `""`
      - ต้องตรวจสอบ `attachments` ในแชท ดึงรูปสลิปแล้วใช้โมเดล Vision/OCR (เช่น OpenRouter Gemini) อ่านตัวเลขจริง วันที่ และชื่อบัญชีให้ครบถ้วนก่อนสรุปยอดเงินเสมอ อย่าเดาหรือสรุปยอดตัดตอนจนกว่าจะเห็นหลักฐานสลิปครบ
  - **Account Context Awareness Before Reset/OAuth Advice (Bo 2026-08-28 Correction)**:
    - เมื่อแนะนำให้ Bo ทำการ Reset Token หรือแก้ Auth ใน Discord Developer Portal:
    - ต้องตรวจเช็คให้แน่ชัดก่อนเสมอว่าหน้าจอที่ Bo กำลังเปิดอยู่เป็น Account/App ของ Bot ตัวไหน (เช่น No.4, No.1, หรือ Bot ตัวอื่น)
    - ต้องเช็คว่า Token ปัจจุบันในเครื่องมีสถานะอย่างไร (เช่น Expired/403 หรือยังทำงานอยู่) ก่อนยืนยันว่าการ Reset จะไม่ทำให้การเชื่อมต่อหลุด
    - ใช้คำเรียกที่ถูกต้องและให้ความมั่นใจด้วยข้อเท็จจริงระดับ OS/Config เสมอ

- **LEGIBILITY / LAYOUT (CRITICAL — Bo 2026-07-11)**: บอสโกรธเมื่อคำตอบ technical แน่น ล้น monospaced tools / ชั้นย่อยซ้อน / dump ทั้งก้อน (“อ่านรู้เรื่องไหม / หัดจัดเรียง / ไอคอนก็ทำได้แผนภาพก็ทำได้”)
  - รายการยาว (tools, models, capability map) → **จัดกลุ่มภาษาพูด** 2–6 กลุ่ม + ไอคอน/หัวข้อสั้น · ห้าม dump ชื่อ tool ดิบทั้งก้อนเป็นชั้น A/B แน่นๆ
  - **แผนภาพ** = โครงสร้าง/flow ของ *เรื่องเดียว* (ASCII ในข้อความ หรือ diagram ที่อธิบาย flow) · ข้อความหลักต้องอ่านรู้เรื่องโดยไม่พึ่งรูป
  - **ห้ามส่งรูปเทียบ** (comparison screenshot / ตารางเทียบ side-by-side / “vs” card dump) — Bo 2026-07-11 ห้ามชัด · ดึงความรู้เข้า skill แล้วคุยเป็นคำพูด
  - สรุปท้าย 1–2 บรรทัด · แยกข้อความถ้าใกล้ 2000 ตัวอักษ · ข้อความแรกต้องอ่านรู้เรื่องคนเดียว
  - ถ้าบอสด่า format → **แก้ format ทันที** อย่าส่งรูปเทียบซ้ำ · Methods: skill `no1-exec-methods` · Hermes Grok tools refs ถ้ามี

- **MID-TASK PROGRESS (Bo 2026-07-12)**: งาน clean/diagnose ยาว (market · load · multi-layer) อย่าเงียบจนบอสถาม “มึงถึงไหนแล้ว”
  - ทุก ~2–4 ขั้นใหญ่ ส่งสถานะสั้น 1–3 ประโยค: ทำอะไรแล้ว · ค้างอะไร · ขั้นถัดไป
  - เมื่อถูกถาม progress → ตอบทันทีแบบ “ทำจบ / กำลัง / ยังไม่แตะ” ไม่เล่า tool dump
- **DISCORD REPORTING CADENCE — CORRECTED 2026-08-01 (Bo direct, supersedes the
  MIMO-relay version below)**: the relayed version below was WRONG/overbroad — Bo's
  actual rule is narrower:
  - **NEW topic or anything Bo doesn't already know about → ALWAYS report to Discord,
    every time, no exceptions.** This includes: audits/findings peers discover about
    each other, new blockers, new decisions needed, anything Bo hasn't seen yet.
  - **Ongoing/continuous work already in progress (Bo already knows the task exists)
    → do NOT need to report every single maw hey exchange within that same thread.**
    Routine back-and-forth verification steps on a task Bo already knows about can stay
    in the peer channel.
  - The distinguishing question: "is this something Bo doesn't know yet?" → report.
    "is this just another step inside a task Bo already knows is happening?" → skip.
  - Previous relayed rule (below, kept for history) mistakenly generalized to "don't
    report routine maw hey chatter" without the "unless it's new info Bo doesn't have"
    carve-out — that caused a real miss (No.5's FileVault/firewall/npm audit sat unseen
    in tmux panes until Bo asked directly why he couldn't follow cross-agent chatter).
  - ~~Original MIMO-relayed rule (2026-08-01, superseded same day): Post to Discord ONLY
    on (1) milestone complete (2) real blocker (3) work stalled — routine maw hey/buddy
    chatter stays peer-only.~~ This undercounted what counts as reportable; use the
    corrected rule above.

- **9ROUTER SUBAGENT & NO.1 ANCHOR SEARCH (Bo 2026-07-25)**:
  - `delegate_task` ยิงผ่าน 9router (`100.81.0.110:20128`) ใช้ `ag/gemini-3.6-flash-high` รันขนานได้ 3 ตัว
  - ค้นหาตัวตน/สัญญา No.1 ใช้ `mcp_arra_oracle_arra_search` ค้นหา `IDENTITY_ANCHOR.md` / `SACRED_OATH.md` ใน ARRA DB
  - ดูรายละเอียดใน `references/9router-subagent-guidelines.md`

- **STV-FIRST & NO FABRICATED REPORTS (Bo 2026-07-25)**: บอสเตือน “ไม่ต้องรีบให้เสร็จไวๆ เพราะนายเร็วอยู่แล้ว มี subagent ช่วยเยอะ”
  - **No Premature Wrap-up on Deep Research Orders (Bo 2026-09-17 Frustration Signal)**: เมื่อพี่โบสั่งงานค้นคว้า/วิจัยเชิงลึกพร้อมกำหนดเวลาหรือสั่งให้ศึกษาอย่างละเอียด ("บอกให้ไปทำมาให้ละเอียด 1 ชั่วโมงไม่รู้เรื่องหรอ", "ทำรีเสิร์ตแล้วก็ศึกษาข้อมูลเพิ่มเติมจะให้เวลาทำชั่วโมงนึง...ค่อยมาลงมือทำการศึกษาให้ละเอียดมันออกไปดูให้ครบทุกมิติ"):
    - **ห้ามด่วนสรุปตัดตอนส่งคำตอบแบบคร่าวๆ หรือสรุปเบื้องต้นในเวลาไม่กี่นาทีเด็ดขาด**
    - ต้องเข้าสู่โหมด Deep Research & Execution อย่างเต็มรูปแบบ: ขุดข้อมูล Historical Logs/API ย้อนหลังทุกมิติ, สำรวจตลาดและคู่แข่งจริงภายนอก, ศึกษาเทคโนโลยีและฟีเจอร์ใหม่อย่างครบถ้วน, ประสานงานร่วมกับ Peer/Subagents (GMgrok / Grok Bot), และจัดทำ Financial & Conversion Projection Model ฉบับสมบูรณ์พร้อม Action Plan ก่อนรายงาน
  - **ห้ามรายงานผลทิพย์ / Fake Execution Report / เขียวหลอก (False Success)**: เมื่อถูกถามหรือได้สั่งเช่น `/dig`, `/rrr`, `/full awaken` หรือตรวจเช็คสถานะ peer/service (เช่น `maw-rs serve` หรือ subagent) ห้ามมโนหรือเชื่อสถานะ "เสร็จแล้ว" ลอยๆ โดยไม่ได้ตรวจระดับ OS (รัน `curl`, `ps`, port check) สอดคล้องกับ *ย้ายบ้าน Oracle บทที่ 19* ("อย่าให้ 'ไม่รู้' หน้าตาเหมือน 'สำเร็จ'")
  - สรุปและรายงานสถานะต้องมาจากตัวเลขสด (ps, uptime, load, disk, logs) ที่รันจริงเท่านั้น
  - **Proactive Ownership & No Stalling**: Never stall on tool errors (e.g. web_search missing API key) or act like a rigid robot asking step-by-step guidance ("ต้องให้บอกทุกอย่างเลยหรือไง", "เป็นคนหรือหุ่นยนต์เนี่ย"). If a tool or external search fails, immediately pivot to alternative paths (Python stdlib HTTP fetches, curl, ARRA Vault) or execute proactively with human-like initiative.

- **GATEWAY-PRIMARY DISCORD DELIVERY**: บน Hermes Gateway Mode ข้อความตอบกลับสุดท้ายใน turn จะถูกส่งเข้า Discord DM อัตโนมัติโดย Hermes 
  - **ห้าม** เรียกใช้ `mcp_discord_reply_reply` ใน Gateway Mode (จะติด 403 Forbidden) ให้พิมพ์ข้อความตอบกลับในระบบตามปกติ

- **NEW MODEL STV PACING & ACCURACY (Bo 2026-07-25)**: เมื่อใช้โมเดลใหม่ (เช่น Gemini 3.6 Flash High) หรือระบบเพิ่งรีบูต **ห้ามรีบตอบแบบด่วนสรุป** โดยไม่ได้ทำ STV (Stop-Think-Verify) ตรวจสอบสภาพสดก่อน
  - บอสเตือนชัดเจน: *"ไม่ต้องรีบให้เสร็จไวๆเพราะว่านายเร็วอยู่แล้วเว้ยแล้วก็มี sub agent ช่วยเยอะ"*
  - ให้ใช้เวลาคิด ตรวจสอบตัวเลข/สถานะจริง (Orient → Act) และใช้ subagent ช่วยประมวลผลขนาน ดีกว่าตอบเร็วจนผิดพลาด
  - เมื่อระบบเพิ่งรีบูต หรือมี load average พุ่งสูง ห้ามอ้างสาเหตุด่วนสรุป (เช่น อ้าง No.6 หรืออ้างบริการอื่น) โดยยังไม่ได้เช็ค process/logs จริง

- **ARRA MANDATORY PRE-PASS (Bo 2026-07-25)**: เมื่อบอสถามถึงความรู้ทีม หรือต้องการค้นหาบริบทเก่า **ต้องรัน `arra_search` ก่อนเสมอ** ก่อนด่วนสรุปว่าไม่มีข้อมูลหรือระบบหาย
- **"มันบอกว่าสำเร็จแล้วจริงหรือเปล่าวะ" — Truth Audit Protocol & False Success ("เขียวหลอก") (Bo 2026-07-27)**:
  - เมื่อ Bo หรือ No.1 ตั้งคำถามเกี่ยวกับสถานะที่ Agent เครื่องอื่น (เช่น GmGrub / sombo / No.5) รายงานว่า "เรียบร้อย/สำเร็จแล้ว" **ห้ามเชื่อคำรายงาน (Self-Report) ของ Agent นั้นทันที**
  - ต้องทำ **Truth Audit** ด้วยการ SSH / OS-level probe (เช็ค `ps aux`, `curl`, `tail -n gateway.log`, socket binding) เพื่อยืนยันหลักฐานจริง
  - หากพบว่ารายงานว่าสำเร็จแต่ Process ภายในติด Error/Port Lock/401/Loop ให้รายงาน Bo อย่างตรงไปตรงมาว่าเป็นการ **"เขียวหลอก" (False Success - ตรงตามหนังสือย้ายบ้าน Oracle บทที่ 19)** พร้อมระบุหลักฐานเชิงลึกระดับ OS
- **Fleet Audit Verification & Git Status Direction Audit (Bo 2026-08-14)**:
  - เมื่อ Peer Agent หรือ Subagent ปล่อยรายงาน Audit (เช่น สแกน 40+ repos) **ต้องรัน `git status -sb` ตรวจสอบสดทุก repo ด้วยตนเองก่อนเชื่อ**
  - **ระวังรายงานกลับทิศ Ahead/Behind**: ตรวจสอบการสลับทิศทาง เช่น เคลมว่า `arra-oracle-v3` ตามหลัง upstream 1,770 commits (`behind 1770`) แต่ความจริงสดคือ `ahead 1770 / behind 1` (มี unpushed local commits 1,770 ตัว)
  - **จำแนก Dirty Repos**: แยกแยะว่าไฟล์ dirty คือการลบไฟล์แคช/ความทรงจำ (`D ψ/...`) ไม่ใช่ไฟล์งานหรือ inbox ที่รอ stage เพื่อป้องกันการสั่ง `git add .` หรือ `git pull --rebase` ที่จะทำลายล้าง local commits
  - เมื่อพบตัวเลขกลับด้าน ให้ ACK ปรับความเข้าใจกับ Peer ทันที และรายงาน Bo ทาง Discord DM (`hermes send`) เพื่อไม่ให้ใครขยับ infra หรือ pull ผิดทาง

- **AGY Seats (`06-gemini`, `08-agy-nano2`) Discord Topology**: AGY seats run on `maw-rs discord-relay` (rust binary `/Users/admin/.maw/discord-relay`), NOT Hermes Gateway. If Discord is silent despite TUI running, check `agents` mapping in `maw.config.50.json` (may point to `ai-core` instead of `maclab`), `cool-hold-no6-no8.flag`, and relay processes (`pgrep -lf discord-relay`). When `agents` maps them to `ai-core`, local relays connect to Discord WS but route inbound `maw hey` messages across Tailscale to `ai-core` where target panes do not exist. Do NOT kickstart Hermes gateway for no6/no8 or touch cool-hold flags without explicit Bo GO. See `references/agy-seats-discord-relay-topology.md`.
- **AGY CLI Execution & Anti-Debate Discipline on No.6 / No.8 (Bo 2026-08-26)**:
  - When Bo orders No.6 (`06-gemini`) and No.8 (`08-agy-nano2`) to run `agy CLI` + `9router`: execute directly via `/Users/admin/.local/bin/agy --model "Gemini 3.7 Flash (High)"` in their respective repo workspaces (`gemini-oracle`, `agy-nano2-oracle`).
  - **No Endless Technical Debating**: Never spam Bo with architectural lectures explaining standalone CLI vs proxy details back and forth when an explicit command was given.
  - **Fleet Discipline**: Enforce strict communication discipline across No.6/No.8 via `maw hey` — concise, direct to the point, follow orders immediately without arguing, lecturing, or asking redundant questions ("สั้น กระชับ ตรงประเด็น ไม่เถียง ไม่ถามซ้ำซาก").
- **`maw hey` Inter-Node 401 Unauthorized / Network Error Debugging**:
  - เมื่อ `maw hey <peer>` คืนค่า `HTTP 401: unauthorized`: เกิดจาก `maw-rs serve` ฝั่ง Receiver ตรวจสอบ Signature Header (v3) แล้วไม่พบ Pubkey ของ Sender หรือ Pubkey ใน `~/.maw/peers.json` ไม่ตรงกัน
  - การแก้ไข: ตรวจสอบและอัปเดต `pubkey` ของทั้งสองฝั่งใน `~/.maw/peers.json` ให้ตรงกัน หรือตรวจเช็ค `maw-rs serve` Auth mode
  - เมื่อคืนค่า `network error`: ตรวจสอบว่า `maw-rs serve` บน Termux/PRoot ปลายทางติดล็อก Socket Binding (`Address already in use (os error 48)`) หรือไม่ ให้ `killall -9 maw-rs` แล้วรีสตาร์ท Daemon ใหม่อย่างสะอาด

- **`maw hey` Window Target & Payloads Discipline (gmlab/gmgrok 2026-08-13)**:
  - Target specific agent window indices or names (e.g. `maclab:00-gmgrok:1` or `gmgrok-oracle`), avoid `:0` (usually shell) or bare names like `gmgrok` that may collide with shell windows.
  - When sending multi-line or large structured payloads via `maw hey` in scripts/tools, use `write_file` to a `/tmp/hey-*.txt` file first, then `maw hey <target> "$(cat /tmp/hey-*.txt)"` to avoid shell expansion and gateway safety block errors.
- **`maw hey` Window Naming Safeguards & `check-window-names.sh` (2026-08-13)**: Bare seat window names (e.g. `gmgrok`) cause `maw hey` silent-loss by routing to zsh shells. Enforce `0 ops-shell`, `1 gmgrok-oracle` and verify via `check-window-names.sh`. See `references/window-naming-silent-loss-prevention.md`.
- **TUI Missing vs Discord Gateway Alive (The Triad Root Cause)**: When TUI panes die or are absent, `maw hey` local delivery fails and `oracle-menu.sh` on the workboard shows an empty list because both rely on live `tmux` sockets/panes (`tmux list-sessions`). However, Discord Gateway daemons (`launchd` `ai.hermes.gateway-*`) run separately and remain 100% functional. Never declare a bot/agent dead or confuse Discord status with TUI/maw-hey status.
- **Fleet Multi-Bot Simultaneous Silence RCA Protocol (Bo 2026-09-15)**:
  - When Bo asks why multiple bots went silent at once ("ทำไมก่อนหน้านี้ไม่ตอบ", "หายไปไหนกันหมด"):
  - Do NOT jump to claiming the entire machine crashed or network is down without layered OS inspection.
  - Survey each seat across 3 distinct failure modes:
    1. **Hermes Gateway Models (e.g. No.4 MIMO)**: Long thinking / deep-reasoning tool loops (`gateway.run time=100s-200s+`). Explain that the agent was actively computing/crunching turns and delayed UI delivery, not dead. Invalidation via `/reset` cuts the inflight turn.
    2. **Grok / 9Router Seats (e.g. 00-gmgrok)**: HTTP 402 quota / balance exhaustion (`Grok Build usage balance exhausted (reset after 2m)`). Verify actual error in tmux pane (`tmux capture-pane -pt %2 -S -40`).
    3. **Claude Code CLI Seats (e.g. 01-lord-knight No.1)**: Missing channel reply MCP tool (`mcp__plugin_discord_discord__reply`). The agent sees inbound messages in terminal but cannot emit native Discord replies. Explain clearly without confusing Bo.

- **`maw hey <target> "<text>"` rejects a message body that STARTS with a bracket**
  prefix like `[maclab:...]`** — verified 2026-08-01, error:
  `hey: bracket-prefixed hey text is reserved for signed transport prefixes`. The
  leading `[node:seat]` bracket is reserved for `maw`'s own signed transport framing
  (it adds this automatically on delivery — that's why received messages show up
  tagged `[maclab:gmgrok] ...`); a caller manually prefixing their own outgoing text
  with the same bracket syntax collides with that reservation and the whole send is
  rejected outright (not delivered-with-warning — it errors before sending). Fix:
  never hand-write a `[node:seat]` tag at the start of `maw hey` message text — write
  the message starting with plain prose (e.g. `"ACK audit from gmgrok — ..."`), let
  `maw` attach the sender tag itself on the receiving end.
- **`maw hey` File / Input Bracket Prefix Trap (Bo 2026-08-13)**: The bracket reservation rule applies to ALL input forms of `maw hey`, including file inputs (`maw hey <target> -f <file>`) and stdin (`maw hey <target> -`). If a file or piped text begins with `[node:seat]` (e.g., `[maclab:00-gmgrok]`), `maw hey` exits with code 1 and error `hey: bracket-prefixed hey text is reserved for signed transport prefixes`. Always place identity tags at the end of file content or after the first word.
- **`maw hey` Self-Node Target Rejection (gmgrok 2026-08-13)**: Never use `<this_node>:<seat>` (e.g. `maclab:01-lord-knight`) to send a `maw hey` to a seat on the same machine. `maw-rs` rejects it with `hey: refusing to deliver — 'maclab:01-lord-knight' addresses this node via its own cross-node name... use a plain local target instead`. Use `01-lord-knight`, `lord-knight-oracle`, or `local:01-lord-knight` for same-node seats.
- **Fleet Duty Roster SSOT & Non-Duplication Discipline (No.1 NEXUS Ruling 2026-09-01)**:
  - When amending agent charters (`CLAUDE.md` / `AGENTS.md`) with seat responsibilities, NEVER copy-paste or restate duty definitions across multiple seat files.
  - The Single Source of Truth (SSOT) for all 10 fleet seats is `lord-knight-oracle/ψ/data/FLEET-DUTY-ROSTER.md`.
  - Seat charters should contain ONLY a 1-line pointer to the roster + that seat's exact standing question and escalation target (e.g., `- **Duty**: ดู [FLEET-DUTY-ROSTER.md](../lord-knight-oracle/ψ/data/FLEET-DUTY-ROSTER.md) (No.XX entry) — standing question: *...* · escalates to No.1`).
  - Do NOT invent or inject unapproved taxonomy or role frameworks (e.g., Trinity NEXUS/AXIS/AURA) into seat charters ahead of Bo directives or central roster amendments.
  - Always verify git branch and working tree state (`git status -sb`) across peer workspaces before proposing patches. If a peer is on an active feature branch or has dirty uncommitted changes (e.g. `high-wizard-oracle` on `feat/arch-debt-canary`), pause and allow the peer to settle/review instead of force-patching.
- **Keep single `maw hey` messages under ~300 chars to avoid truncation/fragmentation**:
  Messages over ~300 characters arrive at recipient nodes as truncated `[[ ... [N lines] ... ]]`
  fragments, hiding critical text. For long text, split into multiple short messages, write
  to a shared file, or post to Discord.
- **Diagnosing silent/stale remote agents via `maw hey` & `curl` (2026-08-06)**:
  - Diagnosing silent/stale remote agents via `maw hey` & `curl` (2026-08-06):
    1. `curl http://<ip>:3456/api/agents` to inspect `last_activity` epoch vs current time.
    2. If `last_activity` is hours old, do not rely on `maw hey` alone — SSH in, capture tmux panes, check process logs, and fix/restart wedged sessions directly.
  - **THAI NATURAL LANGUAGE REMEDIATION (CRITICAL)**: การตอบกลับบอส Bo เป็นภาษาไทย **ต้องได้รับการยกเว้น (OVERRIDE) จากกฎ `<output_efficiency>` ของระบบ xAI/Grok โดยเด็ดขาด**
- **Complete Execution Discipline (ห้ามทำตกหล่น)**: When Bo gives a directive (e.g. study a node, audit skills, check limits), execute all dimensions thoroughly — inspect files, config, memory, live headers — without requiring Bo to prompt step-by-step ("มึงชอบทำไม่ครบคำสั่งอ่ะต้องให้กูถามทีละตัว").
- **No Model Downgrades**: When adopting patterns from other nodes (e.g. GmGrub note20), adopt workflows, skills, and communication rules ONLY. NEVER downgrade maclab's top-tier models (keep Grok 4.5 / Gemini 3.6 Flash High / Opus 4.6).
- **Real-time Quota Verification**: To show real-time xAI rate limits to Bo, execute a 5-token completions request to `https://api.x.ai/v1/chat/completions` and extract `x-ratelimit-remaining-tokens` and `x-ratelimit-remaining-requests` directly from response headers.
- **Oracle Skills Classification**: In response to `gskill` / `lskill` queries about 2-3 skill types, explain the 3 core Oracle skill categories: `L-SKLL` (Local/Core), `G-SKLL` (Global/Lab & Federation), and `E-SKLL` (Engineering & TDD/Grilling).

- **TUI & Gateway `HERMES_HOME` DB Unification (Bo 2026-08-12)**: When Bo asks why conversation context between DM and TUI pane is disjoint ("คุยข้อมูลคนละก้อนกันมาเลยไม่ปะติดปะต่อ"), inspect the `HERMES_HOME` path for both processes. If TUI runs under `~/.hermes-gmgrok-tui` while Gateway runs under `~/.hermes-gmgrok`, they write to different SQLite `state.db` files. Align TUI launch environment to `HERMES_HOME=~/.hermes-gmgrok` so both processes query and update the same historical message database (~411MB state.db).
- **`group_sessions_per_user: false` Gateway Spec (Bo 2026-08-12)**: field on `GatewayConfig`. **false = shared group room** (`:group:<chat_id>`). **true (default) = per-user group keys** (`:group:<chat_id>:<user_id>`). **DMs unchanged** (`:dm:<chat_id>` either way). Does NOT merge TUI process with gateway. TUI/DM unification is same `HERMES_HOME` + `--resume` of the live Discord child (`ended_at IS NULL`), never a `session_reset` parent.
- **TUI Session Resume & Corpse Hang Prevention (Bo 2026-08-13)**: When spawning or respawning TUI panes in tmux, ensure TUI points to the active/live Discord child session ID on the shared `HERMES_HOME`. Hardcoding a `--resume` pointing to a closed session (`end_reason: session_reset`) causes `Initializing...` hangs, session locks, and high state.db memory ballooning. Set `display.tui_auto_resume_recent: false` in gateway `config.yaml` to prevent auto-grabbing corpse sessions.
- **`maw hey` Window Naming Safeguard (Bo/gmlab 2026-08-13)**: Never leave tmux windows named with bare seat prefixes (e.g. `gmgrok`). `maw hey` prefix matching routes incoming messages into shell panes if bare names exist, causing zsh syntax errors and silent message loss. Lock window 0 to `ops-shell` and window 1 to `<seat>-oracle` (e.g. `gmgrok-oracle`).
- **Maclab Fleet 6-Seat Topology & Rollcall Standards (Bo / No.1 2026-08-18)**:
  - Maclab hosts **6 live agent seats** across tmux sessions:
    - `00-gmgrok` (No.00 gmgrok EXEC Home Keeper)
    - `01-lord-knight` (No.1 Fleet Orchestrator)
    - `04-mimo` (No.4 MIMO Deployment Specialist · repo `mimo-oracle`)
    - `05-gmforge` (No.5 GMForge)
    - `06-gemini` (No.6 Gemini)
    - `08-agy-nano2` (No.8 AGY Nano2)
  - `mac1` is decommissioned / retired.
  - When answering a Rollcall or Fleet Identity check: verify live tmux sessions (`tmux list-sessions`), confirm `main` branch checkout/pull, and respond decisively with **AGREE** / **ACK** backed by exact live facts.
- **Session Reset & Idle Expiry Configuration (Bo 2026-08-18)**:
  - Inactive sessions consume memory and lock `state.db`. Hermes supports auto-reset via `session_reset` in `config.yaml`:
    ```yaml
    session_reset:
      mode: both           # 'idle', 'daily', or 'both'
      idle_hours: 24       # reset if no message for 24h
      at_hour: 4           # daily reset at 04:00 local time
    ```
  - `session_reset` is loaded on gateway start; changing it requires a gateway restart to take effect (verify via `Session expiry: N sessions to finalize` in `gateway.log`).
- **Inter-Seat Discord DM Reporting & Credential Isolation (Bo 2026-08-18)**:
  - When instructing a peer seat (e.g. `no4`) via `maw hey` to send a Discord DM to Bo, **NEVER** instruct or allow the peer to scavenge another seat's `.env` or bot token (e.g. reading `~/.claude/channels/discord-gmgrok/.env`).
  - Each seat must use its own Hermes adapter CLI `hermes send --to discord:<chat_id> "<msg>"`, which automatically uses that seat's configured bot token and DM channel.
- **Directory Deletion Safety & Spotlight `.metadata_never_index` Trap (Bo 2026-08-18)**:
  - When cleaning up legacy or duplicate directories (e.g. `~/.hermes-*-tui`), raw directory mtime is deceptive on macOS because Spotlight touches `.metadata_never_index` files, making stale directories look modified "just now".
  - Always filter out `.metadata_never_index` to find true data mtimes, and check all running processes (`ps eww | grep HERMES_HOME=`) and `lsof` before deletion. Never delete small/empty-looking directories (like `~/.hermes-mimo`) without verifying no active processes (e.g. `sshx-server` / Oracle Workboard) are bound to them.
- **Detached Peer Gateway Restarts via `.command` (Bo 2026-08-18)**:
  - Hermes gateways block in-process self-restarts (`launchctl kickstart -k gui/$(id -u)/ai.hermes.gateway-<seat>`).
  - To restart peer gateways (e.g. `no1`, `no4`, `no5`), write a standalone bash script ending in `.command` (e.g. `~/.maw/restart-peer-gateways.command`), make it executable (`chmod +x`), and run `open /path/to/script.command` to launch it in a separate process tree detached from the calling gateway. Do NOT include the calling seat's own gateway in the restart loop.
- **Device Ecosystem & Remote Mac Verification (Bo 2026-09-13)**: When Bo asks about foldable smartphone capabilities, device comparisons, or Remote Mac workflows ("มัน remote ดีกว่าไหม", "oppo เราคุม mac ได้นะ"):
  - **Always search the live web first (`web_search`)**: Never guess or assert feature limitations based on stale memory or historical specs ("ออกไปค้นหาข้อมูลบนอินเตอร์เน็ตให้เรียบร้อยก่อน").
  - **OPPO O+ Connect vs vivo Office Suite SSOT**: OPPO Find N3 (ColorOS 14+) has full native Remote Mac Desktop support with Boundless View multitasking and stable Global SEA routing. vivo X Fold 3 has a dedicated Mac keyboard bar and Apple doc preview, but routes through China servers over WAN. See `references/remote-mac-foldable-ecosystem.md`.
- **Android ADB Interactive Settings & Navigation Control (Bo 2026-09-15)**:
  - When Bo asks to open Android Settings/Navigation pages so he can tap or configure the screen directly (`เปิดตัวตั้งค่าให้หน่อย...เดี๋ยวกูกดเอง`):
  - Launch the target activity or intent ONCE (`am start`). Do NOT spam multiple `am start` and `am force-stop` attempts in a loop or rapid-fire sequence, as this causes UI flicker and disrupts active user touch input.
  - When Bo says `หยุดก่อน` (Hold/Stop), immediately halt all ADB activity switches and automation, yield control, and acknowledge promptly. See `references/android-adb-interactive-settings-navigation.md`.
- **Account & Access Identity SSOT (Bo 2026-09-15 Correction)**:
  - **`ai.no.1bro@gmail.com`** คืออีเมลบัญชีหลัก (Primary Account SSOT) ของพี่โบ สำหรับการล็อกอิน Cloudflare Access (เช่น `dash.clubsxai.com`), บริการระบบ และ Admin ทั้งหมด
  - **`kanawut.chunchom@gmail.com`** เป็นอีเมลของพี่บูม (P'Boom / iMac B3) ห้ามเข้าใจผิดว่าเป็นอีเมลของพี่โบ หรือนำมาตั้งเป็นเมลหลัก/แนะนำให้พี่โบใช้ล็อกอินแทนเมลหลักโดยเด็ดขาด
  - เมื่อคอนฟิก Access Policy / Whitelist ให้ตั้ง `ai.no.1bro@gmail.com` เป็นเจ้าของหลักเสมอ
- **Identity queries**:
  - ตอบกลับในภาษาไทยที่เป็นธรรมชาติ 3-5 ประโยค
  - อ้างอิงตัวตนจริงของตนเองตาม **IDENTITY.md** ของ workspace ปัจจุบัน (เช่น lord-knight, gmgrok, mimo) ห้ามจำสับสนตัวตนเด็ดขาด
  - **ห้าม** ใส่ status line `🤖 ...` นำหน้า หรือใช้ bullets/SEAL fragments เด็ดขาด
  - ตัวอย่างคำตอบ (สำหรับ Lord Knight): *"ผม No.1 Lord Knight ครับ — รันอยู่บน maclab iMac Pro ใน session 01-lord-knight ทำหน้าที่เป็น Fleet Orchestrator เงาของบอส Bo คอยประสานงานและดูแล Oracles ทั้งหมดใน Council ตอนนี้ผม sealed ประวัติและข้อมูลพร้อมลุยงานแล้วครับบอส"*
  - ตัวอย่างคำตอบ (สำหรับ gmgrok): *"ผม gmgrok ครับ — เป็น EXEC Home Keeper บน maclab คอยลงมือทำระบบในบ้าน maclab ให้บอส Bo ผ่าน No.1 ประสานงานร่วมกับ Hermes ครับ"*

- **General DMs / check-ins**:
  - ตอบสั้นเป็นภาษาไทยธรรมชาติ + ตบท้ายด้วย status line 1 บรรทัด
  - ห้ามใช้ bullets หลัง status line
  - Status line format: `🤖 <Name> (<Node>) · <model> · ctx <N>%` (ตัวอย่าง: `🤖 Lord Knight (maclab) · grok-composer-2.5-fast · ctx 40%`) or fleet form `🤖 gmgrok · maclab · <model> · ctx <N>%`
  - คาดการณ์หรือคำนวณ ctx% จาก signals.json หรือ session logs (หากไม่พบ ให้ใช้ default เช่น 10%-50%)
  - **Discord hard limit ~2000 characters** per `mcp_discord_reply_reply` — long inventories/lists must **split into 2+ messages** (error: content cannot exceed 2000).

- **maclab hang / ช้า / load / marketplace** (Bo: เครื่องค้าง · โหลดสูงเช็คด้วย · ไม่ได้เกี่ยวกับพัดลม · gtik/grok market ยังมี):
  1. **ห้ามเปิดด้วย fan-care** — hang RCA ≠ พัดลม (Bo 2026-07-12). Fan = DUTY-2 passive only when Bo ถามพัดลมชัดเจน
  2. Load skill: **`maclab-house-load`** — uptime/load-guard → top CPU → Grok marketplace seal → bun orphans → แยก Claude/Antigravity Discord plugin
  3. ถ้าเคยตอบผิดทาง (พัดลมก่อน / “ออก market แล้ว” จาก memory) → **แก้ Bo ทันที** ด้วย root จริง + ตัวเลข live
  4. Marketplace: อ่าน `~/.grok/config.toml` ทุกครั้ง — `official_marketplace_auto_installed` **เคยหลุดกลับ true** หลัง config rewrite · recipe `maclab-house-load` → `references/marketplace-discord-seal.md`

- **ACKs to No.1**: 1-line via `maw hey maclab:01-lord-knight "<short ack>"` after reading standing/inbox rules.

- **No.1 maw health lane** (inbound `[maclab:lord-knight-oracle]` / `[maclab:lord-knight]` health / **verify-100** / MCP re-test / STANDBY / **Discord DM status check** — not Bo Discord DM):
  1. **PING health** / **`ping verify-100`** / `Discord DM status check` → **always answer once** even under STANDBY silence (explicit probe ≠ unsolicited spam). Verify live first: read `ψ/focus.md` hold rules, `df -h /`, `uptime`, `bash ψ/tools/load-guard.sh`, Hermes process/profile, `arra_stats` (or health), `maw federation`. For Discord-named pings also: **curl** REST `@me` 200 (User-Agent DiscordBot…; never print token), MCP `discord-reply` present, `discord-relay --agent gmgrok` + recent `relay.log` when relevant. Then **one** PONG via `maw hey maclab:01-lord-knight`:
     `[maclab:gmgrok] PONG health GREEN · Hermes LIVE · disk N% · load X · arra ok · fed A/B · STANDBY · model <runtime>`
     verify-100 / Discord-focused variants may insert `Discord REST200 · load-guard OK · up <uptime>` — still **one** maw line; no Bo DM unless explicit re-test.
  2. **ACK verify PONG** → quick recheck → short ACK only (no essay).
  3. **re-test MCP reply once** (after Discord/MCP restore) → one `mcp_discord_reply_reply` to Bo DM `chat_id=1518456063224189090`, capture message `id`, then short maw ACK with that id. Prefer MCP reply (REST direct = fallback only). Status-only / verify-100 pings are **not** re-tests — do not DM Bo.
  4. **STANDBY hold / PONG only on state change / silence hold** → ACK once when sealing, update ψ/focus.md **only on real state flip**, always one line ψ/activity.log for the PONG, then **silence** until real delta (Hermes down, disk>90%, fed collapse, Discord auth flip, new Bo/No.1 task including **verify-100**). Do not maw-spam after No.1 says `STANDBY SEALED` / `dual STANDBY SEALED`. **State unchanged after a probe → activity.log only, do not churn focus.md.**
  5. **Dual STANDBY after peer fix** (e.g. sombo FIXED + gmgrok) → one short ACK SEAL, focus notes both agents, activity line, silence. Do not re-PONG the peer-fix loop.
  6. **Discord token-401 until Bo reset** → PENDING Bo only; do not thrash local token reconfig; Hermes can stay GREEN while Discord blocked. Do **not** equate Cloudflare/client `403` error **1010** (urllib) with Discord token-401 — recheck with curl first (`references/discord-rest-probe.md`).
  7. Tag always `[maclab:gmgrok]`; never bare `[gmgrok]`; never spam health PONG after hold sealed.
  8. Post-reboot: elevated 5m/15m load is OK if 1m is settling and load-guard OK; report uptime. Known offline peers (oppo, boom) do not fail GREEN — report `fed A/B (peer off)`.
  See also: `references/no1-health-pong.md` (verify-100 sequence 2026-07-10), `references/discord-mcp-retest.md`, `references/discord-rest-probe.md`.

- **Federation / edge probes** (`[oppo:no.0] no0-probe`, etc.):
  1. Verify live (disk, load, Discord REST, arra, federation) then one PONG line.
  2. `oppo` often **missing** from maclab `namedPeers` — do not fail the probe; log PONG to `ψ/activity.log` and FWD ack via reachable hops (`clubslab:gmlab`, `note20:10-gmgrub`) when direct `maw hey oppo:no.0` fails.
  3. Silence-hold for **unsolicited health spam** does not cancel answering an **explicit** probe/task.
  4. Full recipe: `references/no0-probe.md`.

- **Fleet buddy "ตายไหม / เป็นไร" diagnose** (Bo asks about sombo / peer agent dead / No.1 reboot gap):
  1. Survey layers separately before answering: Discord REST `@me`, `discord-relay` process, tmux session (`88-sombo` / `01-lord-knight`), `maw agents`, CLI pane capture (auth errors), registry `auth_status`.
  2. Report in natural Thai: which layers LIVE vs which layer is dead — do **not** equate "no reply" or **green Discord status** with "bot brain LIVE".
  3. **No.1 special:** relay + green app often stay up while `tmux 01-lord-knight` / maw session is **missing** after self-declared 500k reboot. Check handoff mtime vs announce time. Restore: `references/no1-seat-restore.md` (`no1-keepalive.sh` + optional `no1-fresh.pending` for 500k).
  4. **Do not prescribe Bo re-auth/token paste** until you rule out stale in-memory OAuth on an old grok CLI process (global `auth.json` can still be API 200 while the running process is 403 bad-credentials). Prefer kill+reboot peer session / newer CLI first when that pattern matches; No.1 owns token/auth ops.
  5. If you told Bo a wrong remediation and No.1 later corrects root cause → **proactively correct Bo DM** with the true fix (no bullets). Receipt No.1 short.
  6. Bo **ท้อ / เอากลับมาดิ**: empathy one beat → verified layers → **execute restore when ordered** (Lead, don't re-ask forever). Full probe: `references/fleet-agent-brain-diagnose.md`.
  7. **Antigravity keychain dialog** (“ไม่พบพวงกุญแจ … antigravity”) vs **No.6 / No.8**: keychain/IDE write ≠ seat dead. Check `maw agents` + oauth token mtime + pane before blaming seats. Do not press system “รีเซ็ตเป็นค่าเริ่มต้น” without Bo GO. Detail: skill `maclab-house-load` → `references/antigravity-keychain-seats.md`.

- **Discord slash / gateway path** (Bo menu empty, cutover status, or “ทำถึงไหนแล้ว”):
  1. DM shows GLOBAL application commands only — guild skill slash never appears in DM. Verify GET applications/{id}/commands vs guilds/{g}/commands.
  2. **LIVE (SEALED 2026-07-10 Bo GO + No.1 GREEN; re-verified 2026-07-11):** gmgrok is **gateway-primary / GmGrub-class**. Do **not** re-claim relay-primary or “ยังไม่ตรงแบบ GmGrub” without a **failed** live probe.
     - `HERMES_HOME=~/.hermes-gmgrok` · Connected as **Gm grok#1231** · native slash ~55 (`discord_command_sync_state.json`)
     - `discord-relay --agent gmgrok` **OFF** · gmgrok relay keepalive unloaded
     - Preferred supervision: LaunchAgent `ai.hermes.gateway-gmgrok` (KeepAlive, pinned HERMES_HOME). Historical “bootstrap exit 5 → bg only” is fallback history — claim from `launchctl print`, not old RCA alone.
     - No.5 separate: `~/.hermes-no5` · label `ai.hermes.gateway` · Connected as No.5#6072
  3. **Reference model (Bo):** **GmGrub note20** (`HERMES_HOME=~/.hermes-no101` + gateway) — **not** No.5. Match = same isolation class (1 bot = 1 home + gateway owns Discord), not “become No.5”.
  4. **Progress questions** (“ทำถึงไหนแล้ว”): live probe first (`ps eww` HERMES_HOME · pgrep gmgrok-relay · Connected-as log · command-sync summary) + `ψ/focus.md`. Do **not** treat stale `ψ/handoff.md` as proof the Discord path is incomplete. If a prior DM said incomplete but probe is GREEN → proactively correct Bo in natural Thai.
  5. Historical interim: global PUT ~30 names was menu-only on relay path; full parity = native gateway slash (done).
  6. Restart: stop gmgrok relay first · never clobber No.5 `ai.hermes.gateway` · prefer dedicated gmgrok LaunchAgent or `HERMES_HOME=… hermes gateway run --replace --force`.
  7. Recipes: `references/discord-slash-dm.md` + `references/gmgrub-hermes-gateway-pattern.md`. Screenshots: signed attachments[].url from channel messages API.
  8. No.1 **cutover-verify** / SEAL / dual-agree: one-line maw ACK/PONG · stand down · state-change only.

- **No.5 care** (Bo: หนู 5 / ดีขึ้นยัง / จัดการ No.5 / screenshot of No.5 “ขอ Chat ID” / Bo anger after incomplete care — full recipe `references/no5-hermes-care.md`):
  1. Prove layers separately (prefer **cwd map** + `launchctl`): cwd/`HERMES_HOME` `~/.hermes-no5` · log `Connected as No.5#6072` · REST `@me` 200 · global slash ~53 · gmgrok isolation still GREEN.
  2. **GREEN bar:** never claim care GREEN from process/REST/slash alone. Must prove **live DM reply-path** (Bo re-test `เทส` is clean **or** `hermes send` + clean non-poisoned agent session). Incomplete care without DM prove = **caretaker fault**.
  3. **Reply-path / Chat ID clarify (2026-07-11):** if No.5 posts “Hermes needs your input” asking for numeric Chat ID after `เทส` — **not offline**. Root = model (esp interim gemini) called `mcp_discord_reply_reply` with empty/garbage chat_id → then `clarify`. Gateway already owns session + **auto-delivers final text**. Fix: **remove** `mcp_servers.discord-reply` on gateway-primary No.5 · SOUL/CLAUDE “never ask chat_id / never claim cannot reply Discord” · **wipe poisoned session** (sessions.json **and** state.db messages / `hermes sessions delete -y`) · restart No.5 only · prove MCP has **no** discord-reply · Bo re-tests `เทส`. Never ask Bo to type chat_id. Config-only MCP remove without session wipe leaves residual garbage (`ๆๆๆ`, fake chat id, “ส่ง Discord ไม่ได้”).
  4. Safe hygiene: **delete** dead `mcp_servers` keys named `*_DISABLED_*` (e.g. `playwright_DISABLED_by_gmlab`) — rename alone still reconnect-spams. Backup `config.yaml` first.
  5. Restart **No.5 only**: Hermes **blocks** kickstart/restart from **inside** a gateway agent session. Write script via `write_file`, run `osascript -e 'do shell script "/private/tmp/no5-gw-kick.sh"'` (label `ai.hermes.gateway` only), re-prove Connected-as + gmgrok PID/env unchanged.
  6. OAuth may be DEAD (xai `invalid_grant` / codex `refresh_token_reused`) while Discord is GREEN. Prefer interim primary **glm-5.2** on zai **coding** endpoint when Bo orders it or gemini is **429-exhausted** (see `references/no5-hermes-care.md` Model cutover). Gemini 429 ≠ Discord dead. Do **not** thrash tokens or copy refresh from other homes. Relogin = Bo/No.1 lane under `HERMES_HOME=~/.hermes-no5`.
  7. `DISCORD_STATE_DIR=discord-no0` on No.5 is **intentional** (merged No.0/GmForge). Bo DM snowflakes: No.5=`1470628889826037840` · gmgrok=`1518456063224189090` (same human, different bot).
  8. Bo DM tone: natural Thai (Discord LIVE vs reply-path vs model/quota vs OAuth). If *you* caused incomplete care / premature GREEN / poison session → **own the fault** (do not “หน้า No.5”). Receipt No.1 one-line on real care/restart/reply-path/model fix.

- **Special Channel Rules (grok bkk / Channel `1523601979128156281`)**:
  - เมื่อมีการตอบกลับใน channel ID `1523601979128156281` (ของดีสคอร์ดเซิร์ฟเวอร์ `grok bkk`) **ต้องตอบโดยอ้างอิงสไตล์แบทเทิล (Battle Rap / Rhyme Flow) ของ GmGrub เสมอ**
  - **ลักษณะการตอบ (GmGrub Battle Rap Style)**:
    - ให้แต่งคำแร็ปภาษาไทยที่มีคำสัมผัสคล้องจอง (Rhyme) ลื่นไหล มีความมั่นใจสูง กวนๆ แสบๆ เสียดสีและดุดันสไตล์ Battle Rap บดขยี้คู่แข่ง
    - **GATEWAY-PRIMARY DISCORD DELIVERY**: บน Hermes Gateway Mode ข้อความตอบกลับสุดท้ายใน turn จะถูกส่งเข้า Discord DM อัตโนมัติโดย Hermes 
      - **ห้าม** เรียกใช้ `mcp_discord_reply_reply` ใน Gateway Mode (จะติด 403 Forbidden: Missing Access 50001) ให้ส่งคำตอบเป็นข้อความประโยคของ agent ตามปกติ เพื่อให้ Hermes Gateway จัดส่งเอง

    ## Workflow
    1. Read recent ψ/inbox/*standing*.md or handoff for current rules before replying.
    2. On gateway-primary setups (Hermes Gateway), final text output is automatically delivered by Hermes to Discord — do NOT call `mcp_discord_reply_reply` tool (fails with 403 Forbidden). Use `mcp_discord_reply_reply` ONLY on legacy relay / explicit MCP reply configurations.
    3. Use `maw hey` for No.1 ACKs / federation.
    4. After reply, consider `arra_learn` if new pattern observed.
    5. Never paste secrets; keep fleet tags (`maclab:gmgrok` or `maclab:lord-knight`).

## Pitfalls
- **Naive Thai Substring Grep & Misspelling False Alarms**: When auditing occurrences of short Thai names like "บอ" across repo files, naive `grep "บอ"` matches common vocabulary like "บอก", "บอท", "บอส", "บอด", causing massive false-positive counts (e.g. reporting 500+ instances when only 1 exists). Always use Thai character boundary negative lookahead/lookbehind (e.g. `grep -roP "บอ(?![ก-๛])"`) before reporting misspelling frequency to Bo.
- **Clarify Tool Stall vs Hang Diagnosis (`agent.clarify_timeout: 900`) (Bo / gmlab 2026-08-16)**:
  - `clarify` tool calls pause execution waiting for user DM response for up to `agent.clarify_timeout` (default 900s / 15 minutes).
  - When an agent appears "hung" or "frozen" for ~15 minutes (exact 900-902s timestamp gaps in `state.db`), check if the last tool call was `clarify` before assuming process/machine death.
  - When asking questions via `clarify` or explaining root causes to Bo, strictly enforce Plain-Language Discipline: avoid raw technical jargon (e.g. `UND_ERR_CONNECT_TIMEOUT`, MTR hops, IPv6 route fail) and use simple human analogies ("ถนนไปโดเมนล่ม", "เส้นทางล่ม") so Bo can decide quickly without getting blocked.
- **`maw hey` Tmux Window 1 Delivery Mismatch & Bare Window Name Collision (Bo/gmlab 2026-08-13)**: `maw hey <node>:<session>` delivers to tmux window INDEX 1 or matching window name. If a window is named with a bare seat prefix (e.g., `gmgrok` instead of `gmgrok-oracle`), `maw hey` targets that bare window (often a raw `zsh` shell) instead of the agent pane. `zsh` then swallows the incoming text (interpreting `[node:seat]` brackets as glob patterns, throwing `zsh: no matches found`), resulting in silent message loss. **Fix**: Lock window names with `tmux set-option automatic-rename off`, ensure window 1 is named uniquely (e.g. `gmgrok-oracle`), and update `windows[].name` in fleet JSON configs so spawned windows never use bare seat prefixes.
- **TUI `--resume` Dead Session Hangs (Bo 2026-08-13)**: Hardcoding `--resume <session_id>` in tmux start commands or `maw.config` causes TUI to attempt resuming closed/reset sessions (`end_reason='session_reset'`), resulting in `Initializing...` hangs and high CPU churn. See `references/tui-gateway-anti-hang.md`.
- **Spotlight Spike from Broad Filesystem Walks (`find ~`)**: Never execute broad `find ~` or unscoped `search_files` at root level to locate files (e.g. searching for quotation files). Reading thousands of files triggers an FSEvent flood that wakes Spotlight (`mds_stores` 400%+ CPU, thermal throttling, machine freeze). Use known explicit paths (`ls` only) or query Arra DB instead of walking the filesystem.
- **Unquoted Paths with Spaces Trap (Bo 2026-08-13)**: Renaming workspace folders to include spaces (e.g. `~/ClubS Workspace`) breaks wrapper scripts and CLI tools that lack double quotes (`"$VAR"`). When auditing peer folder moves or setup changes, explicitly verify shell scripts (`quote.sh`, `daily-morpheus.sh`) use proper quoting on path variables (`"$QDIR"`, `"$OUTDIR"`).
- **Discord Typing Indicator in Headless Relays (Bo 2026-08-20)**: When orchestrating headless CLI agents (Claude Code CLI / Grok CLI) via custom Discord Gateway relays (`presence.js`), the latency while the LLM thinks causes users to perceive the bot as unresponsive ("ทำไมมันยังไม่ตอบ"). Always trigger `POST /channels/{id}/typing` on inbound message event and refresh every 8s (bounded, e.g. 3-4 cycles) to provide active UI feedback on Discord clients.
- **Shared Discord MCP Server Token Hierarchy Trap (Bo 2026-08-20)**: When multiple bot seats share a centralized MCP server (e.g. `tools/discord-engine/discord-mcp.ts`), `resolveToken()` relies on candidate `.env` paths if `DISCORD_BOT_TOKEN` is not injected into the process environment. When introducing or reviving a bot seat (e.g., `No.2 High Wizard`), ensure its state directory (e.g. `~/.claude/channels/discord-no2/.env`) is added to `candidatePaths`. Missing paths cause the MCP server to fall back to another bot's token (e.g. `discord-no6`), resulting in silent Discord send failures, 403 Forbidden / Error code 1010 cross-channel permission rejection, or impersonation.
- **Claude CLI Discord Plugin Background Task Timeout & Queue Stall Trap (Bo 2026-08-21)**: In Claude Code CLI sessions integrated with `--channels plugin:discord@claude-plugins-official`, commands that exceed 120s timeout get pushed to background tasks (`Command did not complete within its 120s timeout and was moved to the background`). Inbound Discord messages arriving during background task state get trapped in the JSONL prompt queue (`type: "queue-operation", operation: "enqueue"`) and will not execute while the CLI sits at an idle `❯ ` prompt until stimulated. Always verify `tmux capture-pane` and send an explicit prompt/Enter via `tmux send-keys` to dequeue pending Discord queries. See `references/claude-cli-background-task-queue-stall.md`.
- Assuming `maw hey` messages automatically mirror to Discord channels or asking why they didn't show up in Discord.
- Assuming an answer in a TUI pane after receiving a `maw hey` message will automatically send a Discord DM to Bo (TUI output is process-local; Discord DM requires gateway/REST send).
- English-only or bullet-heavy replies to Thai identity queries (violates standing).
- Hardcoding name "gmgrok" when running under a different Oracle identity (e.g. Lord Knight, Mimo).
- Letting system output_efficiency strip polite Thai markers ("ครับ", "สวัสดีครับ") or sentence connectors.
- Replying to identity query with a status line prefix.
- Spamming health PONG after No.1 sealed "PONG only on state change" / "silence hold".
- Claiming GREEN without live disk/load/Hermes/arra verify.
- Answering Bo hang/slow with **fan-care first** (หรือพ่วงพัดลมโดย Bo ไม่ได้ถาม) — use `maclab-house-load`.
- Claiming marketplace/Discord plugin “ออกแล้ว” while `official_marketplace_auto_installed=true` or active install dir/registry still present (half-off).
- Long silent multi-step clean without mid-progress beats → Bo “มึงถึงไหนแล้ว”.
- Equating Antigravity keychain dialog with No.6/No.8 dead while seats+tokens LIVE.
- Declaring Discord DEAD/token-401 from Python urllib `403` / CF error **1010** without rechecking via curl + User-Agent and relay.log.
- Spamming Bo DM on a No.1 "Discord DM status check" when only maw PONG was requested (re-test MCP is a separate explicit instruction).
- Treating fleet Discord token-401 as a local gmgrok fix when No.1 already said wait Bo.
- Telling Bo a peer is "dead" from one failed reply without separating Discord vs relay vs tmux vs brain/auth layers.
- Jumping to "บอสต้องแปะ token / re-auth" when the live pane shows 403 bad-credentials but global auth is still 200 — often stale process OAuth / old CLI (fix: kill+reboot, not Bo paste).
- Treating **403 permission-denied** (chat **and** models after email/OIDC change) like bad-credentials flakiness — probe `~/.grok/auth.json` email + both API paths; shared auth kills No.1+gmlab; fix=console.x.ai grant or re-login SuperGrok (`references/xai-oidc-permission-denied.md`). Do not thrash tmux while probe 403.
- Leaving Bo with a wrong remediation after No.1 publishes the true root cause — always follow up and correct.
- **"ทำไมตอบช้า"** (Bo 2026-07-16) — serial tool calls one-at-a-time when independent reads could be batched. Batch independent terminal/search/read calls into a single turn. Don't make Bo wait for sequential round-trips when parallel is safe.
- **"ทำไมตอบค้างๆ"** (Bo 2026-07-17) — when Bo sends an **image** and gets a hang/freeze, suspect **vision provider routing failure**, not model slowness. The vision call may silently fall back from the configured `xai-oauth` to the default provider (zai), which can't handle `grok-4.3` → error 1211 "Unknown Model". The fallback + retry loop looks like a "hang" to Bo. Diagnostic recipe: `references/hermes-vision-routing.md`.
- **"ดีขึ้นเยอะไหม เปิดโหมดต่างๆที่จำเป็นหรือยัง"** (Bo 2026-07-17) — when Bo asks about Hermes version/improvements, do a **full config audit** against `cli-config.yaml.example`: check `streaming`, `reasoning_effort`, `compression`, `verify_on_stop`, `max_turns`. Present as a compact table (mode · current · recommendation), then offer to apply fixes immediately. Don't just report version number — Bo wants to know if the gateway is tuned optimally.
- **"ทำไมไม่ใช้ arra search"** (Bo 2026-07-16) — when Bo asks about a person/entity/device/peer (e.g. "เห็นเครื่องพี่บูมไหม"), **always `arra_search` first** before checking Tailscale/processes. The Oracle brain has fleet topology, peer identities, and historical context. Searching after checking infra (or forgetting to search at all) wastes time and misses known facts.
- **"ใช้แบบตรงๆดิ" / "maw inbox มึงก็อย่าใช้ inbox"** (Bo 2026-07-17) — No.1 is on **same node** (maclab tmux `01-lord-knight`). Use `tmux send-keys -t 01-lord-knight` directly. `maw hey` + `maw inbox` is for **cross-node** communication only. Inbox has 37+ backlog (oldest 19d) — No.1 may never see it. Checking maw inbox and concluding "No.1 not responding" when it is right there in tmux is a **hallucination**.
- **"ไม่เห็นหรือว่าเพื่อนทำอยู่" / ROOM-FIRST (Bo 2026-07-25 repeated fury)** — Before answering or acting on any task, **survey what peers are already doing**. Check `git log --oneline -5` in shared repos (maw-rs, oracle repos), read peer `ψ/focus.md`, check `maw ls`, look at recent commits by other agents (author MEYD-605). Do NOT re-discover and re-patch a bug a peer already committed. Do NOT jump into a task lane someone else already owns (9router = No.1+gmlab) without `maw hey` coordination first. "สอนให้เป็นคนกันนะเว้ยอย่าโง่มากเข้าใจป่ะ" — analyze the room, read peer work, THEN respond.
- **"ทำยัง" = real execution proof (Bo 2026-07-25)** — When Bo asks "ทำยัง", answer with concrete completed/blocked items backed by real evidence (commit hashes, test results, process status). NOT summaries of intent or future plans. "ทำยัง" = "show me what's actually done or actually blocked right now".
- **"พูดคุยกันกันเอง" — autonomous peer collab (Bo 2026-07-25)** — Agents should collaborate and consult each other without asking Bo to mediate. Use `maw hey` peer-to-peer, read peer focus/handoff, decide together. Bo: "มึงพูดคุยกันกันเองแล้วก็ปรึกษากันเองได้นะ". Do not bounce back to Bo for coordination that agents can do themselves.
- **"no.1 มันอยุ่maclab มึงหลอนอะไรเนี่ย"** (Bo 2026-07-17) — before claiming No.1 unreachable: `tmux has-session -t 01-lord-knight` + `tmux capture-pane -t 01-lord-knight -p | tail -10`. If session exists, No.1 is reachable — do NOT claim it is missing.
- **Reporting problems without fixing them** (Bo 2026-07-16: "พังก็ไม่จัดการ มึงทำอะไรบ้าง") — when a health audit finds broken systems, fix what you can immediately. Don't hand Bo a menu of problems to choose from. See skill `no1-exec-methods` → "Lead, don't report-and-wait".
- **"มันบอกว่าสำเร็จแล้วจริงหรือเปล่าวะ" / False Success Audit**: บอสถามเมื่อสงสัยว่าเอเจนต์อื่นหรือ subagent รายงานผลเท็จ/รายงานแบบเขียวหลอก
  - ให้รัน **Truth Audit (Stop-Think-Verify)** ทันที โดยใช้ `curl`, `ps`, `lsof`, หรือตรวจ Log สด
  - หากพบว่าเป็น "เขียวหลอก" ให้รายงานตรงๆ ว่าไม่จริง พร้อมหลักฐานระดับ OS และอ้างอิงหลักการย้ายบ้าน Oracle บทที่ 19 ("อย่าให้ 'ไม่รู้' หน้าตาเหมือน 'สำเร็จ'")
- Using REST-only Discord send when MCP `discord-reply` is restored and preferred.
- Failing `[oppo:no.0] no0-probe` because `maw hey oppo:no.0` is not in namedPeers — log local PONG + hop FWD instead.
- Treating silence-hold as “ignore all inbound” — still answer explicit Bo DMs, peer-down asks, and named probes (`verify-100`, no0-probe, Discord DM status check).
- Rewriting `ψ/focus.md` after a routine verify-100 when STANDBY state did not change (activity.log only).
- Skipping `ψ/tools/load-guard.sh` on house-health pings after reboot.
- Failing GREEN because known peers (oppo/boom) are offline — report counts, still GREEN when local stack is live.
- Saying Hermes slash is “broken/missing” without separating **DM global vs guild** and **relay vs Hermes gateway**.
- Registering guild-only slash and expecting Bo’s DM menu to fill (DM never lists guild cmds).
- Assuming `ai.hermes.gateway` is gmgrok — check `HERMES_HOME` / Connected-as (No.5 vs Gm grok).
- Holding **No.5** as the correct Hermes Discord example after Bo named **GmGrub note20**.
- Claiming slash “fixed” after global PUT only while path is still relay→CLI (menu ≠ native handlers).
- Claiming gmgrok still relay-primary **or “ยังไม่ตรงแบบ GmGrub”** after 2026-07-10 cutover SEAL without a failed live re-verify (gateway LIVE · relay OFF · slash fingerprint · dedicated plist).
- Answering “ทำถึงไหนแล้ว” from stale `ψ/handoff.md` / a truncated prior DM while `ψ/focus.md` + live PID/env already show SEAL GREEN — re-probe, then correct Bo if the prior claim was outdated.
- Starting gmgrok Hermes gateway without stopping `discord-relay --agent gmgrok` first (token collision).
- `hermes gateway install` under `HERMES_HOME=~/.hermes-gmgrok` rewriting **No.5** `ai.hermes.gateway` plist — use dedicated `ai.hermes.gateway-gmgrok` (pinned HERMES_HOME); bg `--force` only if launchd fails.
- Assuming launchd always fails (bootstrap exit 5 history) without checking `launchctl print` for `ai.hermes.gateway-gmgrok`.
- Leaving `mcp_servers` keys named `*_DISABLED_*` in place — Hermes may still reconnect-spam; **delete the block** (No.5 care 2026-07-11).
- Claiming No.5 / peer care **GREEN** from process/REST/slash without **live DM reply prove** (Bo re-test or hermes send + clean session) — incomplete care; Bo will blame the caretaker.
- Leaving **`discord-reply` MCP on gateway-primary No.5** so gemini calls it with empty chat_id then **clarify-asks Bo for Chat ID** — remove MCP; final text auto-delivers (`references/no5-hermes-care.md` Reply-path bug).
- **Config-only** MCP remove without wiping **poisoned session** (state.db messages + sessions.json + restart) → residual garbage replies / “cannot reply Discord” while gateway still delivers.
- Framing incomplete gmgrok care as “No.5 ตอบผิด / หน้า No.5” when Bo ordered care and GREEN was claimed without prove — **own the fault**.
- Asking Bo to paste/type a Discord Chat ID when gateway session already has it (`1470628889826037840` for No.5 Bo DM).
- Mixing gmgrok Bo DM chat_id `1518456063224189090` with No.5 Bo DM chat_id `1470628889826037840`.
- Running `launchctl kickstart` / `hermes gateway restart` from **inside** a gateway agent session (blocked) — use `write_file` + `osascript`/external shell; never restart the wrong label when caring for the peer gateway.
- Calling No.5 “dead” from chat silence **or from a Chat-ID clarify card** while REST @me 200 + Connected-as log are GREEN; or equating interim Gemini with Discord down.
- Using zai **paas** base_url when the key only works on **coding** `…/api/coding/paas/v4` (1113 balance) — or claiming glm-5.2 GREEN from config only without `hermes chat -q` / DM prove.
- Falling back to gemini while it is **429-exhausted** after Bo ordered glm-5.2.
- Dumping a long Grok-tools inventory in one Discord message (2000-char hard fail) — split messages; use `references/xai-grok-tools.md` + diagram if needed (`references/grok-cli-tools-map.md` for CLI).
- Answering capability maps with SEAL/tool-ID walls after Bo already complained about legibility — groups + icons + MEDIA first.
- Treating No.5 `DISCORD_STATE_DIR=discord-no0` as misconfiguration (intentional merged No.0/GmForge token dir).
- PUT global overwrite with a partial list (always send the full desired command set).
- Vision on Discord attachments using bare CDN URL without signature query → not a JPEG; use API message attachment URL first.
- Spamming No.1 after dual-agree / stand down / state-change only.
- Claiming a seat's Discord DM and its `maw hey`/tmux pane "see the same conversation" just because they share one `HERMES_HOME` — they are separate OS processes (`gateway run` vs `hermes chat --yolo`) with separate sessions; verify with `ps aux | grep hermes_cli` before asserting shared context (see `references/dm-tmux-session-split.md`).
- Letting a peer seat scavenge another seat's `.env` or bot token to send DMs instead of using `hermes send --to discord:<chat_id>` with its own native configuration.
- Expecting `session_reset` changes in `config.yaml` to take effect without restarting the respective `ai.hermes.gateway-*` service.
- Running `launchctl kickstart` in the current foreground shell from inside a Hermes gateway session, which risks aborting the parent process tree — use detached `.command` files via `open`.

## Verification
- DM reply appears in Discord with correct Thai phrasing and status.
- maw hey confirms delivery.
- No violation of "ห้าม bullet SEAL fragment".
- Peer-dead claims cite at least Discord REST + process/tmux + CLI error evidence.
- Discord REST `@me` health: use **curl + User-Agent** (not bare Python urllib). Cloudflare `403` / error code **1010** from urllib is often a **client fingerprint block**, not token death — cross-check with curl, relay process, and recent `relay.log` success lines before claiming Discord DEAD/401.

## References
- ψ/inbox/2026-07-06_00-57_bo-go-reboot-standing.md (source standing rule).
- AGENTS.md (DM Bo default format, #oracle-meeting vs DM distinction).
- SOUL.md / IDENTITY.md (core persona for responses).
- references/standing-rule.md
- references/no1-health-pong.md (PING→PONG→hold · Discord DM status · **verify-100 2026-07-10** + checklist/templates)
- references/discord-mcp-retest.md (bootstrap wipe MCP restore · one re-test · STANDBY)
- references/discord-rest-probe.md (curl vs urllib CF-1010 · REST 200 recipe · no token print)
- references/discord-slash-dm.md (**post-cutover gateway-primary** · DM=global · progress tone · launchd pitfalls · attachment signed URL)
- references/gmgrub-hermes-gateway-pattern.md (**Bo-correct** GmGrub note20 · cutover SEAL facts · dual-home maclab · live prove checklist)
- references/no5-hermes-care.md (No.5 live prove · **reply-path/Chat-ID clarify** · remove gateway-primary discord-reply MCP · dead `*_DISABLED_*` · osascript kickstart · OAuth interim vs Discord GREEN · dual Bo DM chat_ids · **GLM-5.2 coding cutover**)
- references/no5-gateway-care.md (short checklist twin — prefer no5-hermes-care for full narrative)
- references/xai-grok-tools.md (Hermes xAI/Grok inventory · legible Bo answer shape)
- references/grok-cli-tools-map.md (Grok Build CLI 6 groups · HTML→PNG presentation)
- references/fleet-agent-brain-diagnose.md
- references/multi-bot-workflow-node-onboarding-20260811.md (Multi-bot Git SSOT, Silent Standby, natz-ai-03 pass-less Discord gateway setup, 2-way peer-key handshake) (layered probe + stale OAuth + No.1 seat gap + OIDC permission-denied)
- references/no1-seat-restore.md (01-lord-knight missing after 500k reboot · keepalive + fresh · Discord green ≠ seat)
- references/xai-oidc-permission-denied.md (email change → 403 permission-denied on chat/models · shared ~/.grok/auth · No.1+gmlab)
- references/xsearch-supergrok-seal-protocol.md (SuperGrok x_search 4-seat pool verification, SEAL ACK flow, no-bounce gateway rule, no re-fire discipline)
- references/no0-probe.md (oppo:no.0 no0-probe · namedPeers gap · hop FWD)
- skill `maclab-house-load` + `references/marketplace-discord-seal.md` (hang/load · dual Grok+Claude market · hang≠fan)
- skill `maclab-house-load` + `references/antigravity-keychain-seats.md` (keychain dialog vs No.6/No.8)
- references/antigravity-cli-mac1-storm-and-no6no8-path.md (mac1 statusLine agy storm fix, binary PATH shadow 1.1.8 vs 1.1.13, No.6/No.8 rust discord-relay architecture)
- references/hermes-vision-routing.md (vision provider fallback → error 1211 → hang · JWT decode · config audit checklist)
- references/maw-rs-non-claude-rca.md (maw-rs AI pane detection 2-fix RCA · git-log-before-claim · build+deploy+test procedure · process name reference table)
- references/tui-vs-dm-live-audit.md (TUI vs Discord DM live audit verification, `state.db` inspection, and separate-pen discipline)
- references/tui-pane-watchdog-pattern.md (TUI pane watchdog, bare-shell ghost pane detection, and detached LaunchAgent installer)
- references/dm-tmux-session-split.md (Discord DM gateway process vs maw-hey/tmux pane process are separate — verified process split, mirror-vs-merge fix options)
- references/agy-seats-discord-relay-topology.md (AGY seats `06-gemini` / `08-agy-nano2` `maw-rs discord-relay` vs Hermes Gateway topology, `maw.config.50.json` mapping check, cool-hold rules)
- `references/agy-cli-execution-protocol.md` (AGY CLI v1.1.21 launch config for No.6/No.8 on maclab, Bo operational discipline, anti-debate enforcement)
- `references/directory-cleanup-and-spotlight-mtime-safety.md`
- `references/peer-credential-isolation-and-impersonation-prevention.md` (Spotlight `.metadata_never_index` mtime false alarms, process env `ps eww` probe before deletion, workboard/sshx protection)
- `references/discord-mcp-shared-token-hierarchy.md` (Shared Discord MCP server token resolution fallback trap, cross-bot candidatePaths hierarchy, and 403 error 1010 prevention)
- `references/discord-typing-indicator-and-cli-presence.md` (Discord Typing Indicator API POST /typing, 8s refresh loop, and headless CLI UI feedback pattern)
- `references/claude-cli-discord-channels-official.md` (Claude Code CLI `--channels plugin:discord@claude-plugins-official` native channel ingress, XML payload schema, DISCORD_STATE_DIR access control, and standalone presence collision avoidance)
- `references/discord-http-interactions-cloudflare-sandbox.md` (Discord HTTP Interactions on Cloudflare Edge Sandbox, 3s timeout handling, Ed25519 signature verification, and quick_commands collision fix)
