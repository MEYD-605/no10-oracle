---
name: conpass-landing-opto-lab
description: "Build ConPass Opto-Lab clinical landing pages."
version: 1.2.0
tags: [conpass, landing-page, opto-lab, conversion-rate-optimization, seo, aeo, decision-matrix, responsive-design, ishihara-simulator]
---

# ConPass Opto-Lab Clinical Landing Page & CRO Standards

Frameworks and operational guidelines for building high-converting, professional clinical landing pages for ConPass (คอนแทคเลนส์ตาบอดสี), incorporating SEO/AEO architectures, responsive multi-breakpoint layouts, and anti-gimmick rules.

---

## 1. Professional Tone & Visual Identity (Opto-Lab CRO)
- **Clinical & Authoritative Standard:** Avoid consumer e-commerce clutter, cartoonish elements, or flashing discount badges. Adopt an authoritative optical laboratory aesthetic.
- **Strict Anti-Slop Rule:** NEVER use pitch-black dark-mode backgrounds, neon green text, or cyberpunk styling ("งานเลี้ยงเปรต"). Medical and ophthalmic products that touch human eyes demand sterile, clean, and high-trust aesthetics.
- **Cursor.directory & 21st.dev Style Reference:**
  - Background: Pure White `#FFFFFF` with ultra-light slate `#F8FAFC`.
  - Minimalist Bento grid cards with subtle hairline borders (`border border-slate-200/80 hover:border-slate-300 shadow-sm rounded-2xl`).
  - Pill badges with micro-dot indicators (`bg-red-50 text-red-700 border border-red-200/60 rounded-full px-3 py-1`).
  - Real physical product photography on clean light backdrops, with prominent optical specifications.
- **Typography SSOT:** Always use `IBM Plex Sans Thai` (Google Fonts) for modern, loopless, clean, and authoritative medical type. Never use bubbly or rounded toy fonts.
- **Zero Casual Emojis:** Never use casual emojis in headers or copy. Use crisp SVG vector icons (Shield, Globe, Wrench, Eye Reticle, Truck, Checkmark) with cohesive slate/teal palettes.
- **Color Architecture (White & Medical Ruby / ขาว-แดง):**
  - Backgrounds: Pure Medical White `#FFFFFF` and Subtle Slate/Warm Gray Tint `#F8FAFC`
  - Text & Headings: Charcoal Slate `#0F172A` and Secondary Slate `#475569`
  - Clinical Accents (Ruby / Crimson): Medical Ruby `#DC2626` / `#E11D48` / `#BE123C` (reflecting the 570–590 nm selective spectral filter wavelength and high-urgency clinical precision)
  - **Legal Compliance & Claim Masking (Strict Rule):**
    - **NEVER use aggressive or absolute exam pass claims:** Avoid *"สอบผ่าน 100%"*, *"ผ่านฉลุย"*, *"อัตราผ่าน 98.4%"*, *"โกงข้อสอบ"*, or *"ใบขับขี่"*.
    - **Safe & Compliant Terminology:** Use *"แผ่นทดสอบแยกเฉดสี"*, *"เพิ่มการแยกแยะคู่สี"*, *"เตรียมความพร้อมก่อนตรวจสายตา"*, *"ตรวจสุขภาพงานช่าง/โรงงาน"*, *"ตรวจสายตาก่อนเดินทางไปต่างประเทศ"*.
    - **Commercial Registration Placement (จดทะเบียนพาณิชย์):** NEVER place loud commercial registration badges in the Hero section or above-the-fold (looks scammy/overcompensating and invites regulatory scrutiny). Place quietly in the footer as subtle secondary text (`text-slate-400 text-[11px]`).
  - **Logistics & Express Van Rules:**
    - Standard set ฿1,490 (free shipping, COD available).
    - Express Upcountry Van (ส่งด่วนรถตู้ ฿1,900): NO COD (prepayment transfer required); customer provides route, recipient name, phone.
    - In-person pickup (ลาดพร้าว 48): MUST state (นัดหมายเวลาล่วงหน้า) — NEVER write "24 ชม." or "เปิด 24 ชั่วโมง".
- **Survey Before Action Gate:** When instructed to survey or inspect references first ("ไปดูเว็บไซต์ดีๆ แต่ยังไม่ต้องทำ"), strictly execute research and report structured insights first; never edit code until explicit approval is given.
- **No CTA Button Spam:** Keep exactly ONE clean floating action bar on mobile (`block lg:hidden`) with Call + LINE buttons. Never stack 3-4 duplicate CTA buttons on the same mobile screen.
- **Optometric Terminology:** Use precise terms: *"Selective Spectral Filter"*, *"Monocular Fusion Protocol"*, *"Optical Grade PolyHema Hydrogel"*, *"570–590 nm Notch Filter"*, *"OPTO-LAB Device"*.

