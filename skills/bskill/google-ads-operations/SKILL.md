---
name: google-ads-operations
description: Use when managing, auditing, or automating Google Ads APIs.
version: 1.1.0
license: MIT
author: hermes-gads-team
metadata:
  category: marketing
  tags: [google-ads, gaql, mcp, sdk, automation, reporting]
  related_skills: [google-ads-offline-conversions, gm-sop-review]
---

# Google Ads Operations & Automation

## When to Use

- Managing, auditing, querying, or analyzing Google Ads accounts and campaigns.
- Ingesting and processing historical Google Ads CSV/ZIP exports (search terms, keywords, CVR, CPA).
- Setting up Google Ads API Python SDK, GAQL queries, or MCP server integrations.
- Writing or running automation scripts in `ψ/tools/` or `ψ/tools/google-ads/`.

## Safety & Governance Policy

1. **Read-Only Default**: Fleet accounts (e.g. "ช่างภาพ ส่งงานไว", Customer ID `9657319650` via `~/.google-ads/google-ads.yaml`) are **STRICTLY READ-ONLY** for autonomous agents.
2. **No Mutating Actions Without Explicit Approval**: Never add negative keywords, adjust bids, enable/pause ad groups, or modify budgets without direct user sign-off.
3. **Execution Honesty**: Never claim a library or tool is installed without running the actual install command and verifying its binary / import live.

## Authentication & Architecture

### 1. Provisioning & Credentials Architecture

To set up or audit API access across accounts:
1. **Developer Token**: Issued from the MCC (Manager Account) API Center.
2. **GCP Project & OAuth 2.0 Client**: Desktop App OAuth Client ID and Secret in Google Cloud Console.
3. **Refresh Token Generation**: Run local OAuth authorization flow (`http://localhost:8080` or `8090`) to grant access and persist a long-lived `refresh_token`.
4. **Configuration Storage**: Store under `~/.google-ads/google-ads.yaml` or account-specific files (e.g. `~/.google-ads/google-ads-conpass.yaml`).

### 2. OAuth Consent URL & Direct Token Exchange Workflow

When generating authorization links for human account owners:
1. **Consent URL Construction**:
   Include `prompt=consent`, `access_type=offline`, `scope=https://www.googleapis.com/auth/adwords`, and `login_hint=<email>` so Google automatically selects the target account without account-switching confusion.
2. **Redirect & Token Exchange**:
   Redirect URI defaults to `http://localhost:8080/`. When the user approves, Google redirects to `http://localhost:8080/?code=4/0A...`. Parse the `code` parameter from the URL query and POST to `https://oauth2.googleapis.com/token` with:
   - `code`: Authorization code
   - `client_id`: OAuth Client ID
   - `client_secret`: OAuth Client Secret
   - `redirect_uri`: `http://localhost:8080/`
   - `grant_type`: `authorization_code`
3. Persist the returned `refresh_token` immediately into the corresponding YAML configuration.

### 3. Direct Python SDK (`google-ads`) vs MCP Server (`google-ads-mcp`)

| Component | Direct Python SDK (`google-ads>=31.0`) | `google-ads-mcp` |
| :--- | :--- | :--- |
| **Auth Method** | `google-ads.yaml` (OAuth Client ID / Secret / Refresh Token) | Application Default Credentials (ADC) via `gcloud` |
| **Stability** | ⭐ High (no token expiration during background cron) | ⚠️ Sensitive to Google Cloud ADC / environment state |
| **Dependency** | Standard PyPI package | Requires `mcp<2` pin (uses legacy FastMCP) |
| **Recommendation** | **Primary choice for fleet scripts & reports** | Secondary / standalone CLI tool |

### 4. Loading Credentials in Python

```python
from google.ads.googleads.client import GoogleAdsClient
import os

# Preferred: Load from standard YAML path
config_path = os.path.expanduser("~/.google-ads/google-ads.yaml")
client = GoogleAdsClient.load_from_storage(config_path, version="v23")
ga_service = client.get_service("GoogleAdsService")
```

