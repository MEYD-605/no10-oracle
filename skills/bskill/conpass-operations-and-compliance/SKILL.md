---
name: conpass-operations-and-compliance
description: "Use for ConPass operations, compliance, and landing pages."
version: 1.0.0
tags: [conpass, compliance, landing-page, marketing, legal-safety, pricing, logistics]
---

# ConPass Operations, Compliance & Landing Page Standards

Comprehensive operational guide, legal compliance rules, copywriting boundaries, pricing tiers, and landing page standards for **ConPass** (คอนแทคเลนส์ช่วยแยกเฉดสี / Opto-Lab).

## 1. Compliance & Legal Safety (Bo's Standing Directives)

- **Strictly FORBIDDEN Keywords**:
  - **NEVER use "สอบใบขับขี่" (Driver's License Exam)** anywhere in web copy, OG tags, headers, or social cards. Directly mentioning driving license exams triggers regulatory scrutiny and transport department compliance risks.
  - **NEVER use aggressive or absolute claims**: Avoid *"ผ่านฉลุย 100%"*, *"อัตราผ่าน 98.4%"*, *"โกงข้อสอบ"*, or *"รักษาตาบอดสีให้หายขาด"*.
- **Approved Safe Positioning & Core Use Cases**:
  1. **ตรวจโรคไปทำงานต่างประเทศ**: เกาหลีใต้ (EPS), ญี่ปุ่น, งานเรือสำราญ/พาณิชย์ (Seaman Book).
  2. **ตรวจสุขภาพเข้างานโรงงาน & ช่างเทคนิค**: โรงงานอุตสาหกรรม, ช่างไฟฟ้า, ช่างซ่อมบำรุง, วิศวกร.
  3. **ตรวจสุขภาพประจำปี / สมัครงานทั่วไป**: เพิ่มความมั่นใจในการแยกแยะเฉดสี แดง-เขียว.
- **Product Framing & Registration Placement**:
  - Describe as *"คอนแทคเลนส์ช่วยแยกแยะเฉดสี (Selective Spectral Filter)"* หรือ *"เลนส์ฟิลเตอร์เฉพาะบุคคลระดับ Opto-Lab"*.
  - **Commercial Registration (จดทะเบียนพาณิชย์)**: Do NOT place loud commercial registration badges in the Hero section or above-the-fold (makes the site look overcompensating/scam-like or invites unwanted regulatory attention). Place quietly in the footer as subtle secondary text (`text-slate-400 text-[11px]`).

---

## 2. Visual Theme, UI Aesthetics & Optical Fidelity

- **Color Scheme (Clean Medical White & Crimson Red)**:
  - Background: Clean white / slate tint (`#FFFFFF` to `#F8FAFC`).
  - Brand Accent: Crimson / Burgundy Red (`#DC2626` / `#991B1B`) for opto-lab precision.
  - Navbar: Dark slate (`#0F172A`) for professional contrast and grounding.
- **Depth & Polish over Flatness**:
  - Avoid flat, dull containers. Use subtle borders (`border border-slate-200/80`), rounded-2xl corners, and soft layered shadows (`shadow-sm`, `hover:shadow-md`).
- **Interactive Simulator Optics (No Red Wash)**:
  - Do NOT apply a crude solid red overlay or muddy red wash over Ishihara plates.
  - Use selective spectral notch filtering (`plate07_conpass_filtered.png` / `plate03_conpass_filtered.png`) so target numbers (74, 29) separate crisply from the surrounding background dots without washing out the whole plate.
- **Open Graph (1200 × 630 px) Social Preview**:
  - Always deploy an explicit 1200x630 OG image (`og-conpass-preview.jpg`) showcasing the genuine product kit (vials, gold case, accessories), try-before-buy signal, urgent pickup note (นัดหมายล่วงหน้า), and phone `080-041-6403`.

---

## 3. Pricing, Delivery Channels & Pickup Rules

| Package / Channel | Price | Terms & Delivery Details |
| :--- | :--- | :--- |
| **ชุดมาตรฐาน ConPass** | **1,490 THB** | ครบชุดพร้อมตลับพรีเมียม น้ำยา อุปกรณ์ใส่ จัดส่งพัสดุฟรีทั่วประเทศ (มีเก็บเงินปลายทาง) |
| **ส่งด่วนรถตู้ต่างจังหวัด** | **1,900 THB** | **ไม่มีเก็บเงินปลายทาง (โอนเงินก่อนส่งเท่านั้น)** ลูกค้าแจ้งชื่อ เบอร์โทร และท่ารถ/จุดรับ |
| **ส่งด่วน Grab กทม.** | ตามระยะทาง | ส่งด่วน 1–2 ชั่วโมง สำหรับลูกค้าที่ต้องการใช้งานเร่งด่วน |
| **นัดรับหน้าร้าน กทม.** | 1,490 THB | **ย่านลาดพร้าว 48 (นัดหมายเวลาล่วงหน้า)**: ลูกค้าสามารถ **ทดลองใส่ดูแผ่นทดสอบสีก่อนรับได้** (ห้ามโฆษณาว่าเปิด 24 ชม.) |

---

## 4. Single DOM Integrity & Deployment Verification Gate

- **Single DOM Hygiene (Zero Duplication)**:
  - When updating or rewriting single-file landing pages (`index.html`), verify DOM uniqueness before deployment.
  - Never allow duplicate sections, repeated modals, or multiple `</body>` / `</html>` closing tags.
  - Automated check: Assert that every key section ID (`#simulator`, `#location`, `#pricing`, `#faq`, `#comparison`) occurs **exactly once**.
  - Assert zero occurrences of forbidden terms (`ใบขับขี่`, `เปิด 24 ชม.`).
  - Always verify that the mobile sticky action bar does not block or overlap content.

---

## 5. Responsive Layout & Transit Map Standards

- **Full Desktop Responsiveness**: Fluid containers (`max-w-7xl mx-auto`) with responsive multi-column grids.
- **Transit Map (No Micro-Address Clutter)**: Do not write confusing micro-soi directions. Display a clean visual transit diagram featuring:
  - **MRT Yellow Line (สายสีเหลือง)**: สถานีภาวนา (ใกล้สุด ~600m)
  - **MRT Blue Line (สายสีน้ำเงิน)**: สถานีสุทธิสาร (ทางออก 3 ลัดเข้าลาดพร้าว 48 ได้ใน 5 นาที)
  - Landmark chips (ตลาดโชคชัย 4, รพ.เปาโล โชคชัย 4, สี่แยกรัชดา-ลาดพร้าว)
  - Single-tap Google Maps navigation button.
- **Direct Phone & LINE SSOT**: Floating CTA bar with safe area padding, direct LINE deep link, and `tel:0800416403` (`080-041-6403` - สุจิตร มานิตยกุล).

---

## 6. Account & Payment SSOT

| Item | Details |
| :--- | :--- |
| **Payment Accounts** | • **KBank**: 051-2-97876-2 (สุจิตร มานิตยกุล)<br>• **SCB**: 111-508-3127 (สุจิตร มานิตยกุล)<br>• **PromptPay / Phone**: 080-0416-403 (สุจิตร มานิตยกุล) |
| **Google Ads MCC** | `810-402-1058` (Conpass Manager) |
| **Google Ads Child CID** | `610-476-1960` |
| **LINE Official** | `@conpass` / `https://lin.ee/conpass` |
