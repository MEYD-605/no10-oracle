---
name: clinical-landing-3d-and-tests
description: "Build clinical landing pages with test popups and 3D WebGL."
version: 1.0.0
tags: [clinical-landing, ishihara-test, 3d-threejs, pop-up-modal, conversion-rate-optimization, medical-device, responsive-design]
---

# Clinical Landing Pages with 3D WebGL & Diagnostic Test Popups

Comprehensive guide for designing, building, and deploying high-converting medical and clinical device landing pages (e.g. ConPass color blindness corrective lenses, optical devices), combining real hospital diagnostic test modals, WebGL 3D product inspection, and clean white-surface CRO standards.

---

## 1. Clean White & Clinical Tone Architecture (Anti-Slop)
- **Medical Sterile Aesthetic:**
  - Backgrounds: Pure White `#FFFFFF` with soft slate/subtle warm gray tint `#F8FAFC` for content cards.
  - Text: High-contrast Slate `#0F172A` and Charcoal `#334155`.
  - Clinical Accent: Deep Ruby / Crimson (`#DC2626` / `#E11D48`) denoting precise optical filter spectrums (570–590 nm) and urgency.
  - NEVER use dark-mode / cyberpunk / black-neon layouts for medical products. Clean white backgrounds establish medical authority and clinical safety.
- **Typography:**
  - Headings & Body: `IBM Plex Sans Thai` for modern, clean, loopless medical typography.
  - Numbers & Badges: `Plus Jakarta Sans` for crisp numerical presentation.

---

## 2. Real Medical Diagnostic Test & Pop-up Modal Protocol
- **No Hand-Coded / Synthetic Dot Simulations:**
  - Never draw fake SVG or programmatic canvas dot patterns. They look amateurish and break customer trust.
- **Real Hospital Test Plates (Rutnin-Gimbel SSOT):**
  - Download and serve real scanned Ishihara plates from accredited eye institutions (e.g. Rutnin-Gimbel Eye Centre `rutningimbel.com` 9-plate series: `plate01.gif` to `plate17.gif` under `assets/plates/`).
- **Intuitive Pop-up Modal UX:**
  - Provide a modal (`#test-modal`) triggered from the sticky header, hero CTA, and floating mobile bar (`👁️ แบบทดสอบตาบอดสี (ฟรี)`).
  - Centered plate image with progress indicator (`แผ่นที่ 1 จาก 9`).
  - Interactive multiple-choice answers (`[12]`, `[74]`, `[มองไม่เห็น]`).
  - **Instant Diagnostic Analysis:** On click, display what normal vision sees vs what red-green color deficiency sees.
  - **Direct Conversion Bridge:** Embed a prominent bottom callout:
    *"อ่านตัวเลขไม่ออก หรือมองไม่เห็นตัวเลข? ConPass ช่วยแก้ปัญหาตาบอดสีแดง-เขียว ให้ท่านอ่านผ่านได้ 100% [สั่งซื้อ / ปรึกษาทาง LINE]"*.

---

## 3. Interactive 3D Product Showcase (Three.js WebGL)
- **Lightweight 3D WebGL Rendering:**
  - Embed Three.js (`three.min.js`) to render a smooth, physical-material translucent contact lens dome (`MeshPhysicalMaterial`, roughness: 0.08, transmission: 0.7, IOR: 1.45).
  - Embed a subtle ruby/crimson center filter disc (`570–590 nm Optical Filter`) in the optical zone.
- **Touch & Mouse 360° Interaction:**
  - Support drag and touch rotation on both desktop and mobile so visitors can inspect curvature and optical depth.
- **Dual Visual Switcher:**
  - Include an instant tab toggle between the 3D WebGL viewer and the high-resolution photograph of the actual physical product kit (sealed vial, gold-stamped case, solution).

---

## 4. Multi-Breakpoint Responsive Layout Standards
- **Anti "Sausage Layout" Rule:**
  - Desktop (>1280px): Utilize full width (`max-w-7xl mx-auto px-4 sm:px-6 lg:px-8`) with a 2-column hero split (`lg:grid-cols-12` ~55/45 split).
  - Left column: Headline, trust badges, value bullets, and dual CTAs.
  - Right column: 3D interactive viewer and product kit card.
- **Mobile Sticky Action Bar:**
  - Sticky bottom action bar restricted to mobile only (`block lg:hidden`) with `env(safe-area-inset-bottom)` safe-area padding and `pb-28` on main container.
  - Action buttons: Quick Test trigger + Phone call (`tel:0949989486`) + Direct LINE OA (`https://line.me/ti/p/~@conpass`).

---

## 5. Decision Matrix & Emergency Dispatch SSOT
- **3-Way Comparative Matrix:**
  - Compare ConPass (฿1,490 / 1 Year, natural discrete iris tint, 98.4% pass rate, 1–2h Grab Express) vs Cheap Fashion Lenses (glaring unnatural red tint, exam rejection) vs Doing Nothing (100% exam failure).
- **Emergency Fulfillment Channels:**
  - Grab Express 1–2h dispatch in Bangkok & perimeter.
  - 24h pickup hub at Lat Phrao 48.
  - Free Flash Express nationwide.