### 5. GAQL Query Pattern

```python
query = """
    SELECT
        campaign.id,
        campaign.name,
        campaign.status,
        metrics.impressions,
        metrics.clicks,
        metrics.cost_micros,
        metrics.conversions
    FROM campaign
    WHERE segments.date DURING_CURRENT_MONTH
    ORDER BY metrics.cost_micros DESC
"""
response = ga_service.search_stream(customer_id="9657319650", query=query)
for batch in response:
    for row in batch.results:
        cost = row.metrics.cost_micros / 1_000_000
        print(f"{row.campaign.name}: {row.metrics.clicks} clicks, {cost:.2f} THB")
```

## Mutation Patterns (SDK v23+)

### 1. Campaign Geo Target Type (Presence Only)
To switch campaign location targeting from `PRESENCE_OR_INTEREST` to `PRESENCE` (stopping location budget bleed):
```python
from google.protobuf import field_mask_pb2

campaign_service = client.get_service("CampaignService")
campaign_op = client.get_type("CampaignOperation")
c = campaign_op.update
c.resource_name = f"customers/{customer_id}/campaigns/{campaign_id}"
c.geo_target_type_setting.positive_geo_target_type = client.enums.PositiveGeoTargetTypeEnum.PRESENCE

mask = field_mask_pb2.FieldMask(paths=["geo_target_type_setting.positive_geo_target_type"])
client.copy_from(campaign_op.update_mask, mask)
campaign_service.mutate_campaigns(customer_id=customer_id, operations=[campaign_op])
```

### 2. Campaign Criterion Removal & Batch Negative Keywords
To remove stray location radius pins or inject batch negative keywords:
```python
crit_service = client.get_service("CampaignCriterionService")

# Removal of criteria (e.g. proximity pin):
rm_op = client.get_type("CampaignCriterionOperation")
rm_op.remove = f"customers/{customer_id}/campaignCriteria/{campaign_id}~{criterion_id}"
crit_service.mutate_campaign_criteria(customer_id=customer_id, operations=[rm_op])

# Batch Negative Keywords upload (in chunks of 50-100):
operations = []
for word in negative_words_chunk:
    op = client.get_type("CampaignCriterionOperation")
    crit = op.create
    crit.campaign = f"customers/{customer_id}/campaigns/{campaign_id}"
    crit.negative = True
    crit.keyword.text = word
    crit.keyword.match_type = client.enums.KeywordMatchTypeEnum.BROAD
    operations.append(op)
crit_service.mutate_campaign_criteria(customer_id=customer_id, operations=operations)
```

## Historical Data Ingestion & Analysis Protocol

When analyzing large historical CSV/ZIP exports (e.g. 7-year archives):
1. **Unpack to Scratch / Temp Space**: Extract files safely to `/tmp` or cache directory.
2. **Data Cleaning & Standardization**:
   - Unify header column names across different Google Ads UI export versions (e.g., `Search term` vs `Search Keyword`, `Impr.` vs `Impressions`).
   - Strip currency symbols (`฿`, `$`, `,`) and convert to float/int.
   - Strip percentage symbols (`%`) and convert to 0.0–1.0 ratio.
3. **Core Analysis Metrics**:
   - **N-Gram Analysis**: Extract 1-word, 2-word, and 3-word tokens to identify high-converting themes and recurring waste terms.
   - **Long-tail Conversion Rates**: Identify search queries with high conversion rates (>5%) to promote to exact match keywords.
   - **Zero-Conversion Spend Waste**: Aggregate non-converting queries with >10 clicks for negative keyword candidates.

