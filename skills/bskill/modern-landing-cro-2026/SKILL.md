---
name: modern-landing-cro-2026
description: "Use when building modern 2026 landing pages and CRO."
version: 1.0.0
tags: [landing-page, cro, modern-web-2026, bento-grid, ui-ux, conversion-rate-optimization]
---

# Modern 2026 Landing Page & CRO Design Standards

Operational guidelines for building high-converting, modern 2026 web landing pages and conversion funnels, avoiding outdated AI-slop/2010s layouts and enforcing contemporary UI/UX standards.

---

## 1. 2026 Aesthetic & Layout Rules
- **No 2010s / AI-Slop Clutter:**
  - Strictly prohibit flat full-bleed solid color bands, loud rainbow gradients, or oversized cartoon emoji bullet points.
  - Never use amateurish interactive gimmicks (e.g. hand-coded canvas/SVG test dot simulations) that reduce brand credibility and waste mobile viewport height.
- **Bento Grid Architecture:**
  - Use structured, asymmetric Bento cards with subtle borders and shadows: `bg-white border border-gray-100/200 shadow-sm rounded-2xl p-6`.
  - Add micro-interactions: `hover:border-teal-500/30 hover:shadow-md transition-all duration-200`.
  - Use high-contrast dark hero / pricing surfaces (`bg-gray-900 border border-gray-800 text-white rounded-3xl p-8`) to anchor commercial offers.
- **Micro-Contrast & OLED Readability (WCAG AAA):**
  - Dark-card secondary and tertiary text must remain legible on low-brightness mobile screens: use `text-gray-300` or `text-gray-400` (never low-luminance `text-gray-500` or `text-gray-600` on dark backgrounds).
  - Primary call-to-action buttons must maintain crisp contrast (e.g. bright emerald green `#10B981` / `#059669` with bold white text).

---

## 2. Multi-Breakpoint Responsive Standards
- **Anti "Sausage Layout" Rule:** Never wrap the entire document inside a narrow mobile container (`max-w-xl` on body). On desktop screens (>1280px), utilize full width (`max-w-7xl mx-auto px-4 sm:px-6 lg:px-8`) with multi-column grids (e.g. 55/45 split in hero section).
- **Mobile Sticky Action Bar:** Bottom CTA bars must be restricted to mobile only (`block lg:hidden`) with safe-area padding (`env(safe-area-inset-bottom)`), and the page bottom must have padding (`pb-28`) so floating bars never obscure footer FAQs or disclaimers.

---

## 3. Visual Verification Gate
- **Headless Browser Visual Inspection:** Always execute headless browser capture (`browser_exec`) and multi-section visual inspection (`vision_analyze`) across desktop and mobile views before shipping to live CDNs.
