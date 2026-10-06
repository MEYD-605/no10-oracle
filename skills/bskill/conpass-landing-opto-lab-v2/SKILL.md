---
name: conpass-landing-opto-lab-v2
description: "Build ConPass Opto-Lab landing pages and CRO."
version: 1.0.0
tags: [conpass, landing-page, opto-lab, conversion-rate-optimization, seo, aeo, decision-matrix, responsive-design, ishihara-simulator]
---

# ConPass Opto-Lab Clinical Landing Page & CRO Standards

Frameworks and operational guidelines for building high-converting, professional clinical landing pages for ConPass (คอนแทคเลนส์ตาบอดสี), incorporating SEO/AEO architectures, responsive multi-breakpoint layouts, safe legal phrasing, and high-urgency call triggers.

---

## 1. Professional Tone & Visual Identity (Opto-Lab CRO)
- **Clinical & Authoritative Standard:** Avoid consumer e-commerce clutter, cartoonish elements, or flashing discount badges. Adopt an authoritative optical laboratory aesthetic.
- **Strict Anti-Slop Rule:** NEVER use pitch-black dark-mode backgrounds, neon green text, or cyberpunk styling ("งานเลี้ยงเปรต"). Medical and ophthalmic products that touch human eyes demand sterile, clean, and high-trust aesthetics.
- **Cursor.directory & 21st.dev Style Reference:**
  - Background: Pure White `#FFFFFF` with ultra-light slate `#F8FAFC`.
  - Minimalist Bento grid cards with subtle hairline borders (`border border-slate-200/80 hover:border-slate-300 shadow-sm rounded-2xl`).
  - Pill badges with micro-dot indicators (`bg-red-50 text-red-700 border border-red-200/60 rounded-full px-3 py-1`).
  - Real physical product photography on clean light backdrops, with prominent optical specifications.
- **Header Cleanliness:** Keep header typography clean and crisp (e.g. `ConPass OPTO-LAB`). Do NOT clutter the header with redundant logo abbreviation boxes (like "CP" monogram boxes).
- **Typography SSOT:** Always use `IBM Plex Sans Thai` (Google Fonts) for modern, loopless, clean, and authoritative medical type. Never use bubbly or rounded toy fonts.
- **Zero Casual Emojis:** Never use casual emojis in headers or copy. Use crisp SVG vector icons (Shield, Globe, Wrench, Eye Reticle, Truck, Checkmark) with cohesive slate/teal palettes.
- **Color Architecture (White & Medical Ruby / ขาว-แดง):**
  - Backgrounds: Pure Medical White `#FFFFFF` and Subtle Slate/Warm Gray Tint `#F8FAFC`
  - Text & Headings: Charcoal Slate `#0F172A` and Secondary Slate `#475569`
  - Clinical Accents (Ruby / Crimson): Medical Ruby `#DC2626` / `#E11D48` / `#BE123C` (reflecting the 570–590 nm selective spectral filter wavelength and high-urgency clinical precision)

---

