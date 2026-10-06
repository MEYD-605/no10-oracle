---
name: service-seo-and-ad-funnel-synergy-v2
description: "Use for service SEO, dedicated domains, and ad funnels."
version: 2.0.0
author: No.4 MIMO (maclab:04-mimo)
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [seo, google-ads, landing-pages, astro, cloudflare-pages, dedicated-domains, schema-org, local-seo, quality-score, lead-capture, mattermost, cpc-optimization, landmark-seo, temple-clustering, billing-prelaunch]
---

# Local Service SEO, Dedicated Domains & Google Ads Funnel Synergy (v2)

Standardized operational playbook for architecting high-speed local service SEO landing pages (Astro + Cloudflare Pages), structuring dedicated domain strategies for sensitive/solemn verticals, boosting Google Ads Quality Score, eliminating mobile app bounce rates, targeting hyper-local venue clusters, separating pre-launch campaign scaffolding from billing, and routing captured leads in real time to team chat (Mattermost / LINE).

---

## 1. Dedicated Domain vs Subfolder Strategy for High-Intent Verticals

When expanding into specialized, high-intent, or solemn service lines (e.g. Funeral Photography `ช่างภาพงานศพ 24 ชม.`):

### Why Dedicated Standalone Domains Win
1. **Brand Solemnity & Emotional Trust**: 
   - Sensitive life events (funerals, memorials, hospital transfers) require solemnity, dignity, and specialized professionalism.
   - Hosting solemn services under a festive graduation/party photography domain (`clubsxai.com/funeral`) dilutes brand perception and causes emotional friction for grieving families.
   - Dedicated domains (e.g. `funeralphotobkk.com`, `thaifuneralphoto.com`) establish instant authority and empathy.
2. **Google Ads Quality Score & Ad Relevance**:
   - Google Ads evaluates Display URL and Landing Page relevance directly against user search terms.
   - An exact-match domain in the search snippet significantly lifts Expected CTR (+15–25%) and raises Quality Score to 8–10/10, cutting CPC in half.
3. **Zero-Overhead Edge Deployment**:
   - Cloudflare Pages + DNS allows pointing a newly registered domain (`.com`) to an Astro static landing page in < 2 minutes with automatic SSL and global CDN caching.

---

## 2. The Mobile Ad Friction Trap & Architectural Fix

### The Anti-Pattern
Sending Google Search Ads mobile clicks directly to a Facebook Page or social profile causes **90–95% drop-off (bounce rate)** because:
- Mobile webviews force authentication login prompts.
- Deep links to native Facebook apps fail intermittently across iOS/Android.
- Google Ads Quality Score drops to 3–5/10 due to poor page experience and slow redirect latency, doubling CPC.

### The High-Conversion Architecture
```text
[ Google Search Ads / Organic Search ]
                 │
                 ▼ (< 1s Edge Load)
[ High-Speed Dedicated Landing Page (Astro / Cloudflare Pages) ]
  ├── 1. PhotographyBusiness / LocalBusiness Schema (JSON-LD) + FAQPage Schema
  ├── 2. Hero Proof: Portfolio Grid + Clear 24-hr Delivery USP + Exact Base Rates
  ├── 3. Hyper-Local Venue Matrix (Top 12 Hubs / Landmark Clusters)
  ├── 4. Sticky Floating CTA: [ 📞 โทรจองด่วน ] + [ 🟢 แอด LINE เช็คคิว ]
  └── 5. Real-time Lead Form Webhook
                 │
                 ▼
[ Mattermost Omnichannel Inbound (#inbox-funeral / #inbox-facebook / #inbox-line) ]
```

---

## 3. Pre-Launch Campaign Scaffolding vs Billing Separation

When preparing new ad accounts or service launches:
1. **Full Pre-Launch Configuration**: Build complete campaign structures, ad groups, keyword sets, 250+ negative keywords, responsive search ad copies, call extensions, and conversion tracking before attaching a credit card or funding the account.
2. **Promotional Voucher Synchronization**:
   - Claim new advertiser promotional vouchers (e.g. Spend ฿15,000 get ฿15,000 credit) under **Billing ➔ Promotions** within the first 14–30 days of account activation.
   - Note that promotional credits are spend-match rebates applied automatically 5–7 days after hitting the spend threshold within the 60-day qualifying window.
3. **Location Target Guard (`PRESENCE Only`)**:
   - Always verify campaign location settings are set to `PRESENCE` (People in or regularly in your targeted locations) rather than `PRESENCE_OR_INTEREST` to prevent non-local budget bleed.

---

## 4. SEO Pillars for Local & Solemn Service Businesses

### 1. JSON-LD Local Business & FAQPage Schema
Always inject structured data into the `<head>` of service landing pages to feed Google AI Overviews and Search:
```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "PhotographyBusiness",
      "name": "ช่างภาพงานศพ กรุงเทพ 24 ชม. - บริการบันทึกภาพพิธีการ",
      "url": "https://funeralphotobkk.com",
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

## 5. Mattermost Team Hub & Channel Hierarchy Integration

Keep internal discussions strictly separate from inbound customer chat streams:

```text
[ Mattermost Channels ]
  ├── 02 | 📸 แผนกช่างภาพ Club S        ➔ Internal grad & event coordination
  ├── 03 | 🖤 แผนกช่างภาพงานศพ 24 ชม.   ➔ Internal solemn ceremony packages & crew scheduling
  ├── 06 | 📥 ลูกค้า FB: 📸 Club S      ➔ Direct customer messages from Club S Facebook
  └── 07 | 📥 ลูกค้า FB: 🖤 งานศพ 24 ชม. ➔ Direct customer messages from Funeral Facebook
```

In automated bots and executive daily digests, include all inbound customer channels (`inbox-facebook`, `inbox-funeral`, `inbox-conpass`, `inbox-line`) in daily SQL volume calculations.

---

## 6. Key Pitfalls & Hardened Rules

1. **Brand Context Collision**: Never host solemn ceremony services on party/grad domains. Use dedicated domains for proper emotional tone and maximum Google Ads Quality Score.
2. **The Trailing Slash / Redirect Loop Trap**: Cloudflare Pages with Astro static builds must handle 301 canonical redirects properly. Ensure `trailingSlash: 'never'` or `'always'` is consistent across `astro.config.mjs` and Google Ads final URLs.
3. **Missing Geo Exclusion**: Always enforce `Presence only` in Google Ads campaign location settings (exclude non-service provinces) to prevent ad budget waste.
4. **Internal vs Customer Chat Bleed**: Never conduct internal staff discussions inside customer webhook channels (`inbox-*`). Always route team discussions to dedicated departmental channels (`photo-*`).