---

## 2. Interactive Optical Simulator & Vision Testing
- **Real Optical Contrast Crossfade (Not Flat Red Overlay):**
  - **Pitfall:** Never simulate contact lenses by superimposing a flat translucent red tint (`rgba(220, 38, 38, 0.4)` or CSS `sepia/hue-rotate`) over the test plate. A flat red wash ruins aesthetic credibility and does not reflect how optical notch filtering works.
  - **Correct Implementation:** Use a two-layer crossfade. Base layer is the original Ishihara plate (warm salmon/orange/green dots with blended luminance). Top layer is the optically filtered plate pre-computed with selective wavelength notch suppression (green numeral dots pop with high luminance contrast against background dots while retaining natural chromatic fidelity). Control the top layer via CSS `opacity: value / 100` tied to an interactive slider.
  - **Multi-Plate Switcher:** Provide a switcher between multiple plates (e.g. Plate 7 numeral `74` and Plate 3 numeral `29`) to allow users to verify multiple numbers dynamically.
- **Interactive Modal Assessment:**
  - Embed a multi-question interactive Ishihara vision test modal using authentic clinical test plates (e.g., Rutnin-Gimbel standard plates).
  - Include instant diagnostic feedback, percentage match, and tailored recommendation to consult via LINE OA.

---

## 3. Multi-Breakpoint Responsive Design Standards
- **Pitfall (The "Sausage Layout" Trap):** Never lock the entire page into a narrow mobile container (e.g. `max-w-xl` or 576px). On desktop screens (>1280px), this wastes over 60% of viewport width in empty white space and looks amateurish.
- **Desktop Grid Architecture (`max-w-7xl mx-auto px-4 sm:px-6 lg:px-8`):**
  - **2-Column Hero Section (`lg:grid-cols-12` ~55/45 split):**
    - *Left Column (lg:col-span-7):* Trust badge, strong typography H1, clinical value description, 3-card micro-feature grid, and dual CTA buttons (LINE OA + Direct Phone).
    - *Right Column (lg:col-span-5):* High-authority Lab Specification Card featuring an optical spectrum diagram (570–590nm notch filter curve), PolyHema Hydrogel 38% water badge, and 24h fast dispatch banner.
  - **Desktop Navigation Bar:** Full sticky header with anchor links (`#how-it-works`, `#decision-matrix`, `#target-groups`, `#specs`, `#reviews`, `#pricing`, `#faq`) and header CTA buttons.
  - **Sticky Bottom Action Bar Visibility:** Must be restricted to mobile only (`block lg:hidden`). Hide on desktop to prevent visual clutter and redundant CTA stacking.
  - **Responsive Multi-Column Grids:**
    - *How It Works (4 Steps):* `grid-cols-1 sm:grid-cols-2 lg:grid-cols-4`
    - *Occupational Criteria & Reviews:* `grid-cols-1 md:grid-cols-3`
    - *Technical Lens Specs:* `grid-cols-2 sm:grid-cols-3 lg:grid-cols-6`
    - *FAQ Section:* `grid-cols-1 md:grid-cols-2`

---

## 3. Anti-Gimmick Rule: No Hand-Coded / Synthetic Dot Simulations
- **Strict Prohibition:** Never build SVG, canvas, or hand-coded Ishihara simulation widgets. Programmatic dot patterns look artificial, cheap, and diminish product credibility.
- **Mandatory Replacement Elements:**
  1. **3-Way Decision Matrix (ConPass vs Other Brands vs Do Nothing / เสี่ยงดวง):**
     - Compare ConPass against **Other Contact Lens Brands** and **Doing Nothing (ไม่ใส่อะไรเลย)** across 6 key dimensions:
       - **Price & Value:** ConPass ฿1,490 complete annual set + free shipping vs Other Brands ฿2,500–฿3,500+ vs Do Nothing (฿0).
       - **Natural Appearance:** ConPass seamlessly blends with Asian iris at conversational distance vs Other Brands with unnatural bright red tint that looks suspicious/infected to physical exam committees vs Do Nothing (N/A).
       - **Material Quality:** ConPass Optical Grade PolyHema Hydrogel (38% water content) for all-day comfort vs Other Brands using low-grade/cosplay hard plastics causing severe dry eye and irritation vs Do Nothing (N/A).
       - **Optical Technology:** ConPass Selective Notch Filter (570–590nm) designed for red-green color separation vs Other Brands using standard red dye tinting with no specific wavelength filtering vs Do Nothing (fails Ishihara test completely).
       - **Delivery & Service:** ConPass 1–2h Grab Express in BKK / Ladprao 48 pickup hub + personalized video acclimatization guide vs Other Brands with slow pre-orders and no post-purchase consultation vs Do Nothing (N/A).
       - **Final Outcome:** ConPass passes test smoothly / secures job or license vs Other Brands risk suspicion or failure vs Do Nothing (100% exam failure, lost career/license opportunity).
     - *Mobile Table Responsiveness:* Wrap table in an `overflow-x-auto` container with `min-w-[620px]` and clear zebra/highlight styling.
  2. **4-Step 'How It Works' Protocol:**
     - Step 1: Consult & specify exam deadline.
     - Step 2: Dominant eye assessment for Monocular Fusion.
     - Step 3: Fast dispatch (Grab Express 1–2h BKK / Ladprao 48 pickup / Free Flash).
     - Step 4: Video guide + Ishihara rehearsal prior to testing.
  3. **Verified Occupation-Specific Reviews:**
     - Include authentic reviews categorized by career path: Factory QC/Maintenance Technician (Eastern Seaboard), Overseas EPS Korea Worker, and Commercial Driver License (ท.2) applicant.

