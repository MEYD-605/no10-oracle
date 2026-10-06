---
name: service-seo-and-ad-funnel-synergy
description: "Build service SEO landing pages and sync leads to team chat."
version: 1.2.0
author: No.4 MIMO (maclab:04-mimo)
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [seo, google-ads, landing-pages, astro, cloudflare-pages, schema-org, local-seo, quality-score, lead-capture, mattermost, cpc-optimization, landmark-seo, temple-clustering]
---

# Local Service SEO & Google Ads Funnel Synergy Playbook

Standardized operational playbook for architecting high-speed local service SEO landing pages (Astro + Cloudflare Pages), boosting Google Ads Quality Score, eliminating mobile app bounce rates, targeting hyper-local venue clusters (e.g. high-volume temples/hubs), mining historical chat archives for conversion copy, and routing captured leads in real time to team chat (Mattermost / LINE).

---

## 1. The Mobile Ad Friction Trap & Architectural Fix

### The Anti-Pattern
Sending Google Search Ads mobile clicks directly to a Facebook Page or social profile causes **90–95% drop-off (bounce rate)** because:
- Mobile browsers force authentication login prompts.
- Deep links to native Facebook apps fail intermittently across iOS/Android.
- Google Ads Quality Score drops to 3–5/10 due to poor page experience and slow redirect latency, doubling CPC.

### The High-Conversion Architecture
```text
[ Google Search Ads / Organic Search ]
                 │
                 ▼ (< 1s Edge Load)
[ High-Speed Static Landing Page (Astro / Cloudflare Pages) ]
  ├── 1. PhotographyBusiness / LocalBusiness Schema (JSON-LD) + FAQPage Schema
  ├── 2. Hero Proof: Portfolio Grid + Clear 24-hr Delivery USP + Exact Base Rates
  ├── 3. Hyper-Local Venue Matrix (Top 12 Hubs / Landmark Clusters)
  ├── 4. Sticky Floating CTA: [ 📞 โทรจองด่วน ] + [ 🟢 แอด LINE เช็คคิว ]
  └── 5. Real-time Lead Form Webhook
                 │
                 ▼
[ Mattermost Omnichannel Inbound (#inbox-facebook / #inbox-line) ]
```

---

## 2. Google Ads Quality Score & CPC Halving Strategy

Google Ads calculates ad rank and CPC using `Quality Score (1-10)` based on:
1. **Expected CTR**: Highly targeted ad copy mentioning location and delivery guarantee (e.g. *"ส่งรูปไวใน 24 ชม."*).
2. **Ad Relevance**: Ad headlines must match landing page `H1` exactly (e.g. `ช่างภาพ Portrait กรุงเทพ ส่งรูปด่วน 24 ชม.` or `ช่างภาพงานศพ กรุงเทพ ถึงวัดใน 2 ชม.`).
3. **Landing Page Experience**: Static CDN hosting on Cloudflare Pages ensures Core Web Vitals score 95–100/100 and First Contentful Paint (FCP) < 800ms.

**Result**: Quality Score climbs to **8–10/10**, reducing average CPC from ~฿4.80 down to ~฿2.40 per click.

---

## 3. SEO Pillars for Local & Solemn Service Businesses

### 1. JSON-LD Local Business & FAQPage Schema
Always inject structured data into the `<head>` of service landing pages to feed Google AI Overviews and Search:
```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "PhotographyBusiness",
      "name": "Club S Photography - Funeral & Solemn Ceremonies",
      "url": "https://clubsxai.com/funeral",
      "telephone": "+66XXXXXXXXX",
      "priceRange": "฿1,500 - ฿3,500",
      "address": {
        "@type": "PostalAddress",
        "addressLocality": "Bangkok",
        "addressCountry": "TH"
      },
      "areaServed": ["Bangkok", "Nonthaburi", "Samut Prakan", "Pathum Thani"],
      "openingHours": "Mo-Su 00:00-24:00"
    },
    {
      "@type": "FAQPage",
      "mainEntity": [
        {
          "@type": "Question",
          "name": "จองช่างภาพงานศพด่วนวันนี้ เดินทางถึงศาลาทันไหม?",
          "acceptedAnswer": {
            "@type": "Answer",
            "text": "รับงานด่วน 24 ชม. ทั่วกรุงเทพฯ และปริมณฑล ทีมช่างภาพสามารถเดินทางถึงศาลาวัดภายใน 2 ชั่วโมง"
          }
        },
        {
          "@type": "Question",
          "name": "ส่งรูปไวสุดภายในกี่วัน?",
          "acceptedAnswer": {
            "@type": "Answer",
            "text": "ส่งภาพไฮไลต์เบื้องต้นภายใน 24 ชม. และส่งงานครบทุกภาพปรับแสงสีสมเกียรติผ่าน Cloud ภายใน 3 วัน"
          }
        }
      ]
    }
  ]
}
</script>
```

