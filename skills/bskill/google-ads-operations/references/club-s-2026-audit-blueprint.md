# Club S Google Ads Audit & Modern Funnel Blueprint (2026)

## Campaign & Account Profile
- **Account CID**: `9657319650` ("ช่างภาพ ส่งงานไว")
- **Service Domain**: Photography (Graduation, Weddings, Events, Profiles, Ceremonies)
- **Primary Market**: Bangkok & Metropolitan Region (Nonthaburi, Pathum Thani, Samut Prakan, Samut Sakhon, Nakhon Pathom)
- **Core Value Proposition**: Full photo delivery in 24 hours ("ส่งงานไว 24 ชม.")

---

## 1. Multi-Year Performance Trajectory (2024 - 2026)

| Period | Impressions | Clicks | CTR | Avg CPC | Total Spend | Conv. Recorded |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **2024** | 693,309 | 13,365 | 1.93% | ฿2.54 | ฿34,003 | 0.0 |
| **2025** | 907,965 | 28,556 | 3.15% | ฿3.24 | ฿92,382 | 0.0 |
| **2026 (YTD Sep)** | 245,795 | 14,685 | 5.97% – 7.20% | ฿4.36 – ฿4.77 | ฿64,061 | 0.0 |
| **Cumulative** | **1,847,069** | **56,606** | **3.06%** | **฿3.36** | **฿190,447** | **0.0** |

---

## 2. Key Diagnosis & Discovered Pitfalls

### 1. Location Targeting Bleed & Strategic Core Coverage
- **Problem**: Default positive geo target type was `Presence or Interest`.
- **API Audit Evidence**:
  - `PRESENCE` (In target area): 904 clicks, 4,309 THB
  - `LOCATION_OF_INTEREST` (Outside target area): 875 clicks, 4,181 THB (49.2% waste)
- **Remedy & Target Geographic SSOT**:
  - Switch positive geo target to `PRESENCE` only in campaign settings.
  - Core Focus Areas: Bangkok & Metropolitan Region (Nonthaburi, Pathum Thani, Samut Prakan, Nakhon Pathom).
  - Explicit Service Hubs:
    - **Samut Sakhon / Ekachai** (P'Mo base)
    - **Udom Suk / Bang Na** (Eastern corridor)
  - Exclude outlying provinces (Kanchanaburi, Suphan Buri, Chachoengsao) to prevent budget bleed.

### 2. Destination Friction (Mobile Webview Drop-off)
- **Problem**: Final URL sent mobile traffic (95.1% of total) to a Facebook post URL (`facebook.com/share/...`).
- **Impact**: Mobile in-app browser prompts login barrier and prevents seamless direct Messenger conversion. Main domain `clubsxai.com` had a broken deployment pipeline returning HTTP 404.
- **Remedy**: Direct to LINE OA (`lin.ee/ztIojKN`) or fast-loading landing page with sticky LINE/Call CTAs.

### 3. Broad Match Search Term Pollution
- **Problem**: Broad keyword `ช่าง ภาพ` accounted for 1,022 clicks (4,854 THB, 57% spend).
- **Major Negative Clusters**:
  - Passport / 1-inch ID photos: `ร้านถ่ายรูปใกล้ฉัน`, `ถ่ายรูป 1 นิ้ว`, `ถ่ายรูปติดบัตร` (166 clicks / 806 THB)
  - Studio rental (Aircon studio): `สตูดิโอถ่ายรูปใกล้ฉัน`, `สตูดิโอให้เช่า`
  - Sub-market pricing / Free: `ช่างภาพครึ่งวัน 1000` (129 clicks / 620 THB), `ฟรีแลนซ์ 500`
  - Equipment & Camera gear: `เช่ากล้อง`, `กล้องมือสอง`

### 4. Single Monolithic Ad Group (Low Quality Score / Lost to Rank)
- **Problem**: All categories combined in 1 Ad Group. Lost to Rank is 82.8%.
- **Remedy**: Split into 3 specialized Ad Groups: `[Wedding & Prewedding]`, `[Graduation & Portrait]`, `[General & Urgent Photography]`.

---

## 3. Financial & Conversion Projection

| Metric | Before (Current) | Target (Phase 1-2) | Delta |
| :--- | :---: | :---: | :---: |
| **Monthly Budget** | ฿8,500 | ฿8,500 | Same |
| **Wasted Out-of-Area Spend** | ฿4,180 (49%) | ฿0 (0%) | **-฿4,180 Saved** |
| **Targeted Clicks** | ~900 | ~1,600 – 1,800 | **+80% Quality Traffic** |
| **Inquiry Rate (CVR)** | **< 0.5%** | **3.5% – 5.0%** | **7x – 10x Increase** |
| **Inquiries / Month** | 4 – 8 | 55 – 85 | **50+ Leads / Month** |
| **Cost per Inquiry (CPL)** | ฿1,060 – ฿2,125 | ฿100 – ฿155 | **-90% CPL Reduction** |
| **Booked Jobs (20% Close)** | 1 – 2 | 11 – 17 | **Strong Revenue Growth** |

---

## 4. Modern Funnel Configuration for Thai Local Services (2026)

```text
[ Google Search Ad ] 
  ├── Primary Headline: "ช่างภาพมืออาชีพ ส่งงานไว 24 ชม."
  ├── Message Asset: [ LINE แชทจองคิว ] -> lin.ee/ztIojKN
  ├── Call Asset: [ โทรปรึกษาด่วน ] -> 080-041-6403
  └── Sitelinks / Final URL: 
        └── Mobile-First Landing Page (clubsxai.com)
              ├── 24hr Fast Delivery Banner
              ├── 6-9 High-Impact Portfolio Grid
              ├── Transparent Tiered Packages
              └── Sticky Footer: [ ทัก LINE ] + [ โทรจองคิว ]
```
