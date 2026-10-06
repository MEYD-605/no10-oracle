---
name: conpass-landing-and-funnels-v2
description: "Build, deploy, and audit landing pages for ConPass lenses."
version: 1.1.0
tags: [conpass, landing-page, marketing, funnels, responsive, seo]
---

# ConPass Landing Page & Conversion Funnel Standards

Comprehensive design, copywriting, SEO, and operational guide for building and optimizing high-converting landing pages and sales funnels for **ConPass** (คอนแทคเลนส์เพื่อช่วยให้เห็นตัวเลข).

## 1. Value Proposition & Copywriting Standards

- **Core Framing**: Use safe, attractive, and high-converting commercial phrasing: **"คอนแทคเลนส์เพื่อช่วยให้เห็นตัวเลข"** (contact lenses to help see numbers) and **"เตรียมความพร้อมก่อนตรวจสุขภาพ"**. Avoid overt or absolute medical claims (*"ผ่าน 100%"*, *"รักษาหายขาด"*).
- **Respectful Selection Guide (Do NOT Devalue Glasses)**:
  - We offer both color blindness glasses and contact lenses.
  - **แว่นตาบอดสี**: เหมาะสำหรับใช้ชีวิตประจำวัน, ทำงานหน้าจอคอมพิวเตอร์, ขับรถท่องเที่ยว โดยไม่ต้องสัมผัสกระจกตา.
  - **คอนแทคเลนส์ ConPass**: ออกแบบเฉพาะเพื่อการตรวจคัดกรองที่ต้องการความเนียนตาเป็นพิเศษ (ตรวจสุขภาพเข้างานโรงงาน, ช่างเทคนิค, งานต่างประเทศ EPS) ที่ไม่สามารถใส่แว่นกรอบหนาสะดุดตาได้.
- **Accurate Lifespan & Storage Terminology**:
  - Unopened vial: 1 Year (*ขวดแก้วซีลสูญญากาศยังไม่เปิดขวด เก็บได้ 1 ปี*).
  - Opened lens: 1 Month (*หลังเปิดขวดใช้งานมีอายุ 1 เดือน*).
  - Headline format: `อายุเก็บรักษา 1 ปี*` with subtitle `*(ยังไม่เปิดขวด / เปิดแล้วใช้ได้ 1 เดือน)`.
- **Do NOT use interactive SVG / simulated Ishihara plates in main hero**: Focus hero real estate on social proof, delivery speed, opto-lab standards, and direct CTAs. Place test plates in dedicated modal/section.

---

## 2. Responsive Layout, UI/UX & CTA Rules

- **Full Desktop Responsiveness**: Never constrain desktop layouts inside fixed mobile wrappers (e.g. `max-w-xl` on body). Use fluid containers (`max-w-7xl mx-auto`) with responsive grids (`grid-cols-1 md:grid-cols-2 lg:grid-cols-3`).
- **Header & Action Bar Motion Hierarchy**:
  - **Header Phone Button**: Use subtle halo/radar pulse animation (`animate-call-halo`) to draw immediate eye attention for hot-calls.
  - **Bottom Floating Sticky Bar**: Keep the phone call button clean, static, and stable (no distracting jitter/shake). Place micro-motion only on the "ทดสอบ" (Test) action.
- **Pickup Hub & Transit Map**: State the pickup hub concisely as **"จุดนัดรับด่วน: ย่านลาดพร้าว 48 (นัดหมายล่วงหน้า)"** (NEVER claim "24 hours"). Provide transit landmarks (MRT ภาวนา / MRT สุทธิสาร ทางออก 3) and direct Google Maps link.
- **Sticky CTA Bar & Safe Area Padding**: Floating bottom action bars must include safe-area padding (`padding-bottom: calc(1rem + env(safe-area-inset-bottom))`) and the main page container must have `pb-28` to prevent covering footer FAQs or disclaimers.

---

## 3. Technical On-Page SEO & Structured Data Architecture

- **Strict On-Page SEO Quality Standards**:
  - **Title Length**: 40–70 characters (avoids Google SERP desktop & mobile truncation). Must include target keyword + USP + brand.
  - **Meta Description**: 120–200 characters. Must summarize benefits, primary target audience, phone hotline `080-041-6403`, and key location/logistics advantage.
  - **Heading Hierarchy**: Exactly one `<h1>` per page (unique and descriptive). Semantic `<h2>` and `<h3>` tags used for section structure without skipping heading levels.
  - **Image Alt Tags**: 100% coverage across all images for image search and accessibility (zero missing `alt` attributes).
  - **Social Sharing (OG & Twitter)**: Every page must declare `og:title`, `og:description`, `og:image`, `og:url`, `og:type`, and `twitter:card`.
- **Schema.org JSON-LD**: Every deployment must include embedded JSON-LD containing:
  - `WebSite`: Canonical URL, title, description.
  - `Product`: Brand ConPass, offers price 1,490 THB, availability `InStock`.
  - `LocalBusiness` / `MedicalBusiness`: Address, phone `080-041-6403`, geo coordinates, opening hours.
  - `FAQPage`: Question & Answer schema covering lifespan, delivery, and testing plates.
- **Robots & Sitemap**:
  - `robots.txt` must explicitly declare `Sitemap: https://conpasslens.com/sitemap.xml`.
  - `sitemap.xml` must declare `<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">` with `<loc>`, `<lastmod>`, `<changefreq>`, and `<priority>`.
- **Cloudflare Pages Routing & SEO Audit Probing**:
  - Cloudflare Pages automatically redirects `.html` requests to clean URLs with HTTP 308 (e.g. `/korea-eps.html` -> `/korea-eps`).
  - When performing automated SEO audits with `audit_page_seo`, audit the clean URL path directly (`https://conpasslens.com/korea-eps`) to verify HTTP 200 without redirect noise.
  - Verification scripts probing live domains must send a standard browser header (`User-Agent: Mozilla/5.0...`) because Cloudflare WAF blocks Python's default User-Agent (`Python-urllib/3.x`) with HTTP 403.

---

## 4. Official Channels & Commercial SSOT

| Channel / Item | Official Details |
| :--- | :--- |
| **LINE Official Account** | **`@conpasslen`** (`https://line.me/ti/p/~@conpasslen`) — *Note: no trailing 's'* |
| **Facebook Official Page** | **`https://www.facebook.com/ColorBlindnesss`** |
| **Primary Phone** | **`080-041-6403`** (สุจิตร มานิตยกุล / Bo) · `tel:0800416403` |
| **Pricing** | **1,490 THB** per set (โปรโมชั่นพร้อมของแถม + บริการจัดส่งฟรี) |
| **Payment Accounts** | • **KBank**: `051-2-97876-2` (สุจิตร มานิตยกุล)<br>• **SCB**: `111-508-3127` (สุจิตร มานิตยกุล)<br>• **PromptPay**: `080-041-6403` (สุจิตร มานิตยกุล) |
| **Logistics Options** | • Standard Parcel: ฿1,490 free delivery<br>• Bangkok Same-Day Grab: ฿1,490 + Grab courier fee<br>• Provincial Express Van (รถตู้ด่วน): ฿1,900 (Prepayment only) |