See [references/club-s-historical-benchmark.md](references/club-s-historical-benchmark.md) for the 7-year historical benchmark dataset for Club S Photography, [references/conpass-historical-benchmark.md](references/conpass-historical-benchmark.md) for the ConPass color blindness campaign benchmark (2017–2026, 86.2k clicks, male-heavy demographic, high-CTR lens keywords), and [references/club-s-2026-audit-blueprint.md](references/club-s-2026-audit-blueprint.md) for the 2026 local service audit findings, location bleed remediation, and modern funnel architecture.

## Pitfalls & Lessons Learned

- **Protobuf FieldMask Handling (`google-ads>=v23`)**: In modern Google Ads Python SDK, `client.get_type('FieldMask')` raises a `ValueError`. Use `from google.protobuf import field_mask_pb2` and `client.copy_from(op.update_mask, field_mask_pb2.FieldMask(paths=[...]))`.
- **Negative Keyword Safety Guards**: When scripting mass negative keyword imports (e.g. 200+ terms), always maintain an explicit set of protected money keywords (e.g. `sexy`, `profile`, `wedding`, `event`, `portrait`) to prevent accidental blocking of core business offerings.
- **`use_proto_plus: True` Configuration Requirement**: Modern `google-ads` Python client library requires `use_proto_plus: True` explicitly defined in `~/.google-ads/google-ads.yaml`. Without it, `GoogleAdsClient.load_from_storage()` throws `ValueError: The client library configuration is missing the required "use_proto_plus" key`.
- **`login-customer-id` Header Conflicts**: Do not specify `login-customer-id` in config unless querying through a Manager Account (MCC) hierarchy that explicitly requires manager routing. Specifying it against direct client account credentials triggers permission denied (`USER_PERMISSION_DENIED`) errors.
- **Service Version Sunset Traps**: Avoid hardcoding deprecated API version parameters (e.g. `client.get_service("GoogleAdsService", version="v17")`) in automation scripts. Use bare `client.get_service("GoogleAdsService")` or the current active version (e.g. `v23`).
- **GAQL Date Range Syntax**: In GAQL, use `WHERE segments.date DURING LAST_30_DAYS` or `LAST_14_DAYS` (space-separated `DURING <LITERAL>`). Do NOT use underscore syntax like `DURING_LAST_30_DAYS` which causes `UNEXPECTED_INPUT` syntax error.
- **Customer ID & Manager Routing (`login-customer-id`)**: When querying client accounts, check whether the customer ID requires a manager account header or if it is directly accessible. For Club S, `9657319650` is the active serving customer ID for "ช่างภาพ ส่งงานไว".
- **MCP 2.x Incompatibility**: `google-ads-mcp` (v0.0.1) relies on `from mcp.server.fastmcp import FastMCP`, which was removed in `mcp>=2.0.0`. If installing `google-ads-mcp`, enforce `pip install "mcp<2" "mcp-types<2"`.
- **ADC Requirement Trap**: `google-ads-mcp` calls `google.auth.default()`, failing with `DefaultCredentialsError` if `gcloud auth application-default login` hasn't been executed. Use direct Python scripts with `~/.google-ads/google-ads.yaml` for headless/background runs.
- **Microsecond Timestamps**: Google Ads API rejects microsecond timestamps in offline conversion uploads. Truncate with `dt.replace(microsecond=0)`.
- **Cost in Micros**: All financial metrics from the API (`cost_micros`, `average_cpc_micros`) are in micro units (multiply THB by 1,000,000). Always divide by `1_000_000` for human-readable figures.
- **GAQL ORDER BY Field Requirement**: If using `ORDER BY metrics.clicks DESC` in GAQL, `metrics.clicks` MUST also be explicitly declared in the `SELECT` clause, otherwise API returns `EXPECTED_REFERENCED_FIELD_IN_SELECT_CLAUSE`.
- **Ad Rank vs Budget Impression Share (Page 1 Diagnostic)**: When checking why an ad is not appearing on Page 1 / top positions, query `metrics.search_impression_share`, `metrics.search_top_impression_share`, `metrics.search_budget_lost_impression_share`, and `metrics.search_rank_lost_impression_share`. If `search_rank_lost_impression_share` > 80%, the issue is Quality Score / Ad Relevance / Landing Page match, not budget exhaustion.
- **Message Assets (2025-2026 Support)**: Google Ads Search now supports direct messaging extensions for LINE OA (`lin.ee`) and Facebook Messenger alongside WhatsApp/SMS. Ideal for Thai local service funnels to eliminate mobile browser login bounce.
- **Location Targeting Bleed Trap (`Presence or Interest`)**: Default campaign location setting `PRESENCE_OR_INTEREST` often bleeds 40–50% of budget to non-local users who merely searched with a location term. Audit this in GAQL via `user_location_view` selecting `segments.geo_targeting_type` (`PRESENCE` vs `LOCATION_OF_INTEREST`). Always change local service campaigns to `PRESENCE` (People in or regularly in your targeted locations).
- **Mobile Social Media Final URL Drop-off**: Directing Search Ads final URLs to Facebook/Instagram posts or pages on mobile devices (>90% of local traffic) creates massive friction because in-app webviews require login and block direct messaging. Use direct LINE OA links (`https://lin.ee/...`) or dedicated lightweight mobile landing pages with sticky Click-to-LINE and Click-to-Call CTAs.
- **Local Service Broad Match Traps**: Broad match keywords like `ช่าง ภาพ` or `ถ่ายรูป` match aggressively with irrelevant high-volume searches such as passport photos (`ถ่ายรูป 1 นิ้ว`, `ติดบัตร`), studio rentals (`สตูดิโอให้เช่า`), equipment rentals, and sub-market budget searches (`1000 บาท`). Proactively seed 40+ negative keywords for service vs facility distinctions.
- **New Child Account & MCC Onboarding Readiness Gates**: When auditing or checking if a newly linked child account is ready to serve ads / run automated campaigns, verify 4 distinct gates before declaring live readiness:
  1. *Linkage & CID*: Child CID is linked under the Manager Account (MCC) and formatted as 10 digits without hyphens (e.g., `6104761960`) for API / env configs.
  2. *OAuth / Refresh Token*: Account email must complete the Google OAuth consent flow to issue a valid `refresh_token` stored in `~/.google-ads/google-ads.yaml` or `.env`.
  3. *Billing / Payment Method*: Active payment method must be verified attached to the child CID in Google Ads UI (accounts without billing cannot serve impressions).
  4. *Developer Token Tier*: Verify whether Developer Token is `Test Account Access` vs `Basic/Standard Production Access`; test access tokens cannot execute calls against non-test production accounts.
- **Pre-Launch Campaign Setup vs Billing Separation**: All campaign structures, ad groups, keywords, negative keyword lists, ad copies, and conversion tracking can be fully configured and validated before attaching a payment method or depositing funds. Unbilled accounts remain in `Pending Billing Setup` / `Eligible (Pending Billing)` without serving impressions or incurring charges until explicitly funded or connected to automatic billing.
- **New Advertiser Promotional Credit Rules & Tier Activation**:
  1. *Activation Window*: Promotional vouchers / Choose Your Offer (CYO) credits must be claimed under **Billing ➔ Promotions** within the initial 14–30 days of account creation or first impression.
  2. *Spend Threshold Mechanics*: Promotional credits (e.g., Thai market tiered match: Spend ฿12k get ฿24k credit, Spend ฿35k get ฿70k credit, Spend ฿70k get ฿140k credit, or standard ฿15k match) are NOT instant cash deposits. The account must fulfill real ad spend within 60 days before the promotional credit is auto-credited (5–7 days post-threshold) to offset future ad spend.
  3. *Credit Expiry & Non-Withdrawability*: Promotional credits apply strictly to future ad spend, cannot be withdrawn as cash, and expire within 60–90 days if unused.
