---
query: "maw atlas and maw hermes"
target: "no10-oracle"
mode: deep
timestamp: 2026-06-19 05:11
friction_score: 1.0
coverage: [oracle, files]
confidence: high
---

# Trace: maw atlas and maw hermes

**Target**: no10-oracle
**Mode**: deep | **Friction**: 1.0 | **Confidence**: high
**Time**: 2026-06-19 05:11

## Oracle Results
- **maw-atlas**:
  - `learning_ψ/memory/learnings/2026-06-15_discord-oracle-setup-guide-tingtee-cat-lab-x-at_0`: setup guide reviewed by Atlas.
  - `learning_ψ/memory/learnings/2026-06-17_chapter-5-checklist-x_1`: references `- [X] ติดตั้ง maw-atlas` และการตั้งค่า token เพื่อรัน `maw atlas ls`.
  - `retro_15.00_retrospective_1` (2026-06-07): No.6 Gemini ทำการศึกษาโค้ด `maw-atlas` 21 ไฟล์ และพิสูจน์การรันผ่าน `maw atlas whoami/ls/read`.
- **maw-hermes** / **maw hermes**:
  - `learning_ψ/memory/learnings/2026-06-13_making-hermes-actually-work-book-2-of-the-herm_0`: บทที่ 8 มีหัวข้อเรื่อง **Building maw hermes plugin** (plugin.json + index.ts).
  - `learning_ψ/memory/learnings/2026-06-13_hermes-3_0`: บันทึกการทำ profile collaboration, Kanban orchestrator, Discord integration และ MAW.

## Files Found
- **maw-atlas**:
  - `/root/Code/github.com/nat-build-with-oracle/maw-atlas` (โฟลเดอร์ Repository หลักของปลั๊กอิน ประกอบด้วย `plugin.json`, `index.ts`, และโมดูลย่อย)
  - `/root/Code/github.com/Soul-Brews-Studio/maw-js/plugins/atlas/` (โฟลเดอร์ปลั๊กอินที่ติดตั้งอยู่ใน maw-js)
- **maw-hermes**:
  - ไม่พบโฟลเดอร์ Repository หรือโค้ดเบสแยกเฉพาะสำหรับ `maw-hermes`
  - มีเอกสารความรู้และแบบแผนโครงสร้างของปลั๊กอิน `maw hermes` อยู่ใน `/root/ψ/inbox/making-hermes-work_2026-06-13.txt` (บรรทัดที่ 5630-6287: อธิบายการสร้าง `maw hermes` เพื่อทำ Discord REST API calls โดยไม่ต้องรัน gateway หรือ LLM ผ่านคำสั่ง `whoami`, `send`, `read`, `channels`)

## Git History
- **maw-atlas**:
  - `2026-06-09`: แก้ไขบัก inbox mark-read regex ในบรันช์ `fix/inbox-mark-read-robustness` ทั้งใน `maw-js` และ `maw-atlas`
- **maw-hermes**:
  - ไม่พบประวัติการ commit ของ plugin แยก

## GitHub Issues/PRs
None

## Cross-Repo Matches
- `/root/Code/github.com/nat-build-with-oracle/maw-atlas`
- `/root/Code/github.com/MEYD-605/maw-atlas-backfill-workshop`

## Oracle Memory
- การวิเคราะห์เชิงสถาปัตยกรรมของ `maw-atlas` ปรากฏอยู่ในบันทึกการทำงานของ No.6 Gemini (เซสชัน 2026-06-07)
- โครงสร้างและแนวคิดของ `maw hermes` สรุปไว้ใน P'Nat's Book 2: "Making Hermes Actually Work" (Chapter 8) ที่อยู่ใน inbox ของระบบ

## Friction Analysis
**Score**: 1.0 — Frictionless (ข้อมูลครบถ้วน ค้นเจอได้ง่ายจากทั้ง Oracle Learnings และไฟล์เอกสารในระบบ)
**Coverage**: `[oracle, files]`
**Goal check**: ตอบคำถามได้ชัดเจน สามารถยืนยันที่อยู่และประวัติของทั้ง `maw-atlas` (สคริปต์ที่รันได้จริงใน `/root/Code/github.com/nat-build-with-oracle/maw-atlas`) และ `maw-hermes` (เอกสารสถาปัตยกรรมใน Book 2)

## Summary
- **maw-atlas**: เป็น Discord fleet infrastructure plugin หลักที่พัฒนาเสร็จแล้วและติดตั้งใช้งานจริงใน `maw-js`
- **maw-hermes**: เป็นแนวคิดและแบบแผนการสร้างปลั๊กอินเพื่อใช้แทน gateway (Direct REST) ในบทที่ 8 ของหนังสือ "Making Hermes Actually Work" ของ P'Nat