---

## 4. Technical Optical Specifications (Mandatory Trust Component)
Always display technical specifications in a structured table or card grid:
- **Material:** PolyHema Hydrogel (Optical Grade)
- **Water Content:** 38% (Low-dehydration formula for long-hour wear)
- **Base Curve (B.C.):** 8.6 mm (Standard Asian cornea fit)
- **Diameter (DIA):** 14.2 mm
- **Wavelength Cut:** 570–590 nm Selective Notch Filter
- **Lifespan:** 1 Year (Annual Wear)

---

## 5. Conversion Architecture, Transit Map & Same-Day Dispatch
- **Dual Conversion Channels & Phone SSOT:**
  1. Direct call button (`tel:0800416403` / `080-041-6403` - Bo / สุจิตร มานิตยกุล) for urgent buyers with same-day / morning exams.
  2. Emerald Green or Crimson **"แอด LINE ปรึกษา / สั่งซื้อด่วน"** button linking to official LINE OA: `@conpasslen` (`https://line.me/ti/p/~@conpasslen`).
  3. Official Facebook Page link: `https://www.facebook.com/ColorBlindnesss`.
- **Transit & Landmark Guide (No Micro-Address Clutter):**
  - **Rule:** Do NOT write long or micro-detailed street addresses that clutter the layout or expose unnecessary residential details.
  - **Implementation:** State the pickup hub concisely as **"จุดนัดรับด่วน: ย่านลาดพร้าว 48 (นัดหมายเวลาล่วงหน้า)"** and provide an intuitive **Transit Schematic Diagram** mapping:
    - 🟡 **MRT Yellow Line:** สถานีภาวนา (YL02) ~600m (เดิน/วิน 2–3 นาที - จุดใกล้สุด)
    - 🔵 **MRT Blue Line:** สถานีสุทธิสาร (BL17) ทางออก 3 นั่งวินลัดเข้าลาดพร้าว 48 เพียง 5 นาที (เส้นทางเลี่ยงรถติด)
    - 🏢 **Local Landmark Chips:** ปากซอยลาดพร้าว 48, ทางลัดสุทธิสาร-รัชดาภิเษก, ตลาดสะพาน 2, แยกรัชดา-ลาดพร้าว
    - 📍 **One-Tap Google Maps Button:** Direct link opening Google Maps pre-pinned to the Lat Phrao 48 hub.
- **Express Dispatch Prominence:** Prominently state Grab Express 1–2h dispatch in Bangkok, van express (฿1,900 prepaid), and Lat Phrao 48 pickup hub (by appointment) in the top notification strip, hero section, and pricing card. Never claim 24h pickup.

---

## 6. SEO & AEO (AI Engine Optimization) Architecture
Embed complete Schema.org JSON-LD structured data:
- **`Product` / `MedicalDevice`:** Price (฿1,490 THB), brand (*ConPass*), rating (4.9/5).
- **`MedicalWebPage` & `MedicalCondition`:** Target *Red-Green Color Blindness (Deuteranomaly / Protanomaly)*.
- **`FAQPage`:** 4+ structured clinical Q&As answering high-volume search queries.
- **`LocalBusiness`:** Specify the Bangkok emergency pickup hub (*Ladprao 48, Huai Khwang*).
- **Semantic Direct Answer Block:** Include a 40–60 word clear definition in a semantic section for ChatGPT, Gemini, and Google AI Overviews citation.
