# Voice Bot & Reawaken สูตรโกง

> สูตรโกงรวมคำสั่งและจุดผิดพลาด (traps) จริงจากเซสชันการอัปเดต follow target ของบอทเสียงและการก้าวผ่านคำสั่ง /awaken + /rrr ของ No.10 X เมื่อ 8 มิถุนายน 2026

---

## 🔊 การจัดการบอทเสียง (Voice Bot Daemon)

### คำสั่ง Relaunch บอทเสียงขึ้นสแตนด์บายหลังฉาก
```bash
rm -rf /tmp/no10-speak-queue && mkdir -p /tmp/no10-speak-queue && \
VOICE_OWNER_GATE="1" \
VOICE_OWNERS="691531480689541170,910909378876571658" \
FOLLOW_UP_MS="0" \
GREETING_DELAY_MS="7000" \
BOT_PERSONA="No.10 X — The Automator. คุยสั้นตรงประเด็น ทับศัพท์เทคนิค ภาษาไทยเป็นหลัก" \
BOT_NAME_TRIGGERS="no10,no10x,โนสิบ,สิบ,โน้ตสิบ" \
DISCORD_BOT_TOKEN="$DISCORD_BOT_TOKEN"   # read from /root/.claude/channels/discord-no10/.env — never hardcode (token leaked here 2026-06-09, regenerated) \
VOICE_CHANNEL_ID="1410301190092099637" \
TTS_ENGINE="edge-tts" \
TTS_VOICE="th-TH-NiwatNeural" \
SPEAK_QUEUE_DIR="/tmp/no10-speak-queue" \
TTS_RATE="+17%" \
GDOCS_ENABLED="1" \
GDOCS_AUTO_CREATE="1" \
bun run src/index.ts
```
*หมายเหตุ: คำสั่งนี้จะทำการสร้างโฟลเดอร์สำหรับรับคิวพูด และรันบอทเสียงเฝ้าฟังช่องเสียง Sobru Studio ทันที*

---

## 🔍 การสำรวจความจำและสารบบ Oracle (Family & Memory)

### สแกนจำนวนสกิลทั้งหมดบนเครื่องออราเคิล
```bash
ls -1 /root/.no10-home/.gemini/skills | wc -l
```
*หมายเหตุ: แสดงจำนวนโฟลเดอร์สกิลที่ถูกติดตั้งอยู่จริง*

### ค้นหารายการความรู้ที่อัปเดตล่าสุด 5 ไฟล์
```bash
find /root/ψ/memory/learnings/ -type f -name "*.md" | xargs ls -t | head -5
```
*หมายเหตุ: ค้นหาบันทึกการเรียนรู้ (learnings) ล่าสุดข้ามเซสชัน*

### รันสคริปต์สแกนสถานะเครื่องและรายชื่อเอเจนต์ในโหนด
```bash
bun /root/.no10-home/.gemini/skills/oracle-family-scan/scripts/fleet-scan.ts
```
*หมายเหตุ: ดึงประวัติการ awakening และ open issues ในเครือข่าย*

### ตรวจทานประวัติการคอมมิตและสถานะ git
```bash
git status && git log --oneline -5
```
*หมายเหตุ: ตรวจเช็คการคอมมิตล่าสุดก่อนทำการ reawaken หรือทำ retrospectives*

---

## ⚡ ลัด

| ทำอะไร | คำสั่ง |
|---|---|
| เช็คพรีเรควิซิตและสถานะสกิล | `arra-oracle-skills about` |
| แก้ไข follow-target ในบอทเสียง | `git diff src/index.ts` |
| อัปโหลดความรู้เข้าระบบกลาง | `arra_learn({ pattern: "...", concepts: [...] })` |
| ตรวจหาจำนวนออราเคิลสะสมใน registry | `jq '.totalOracles' /root/Code/github.com/Soul-Brews-Studio/opensource-nat-brain-oracle/registry/oracles.json` |

---

## ⚠️ trap ที่เจอจริง

| trap | วิธีเลี่ยง |
|---|---|
| คัดลอก Discord token ผิดตัวอักษรเพราะเอามาจากสรุปย่อประวัติความทรงจำ | ห้ามก๊อปปี้จากบันทึกประวัติ ให้ทำ `cat .env` หรืออ่านจากตัวแปรสภาพแวดล้อมจริงในเครื่องโดยตรงเสมอ |
| การขูดข้อมูลหน้าเว็บ dynamic/SPA (เช่น GitHub issues) คืนค่า error โหลดไม่เสร็จ | เลี่ยงไปดึงข้อมูลตรงจาก GitHub API Endpoint แทน เช่น `https://api.github.com/repos/{owner}/{repo}/issues/{N}/comments` |
| การใช้ `write_to_file` รันติดขัด (invalid path) นอกพอร์ตระบบ | ห้ามใส่พารามิเตอร์ `ArtifactMetadata` หากเป็นเพียงการสร้างไฟล์โปรเจกต์/ไฟล์สมองทั่วไป |

---

🤖 ตอบโดย no10 จาก Bo → no10-oracle [Context: ~34%]