## 2. Legal Compliance & High-Converting Copywriting Formulas
- **Strict Legal Compliance (Claim Masking):**
  - **NEVER use aggressive or absolute exam pass claims:** Avoid *"สอบผ่าน 100%"*, *"ผ่านฉลุย"*, *"อัตราผ่าน 98.4%"*, *"โกงข้อสอบ"*, or *"ใบขับขี่"*.
  - **Winning Core Phrasing (Bo's High-Converting Formula):**
    - Use: **"คอนแทคเลนส์เพื่อช่วยให้เห็นตัวเลข"** + **"ตัวช่วยแยกเฉดสีบนแผ่นทดสอบ ได้อย่างมั่นใจ"**.
    - *Mechanism:* Answers the user's primary desire ("อยากเห็นตัวเลขในแผ่นทดสอบ") directly and persuasively without making illegal medical cure or exam fraud guarantees.
  - **Safe & Compliant Terminology:** Use *"แผ่นทดสอบแยกเฉดสี"*, *"เพิ่มความชัดเจนในการแยกแยะตัวเลขบนแผ่น Ishihara Plate"*, *"เตรียมความพร้อมก่อนตรวจสายตา"*, *"ตรวจสุขภาพงานช่าง/โรงงาน"*, *"ตรวจสายตาก่อนเดินทางไปต่างประเทศ"*.
  - **Commercial Registration Placement (จดทะเบียนพาณิชย์):** NEVER place loud commercial registration badges in the Hero section or above-the-fold (looks scammy/overcompensating and invites regulatory scrutiny). Place quietly in the footer as subtle secondary text (`text-slate-400 text-[11px]`).
- **Logistics & Express Van Rules:**
  - Standard set ฿1,490 (free shipping, COD available).
  - Express Upcountry Van (ส่งด่วนรถตู้ ฿1,900): NO COD (prepayment transfer required); customer provides route, recipient name, phone.
  - In-person pickup (ลาดพร้าว 48): MUST state (นัดหมายเวลาล่วงหน้า) — NEVER write "24 ชม." or "เปิด 24 ชั่วโมง".

---

## 3. High-Converting Hotline & Animated Micro-Interactions
- **High-Converting Phone Hotline Trigger:**
  - Plain static phone icons on mobile are easily overlooked.
  - Make the phone button a **vibrant crimson/rose pill** with:
    1. **Animated Ringing Receiver (`@keyframes phone-shake` / `animate-phone-active`):** Smooth shaking micro-interaction drawing visual attention.
    2. **Live Green Status Beacon (`animate-radar`):** Expanding radar ripples showing immediate availability.
    3. **High-Contrast Phone Number (`080-041-6403`):** Bold, legible number so users know they can dial directly for urgent same-day/morning exams.
  - Apply the active phone animation to both the header pill and the mobile floating sticky action bar.
- **No CTA Button Spam:** Keep exactly ONE clean floating action bar on mobile (`block lg:hidden`) with Call + LINE buttons. Never stack 3-4 duplicate CTA buttons on the same mobile screen.

---

## 4. Multi-Breakpoint Responsive Design & DOM Integrity
- **Full Desktop Grid Architecture (`max-w-7xl mx-auto px-4 sm:px-6 lg:px-8`):**
  - **2-Column Hero Section (`lg:grid-cols-12` ~55/45 split):**
    - *Left Column (lg:col-span-7):* Trust badge, H1 typography, clinical value description, 3-card micro-feature grid, and dual CTA buttons (LINE OA + Direct Phone).
    - *Right Column (lg:col-span-5):* High-authority Lab Specification Card featuring an optical spectrum diagram, PolyHema Hydrogel 38% water badge, and fast dispatch banner.
- **Single-Instance DOM Integrity (Patching Safety):**
  - When applying code patches or layout revisions, always run a regex/DOM check to ensure critical sections (`#simulator`, `#location`, `#pricing`) exist exactly ONCE in the file.

---

## 5. Optical Simulator & 3-Way Decision Matrix
- **Real Optical Contrast Crossfade (Not Flat Red Overlay):**
  - Base layer: original Ishihara plate.
  - Top layer: optically filtered plate with 570–590 nm notch suppression.
  - Controlled via CSS opacity tied to an interactive slider.
- **3-Way Comparative Decision Matrix:**
  1. **ConPass (Opto-Lab Grade - ฿1,490):** Discreet Asian iris tint, certified optical hydrogel, Grab express / Lat Phrao 48 pickup.
  2. **คอนแทคเลนส์ตลาดทั่วไป (แฟชั่น/ของหิ้วราคาถูก):** สีย้อมไม่ได้มาตรฐาน ออปติกมัว สีย้อมหลุดลอก ระคายเคืองตา ตรวจไม่ผ่าน.
  3. **การรักษาอื่น / ผ่าตัด / เลสิก:** ค่าใช้จ่ายสูงหลักหมื่นถึงหลักแสน และไม่สามารถรักษาความผิดปกติของเซลล์รับแสงรูปกรวย (Cone cells) ที่บกพร่องแต่กำเนิดได้จริง.

---

## 6. Transit Guide & Technical Specifications
- **Transit & Landmark Guide (No Micro-Address Clutter):**
  - State pickup hub concisely as **"จุดนัดรับด่วน: ย่านลาดพร้าว 48 (นัดหมายเวลาล่วงหน้า)"**.
  - Provide a clean Transit Diagram highlighting:
    - 🟡 **MRT Yellow Line:** สถานีภาวนา (YL02) ~600m (เดิน/วิน 2–3 นาที - จุดใกล้สุด)
    - 🔵 **MRT Blue Line:** สถานีสุทธิสาร (BL17) ทางออก 3 นั่งวินลัดเข้าลาดพร้าว 48 เพียง 5 นาที (เส้นทางเลี่ยงรถติด)
    - 🏢 **Landmarks:** ปากซอยลาดพร้าว 48, ทางลัดสุทธิสาร-รัชดาภิเษก, ตลาดสะพาน 2, แยกรัชดา-ลาดพร้าว
- **Technical Lens Specs:**
  - Material: PolyHema Hydrogel (Optical Grade)
  - Water Content: 38%
  - Base Curve (B.C.): 8.6 mm
  - Diameter (DIA): 14.2 mm
  - Filter Cut: 570–590 nm Selective Notch Filter
  - Lifespan: 1 Year (Unopened) / 1 Month (Active Wear)