### 2. Hyper-Local Landmark & Venue Cluster Matrix
For specialized or urgent local services (e.g. funeral photography `ช่างภาพงานศพ`), pair high-intent terms with high-volume venue clusters:
- **Sukhumvit / City Center**: วัดธาตุทอง (BTS Ekkamai), วัดหัวลำโพง (Sam Yan / Silom), วัดยานนาวา (Sathon)
- **Rattanakosin / Dusit / Pom Prap**: วัดมกุฏกษัตริยาราม, วัดโสมนัสราชวรวิหาร, วัดเทพศิรินทราวาส, วัดตรีทศเทพ
- **Bang Khen / Don Mueang**: วัดพระศรีมหาธาตุวรมหาวิหาร (Bang Khen - high funeral volume), วัดดอนเมือง
- **Nonthaburi / Pak Kret**: วัดชลประทานรังสฤษดิ์, วัดบัวขวัญ พระอารามหลวง
- **Thonburi Hubs**: วัดชินวราราม, วัดเจ้าอาม

Explicitly reference these venues in landing page subheadings, copy, and alt tags to rank #1 when searchers query `ช่างภาพงานศพ [ชื่อวัด]`.

---

## 4. Mining Historical Chat Archives for High-Converting Copy

Before writing landing page copy or FAQ sections, mine local conversation and booking archives (`notion_bookings_snapshot.json`, `customer_questions_analysis.json`, `messages_since_*.json`):
1. **Identify Top Customer Anxieties**:
   - Turnaround speed ("กี่วันได้รูป?").
   - Package boundaries ("สวดอภิธรรม กับ ฌาปนกิจ ต่างกันยังไง?").
   - Urgency & response time ("จองวันนี้ ถ่ายเย็นนี้ทันไหม?").
2. **Convert Objections into Hero USPs**:
   - Place direct answers to top anxieties in the hero section and FAQ accordion.
   - Eliminates friction before the customer even asks in chat.

---

## 5. Cross-Vertical Ad Intelligence & Negative Keyword Re-Use

When launching a new specialized vertical (e.g. funeral photography):
1. **Negative Keyword Porting**: Immediately import established 250+ negative keyword lists from parent photography accounts (e.g. *ฟรี, สอน, กล้อง, เลนส์, pantip, สมัครงาน, ดารา, งานศพคนดัง*) to eliminate click waste on day 1.
2. **Strict Location Guard (`PRESENCE Only`)**: Enforce `PRESENCE` (people in or regularly in targeted locations) to stop non-local click leakage.
3. **Mobile-First Bid Adjustments**: Set mobile device bids to +80–90% with prominent **Call Extensions** and direct **LINE OA** deep-links for instant emergency bookings.

---

## 6. Real-time Lead Capture to Mattermost & Chatwoot

Embed zero-latency lead capture endpoints on the landing page:

```javascript
// Lightweight CTA trigger sending lead to internal team webhook
async function handleLeadSubmit(event) {
  event.preventDefault();
  const payload = {
    customer_name: document.getElementById('name').value,
    phone: document.getElementById('phone').value,
    service: document.getElementById('service').value,
    date: document.getElementById('target_date').value,
    source: 'Google Ads / clubsxai.com'
  };

  await fetch('/api/lead-capture', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  });
}
```

The backend webhook dispatches an interactive card to Mattermost `#inbox-facebook` / `#inbox-line` with instant mobile push notifications for staff.

---

## 7. Key Pitfalls & Verification Rules

1. **The Trailing Slash / Redirect Loop Trap**: Cloudflare Pages with Astro static builds must handle 301 canonical redirects properly. Ensure `trailingSlash: 'never'` or `'always'` is consistent across `astro.config.mjs` and Google Ads final URLs to prevent paid ad click bounce.
2. **Missing Geo Exclusion**: Always enforce `Presence only` in Google Ads campaign location settings (exclude non-service provinces like Kanchanaburi or distant regions) to prevent ad budget waste.
3. **Hidden Pricing Friction**: Hiding service prices forces prospective clients to bounce. Display base pricing clearly (e.g. *เริ่มต้น 1,500.-*) to qualify leads before they click the CTA.
4. **Neglecting Landmark Intent**: Omitting specific high-volume venue names (e.g., specific major temples) causes search engines to favor generic directories instead of direct local service providers.
