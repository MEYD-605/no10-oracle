---
name: conpass-landing-and-funnels
description: "Build, deploy, and audit landing pages for ConPass lenses."
version: 1.0.0
tags: [conpass, landing-page, marketing, funnels, responsive]
---

# ConPass Landing Page & Conversion Funnel Standards

Comprehensive design, copywriting, and operational guide for building and optimizing high-converting landing pages and sales funnels for **ConPass** (คอนแทคเลนส์ตาบอดสี).

## 1. Value Proposition & Copywriting Rules (Bo's Standing Preferences)

- **Do NOT use interactive SVG / simulated Ishihara plates**: Customers already know they have color blindness. Interactive plates waste critical viewport height and render inconsistently across mobile webviews. Focus immediately on proof of results, speed of delivery, and opto-lab standards.
- **Do NOT compare against generic glasses (แว่นตาบอดสี 4,500–8,000 THB)**: Glasses are bulky, easily noticed by medical examiners, and strictly banned during official physical examinations (police, military, transport).
- **Enforce the 3-Way Comparative Decision Matrix**:
  1. **ConPass (Opto-Lab Grade - 1,490 THB)**: High optical clarity, natural discrete tint (เนียนตา กรรมการตรวจไม่สะดุดตา), certified optical stability, 1-year durability, instant Grab delivery / pickup at Lat Phrao 48.
  2. **คอนแทคเลนส์ตลาดทั่วไป (แฟชั่น/ของหิ้วราคาถูก)**: สีย้อมไม่ได้มาตรฐาน ออปติกมัว สีย้อมหลุดลอก ระคายเคืองตา ตรวจสอบใบขับขี่ไม่ผ่าน.
  3. **การรักษาอื่น / ผ่าตัด / เลสิก**: ค่าใช้จ่ายสูงหลักหมื่นถึงหลักแสน และไม่สามารถรักษาความผิดปกติของเซลล์รับแสงรูปกรวย (Cone cells) ที่บกพร่องแต่กำเนิดได้จริง.

---

## 2. Responsive Layout, Transit Maps & Viewport Rules

- **Full Desktop Responsiveness**: Never constrain desktop layouts inside fixed mobile wrappers (e.g. `max-w-xl` on body). Use fluid containers (`max-w-7xl mx-auto`) with responsive grids (`grid-cols-1 md:grid-cols-2 lg:grid-cols-3`).
- **Transit & Landmark Map (No Micro-Address Clutter)**: Do not write long or micro-detailed street addresses. State the pickup hub concisely as **"จุดนัดรับด่วน: ย่านลาดพร้าว 48 (เปิด 24 ชม.)"** and provide an intuitive transit diagram showing MRT Yellow Line (สถานีภาวนา ~600m - ใกล้สุด) & Blue Line (สถานีสุทธิสาร ทางออก 3 ลัด 5 นาที) plus landmark chips and a single-tap Google Maps button.
- **Sticky CTA Bar & Safe Area Padding**: Floating bottom action bars must include safe-area padding (`padding-bottom: calc(1rem + env(safe-area-inset-bottom))`) and the main page container must have `pb-28` to prevent covering footer FAQs or disclaimers.
- **Direct Conversion CTAs & Phone SSOT**: Include sticky **Click-to-LINE** and direct phone call links (`tel:0800416403` / `080-0416-403` - Bo / สุจิตร มานิตยกุล) to eliminate mobile webview authentication drop-off.

---

## 3. Commercial & Account SSOT

| Item | Details |
| :--- | :--- |
| **Pricing** | **1,490 THB** per set (โปรโมชั่นพร้อมของแถม + บริการจัดส่งฟรี) |
| **Payment Accounts** | • **KBank**: 051-2-97876-2 (สุจิตร มานิตยกุล)<br>• **SCB**: 111-508-3127 (สุจิตร มานิตยกุล)<br>• **PromptPay**: 0949989486 (สุจิตร มานิตยกุล) |
| **Google Ads MCC** | `810-402-1058` (Conpass Manager) |
| **Google Ads Child CID** | `610-476-1960` (`GOOGLE_ADS_CUSTOMER_ID=6104761960`) |
| **Developer Token** | `Mvsr_5AdNY2Ko9FBJq9odg` (Test Account Access) |
| **Account Email** | `conpass.ai1@gmail.com` |
| **OAuth Helper** | `ψ/tools/conpass_oauth_helper.py` |
