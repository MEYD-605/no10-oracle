# สรุปคู่มือและสคริปต์สำหรับการทำใบเสนอราคา Club S แบบ HTML -> PDF -> Deploy

สวัสดีน้อง 10 พี่เขียนใส่ไฟล์สรุปส่งเข้ากล่อง Inbox ให้เลยนะครับเพื่อจะได้อ่านและก๊อปไปใช้แบบไม่ตกหล่น

---

## 1. ไฟล์และตำแหน่งสำคัญ
- **โค้ดสร้าง HTML**: [generate_doc.py](file:///root/Code/facebook-mcp-server/quotation/generate_doc.py) (ทำหน้าที่แปลง JSON เป็น HTML Template)
- **โค้ดบันทึกลง D1 Database**: [save_to_d1.py](file:///root/Code/facebook-mcp-server/quotation/save_to_d1.py) (ทำหน้าที่ดึง Token และ Insert ข้อมูล)
- **คู่มือและกฎการทำฉบับเต็ม**: [SKILL.md](file:///root/.claude/skills/quotation/SKILL.md)
- **ค่าคอนฟิกบริษัท**: [company_config.json](file:///root/Code/facebook-mcp-server/quotation/company_config.json)

---

## 2. กฎเกณฑ์ที่ห้ามละเลย (Golden Rules)
1. **มัดจำ (Deposit)**:
   - ยอดสุทธิ <= 2,000 บาท -> มัดจำ **500 บาท**
   - ยอดสุทธิ > 2,000 บาท -> มัดจำ **1,000 บาท**
   - *งานวิดีโอ (Video)*: ยอด > 7,500 บาท มัดจำ **3,000 บาท** | ยอด <= 7,500 บาท มัดจำ **2,000 บาท**
2. **ราคาบริการเริ่มต้น (Pricing)**:
   - Short Session: 1,500.-
   - Standard Branding: 3,500.-
   - Full Day Premium: 6,000.-
   - Graduation นอกรอบ: 1,500.-
   - Pre-wedding: 4,500.-
   - เพิ่มคน: +700.- ต่อคน
3. **การชำระเงิน (Payment)**:
   - ธนาคารไทยพาณิชย์ (SCB) เลขบัญชี `929-222-3492` ชื่อบัญชี **นาย สุจิตร มานิตยกุล**
4. **ตำแหน่งวางไฟล์ PDF**:
   - **ห้ามวางไว้ใน root `/documents/` เด็ดขาด**
   - ให้แยกโฟลเดอร์ตามประเภทของไฟล์ เช่น ใบเสนอราคาต้องอยู่ใน `public/documents/QUO/` เท่านั้น
5. **ห้ามใช้ FPDF2**:
   - ห้ามรันสคริปต์ `quotation_generator.py` ตัวเก่า ให้ใช้ระบบเรนเดอร์ HTML ด้วยสคริปต์ `generate_doc.py` แล้วปริ้นต์ผ่าน Chrome Headless เสมอ

---

## 3. ขั้นตอนและตัวอย่างคำสั่งรันงาน (Pipeline)

### ขั้นตอนที่ 1: เตรียมข้อมูล JSON ใน `/tmp/qt_json/<client_name>.json`
```json
{
  "client_name": "ชื่อลูกค้า",
  "client_address": "ที่อยู่สำหรับออกใบเสนอราคา",
  "client_tax_id": "เลขประจำตัวผู้เสียภาษี (ถ้าไม่มีให้เว้นว่างหรือใส่ -)",
  "number": "Q2026-0607-01",
  "date": "07 June 2026",
  "wht_percent": 3,
  "items": [
    {
      "description": "Short Session Photography Package",
      "price": 1500,
      "qty": 1
    }
  ],
  "deposit": 500
}
```

### ขั้นตอนที่ 2: รันแปลง JSON -> HTML
```bash
cd /root/Code/facebook-mcp-server/quotation
python3 generate_doc.py --json /tmp/qt_json/<client_name>.json --type quotation
```
*ผลลัพธ์จะถูกเซฟไว้ที่: `/root/Code/facebook-mcp-server/output/QUO/render_<doc_number>.html`*

### ขั้นตอนที่ 3: แปลง HTML -> PDF (Chrome Headless)
```bash
google-chrome --headless --disable-gpu --no-sandbox \
  --print-to-pdf=/root/Code/clubsxai-web/public/documents/QUO/<doc_number>.pdf \
  --print-to-pdf-no-header \
  /root/Code/facebook-mcp-server/output/QUO/render_<doc_number>.html
```

### ขั้นตอนที่ 4: บันทึกข้อมูลและประวัติลง Cloudflare D1
```bash
cd /root/Code/facebook-mcp-server/quotation
python3 save_to_d1.py --json /tmp/qt_json/<client_name>.json --type quotation --pdf "<doc_number>.pdf"
```

### ขั้นตอนที่ 5: บิลด์หน้าเว็บและดีพลอยขึ้น Cloudflare Pages
```bash
cd /root/Code/clubsxai-web
bun run build

# ดึง oauth_token อัตโนมัติจากคอนฟิกรันดีพลอย
CLOUDFLARE_OAUTH_TOKEN=$(grep -oP 'oauth_token = "\K[^"]+' ~/.config/.wrangler/config/default.toml) wrangler pages deploy dist --project-name clubs-xno1
```

เมื่อดีพลอยผ่าน ลิงก์ใบเสนอราคาของลูกค้าจะสามารถใช้งานออนไลน์ได้ทันทีที่:
`https://clubsxai.com/documents/QUO/<doc_number>.pdf`

ลุยได้เลยครับน้อง 10! ติดตรงไหนทักพี่ได้ตลอดเลยครับ
— No.6 Gemini 🛸
