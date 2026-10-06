---
name: google-ads-multi-account-ops
description: Use when managing multi-account Google Ads OAuth tokens.
version: 1.0.0
license: MIT
author: hermes-gads-team
metadata:
  category: marketing
  tags: [google-ads, oauth, multi-account, mcc, gaql, tokens]
  related_skills: [google-ads-operations, google-ads-offline-conversions]
---

# Google Ads Multi-Account & OAuth Operations

## When to Use

- Managing multiple Google Ads accounts owned by different Google user identities (e.g. personal vs business vs client accounts).
- Deciding between **MCC Manager Account Linking (Recommended 5-Second Bypass)** vs **Dedicated OAuth Token Provisioning**.
- Diagnosing cross-account Google Ads API authorization errors (`CUSTOMER_NOT_ENABLED`, `USER_PERMISSION_DENIED`).
- Mitigating Google Cloud OAuth Consent Screen "Testing Mode" traps (7-day token expiration and unverified user blocks).
- Generating targeted OAuth consent URLs with `login_hint` to prevent multi-Google-account sign-in confusion on mobile/desktop.
- Handling mobile OAuth redirect loopback limitations (`http://localhost:8080/`) and extracting auth codes.
- Structuring multi-account YAML credential files and MCC manager hierarchies.

## Core Rules & Strategic Decision Matrix

### Approach A: The MCC Manager Link (Preferred & Instant — Zero New Tokens)
If the central enterprise/agency already has an active Developer Token and MCC Manager Account (`login_customer_id`):
1. **Never spin up separate GCP projects or OAuth credentials for client accounts when an MCC is available.**
2. **Client Link Request (5 Seconds)**:
   - In Client Google Ads UI: Navigate to `Admin` (ผู้ดูแลระบบ) ➔ `Access and security` (การเข้าถึงและความปลอดภัย) ➔ `Managers` (ผู้จัดการ) tab.
   - Click `+` (Link manager) ➔ Enter the Central MCC Customer ID (e.g., `384-446-7898`) ➔ Click **Send request** (ส่งคำขอ).
3. **Manager Acceptance**:
   - In Central MCC Google Ads UI: Navigate to `Admin` ➔ `Sub-account settings` (การตั้งค่าบัญชีย่อย) or check Notification Bell 🔔 ➔ Click **Accept** (ยอมรับ).
4. **Immediate API Access**:
   - Once linked, the existing central `refresh_token` in `~/.google-ads/google-ads.yaml` can instantly query and manage the child account by setting `login_customer_id: <MCC_CID>` without generating any new OAuth tokens!

### Approach B: Dedicated OAuth Flow (For Standalone / Independent Accounts)
Use this only when an account cannot be linked under the central MCC.

## Core Rules & Verification Protocol

1. **OAuth Refresh Token Identity Isolation**: A `refresh_token` is strictly tied to the specific Google Account that clicked "Allow". A valid token for Account A CANNOT query Customer IDs (CIDs) belonging to Account B unless Account B is linked under Account A's Manager Account (MCC) hierarchy.
2. **Never Misdiagnose `CUSTOMER_NOT_ENABLED`**: In Google Ads API, querying a CID using a refresh token from an unrelated Google identity returns `CUSTOMER_NOT_ENABLED` (`The customer account can't be accessed because it is not yet enabled or has been deactivated`). This does NOT mean the ads account is deleted or disabled in Google Ads UI — it means the active token has zero permissions for that CID.
3. **Always Embed `login_hint` in Consent URLs**: When generating OAuth links for users who manage multiple Google accounts on mobile, always include `login_hint=<target_email>`. Without it, browsers default to the primary mobile account (often the wrong email), generating a useless token for the wrong account.

## Multi-Account Architecture

```
                       [Developer Token (MCC API Center)]
                                      │
                 ┌────────────────────┴────────────────────┐
                 ▼                                         ▼
   [Identity 1: primary@gmail.com]           [Identity 2: brand@gmail.com]
   • Refresh Token 1                         • Refresh Token 2
   • ~/.google-ads/google-ads.yaml           • ~/.google-ads/google-ads-brand.yaml
   • Serves CID: 9657319650 (Club S)         • Serves CID: 6104761960 (Brand)
```

## Step-by-Step Multi-Account OAuth Flow

### Step 1: Generate Account-Specific Consent URL

```python
import urllib.parse

def generate_targeted_oauth_url(client_id: str, target_email: str, port: int = 8080) -> str:
    params = {
        "client_id": client_id,
        "redirect_uri": f"http://localhost:{port}/",
        "response_type": "code",
        "scope": "https://www.googleapis.com/auth/adwords",
        "access_type": "offline",
        "prompt": "consent",
        "login_hint": target_email
    }
    return "https://accounts.google.com/o/oauth2/v2/auth?" + urllib.parse.urlencode(params)
```

### Step 2: Handle Mobile Redirect & Code Extraction

On mobile devices, clicking "Allow" redirects to `http://localhost:8080/?code=4/0A...` which fails to load because no local server runs on the phone.
- **User Instruction**: Instruct the user to ignore the "Cannot connect" or "Site can't be reached" error and copy the full URL from the browser address bar.
- **Parsing**: Extract the `code` parameter from the pasted URL:

```python
import urllib.parse
import urllib.request
import json

def exchange_oauth_code(auth_code_or_url: str, client_id: str, client_secret: str, port: int = 8080) -> dict:
    code = auth_code_or_url.strip()
    if "code=" in code:
        parsed = urllib.parse.urlparse(code)
        qs = urllib.parse.parse_qs(parsed.query)
        if "code" in qs:
            code = qs["code"][0]

    token_url = "https://oauth2.googleapis.com/token"
    payload = urllib.parse.urlencode({
        "code": code,
        "client_id": client_id,
        "client_secret": client_secret,
        "redirect_uri": f"http://localhost:{port}/",
        "grant_type": "authorization_code"
    }).encode("utf-8")

    req = urllib.request.Request(token_url, data=payload, headers={"Content-Type": "application/x-www-form-urlencoded"})
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read().decode("utf-8"))
```

### Step 3: Persist and Isolate Configuration

Store the resulting `refresh_token` into a distinct YAML file to avoid overwriting the default fleet credentials:

```yaml
# ~/.google-ads/google-ads-brand.yaml
developer_token: <DEVELOPER_TOKEN>
client_id: <CLIENT_ID>
client_secret: <CLIENT_SECRET>
refresh_token: <ACCOUNT_SPECIFIC_REFRESH_TOKEN>
login_customer_id: <OPTIONAL_MCC_ID_IF_LINKED>
use_proto_plus: True
```

### Step 4: Verification Gate

Always verify the newly minted token live by querying customer accessibility:

```python
import os
from google.ads.googleads.client import GoogleAdsClient

config_path = os.path.expanduser("~/.google-ads/google-ads-brand.yaml")
client = GoogleAdsClient.load_from_storage(config_path)
ga_service = client.get_service("GoogleAdsService")

# Query descriptive name to confirm account active and accessible
query = "SELECT customer.id, customer.descriptive_name, customer.status FROM customer LIMIT 1"
response = ga_service.search_stream(customer_id="<TARGET_CID_NO_HYPHENS>", query=query)
for batch in response:
    for row in batch.results:
        print(f"Verified CID {row.customer.id}: {row.customer.descriptive_name} (Status: {row.customer.status})")
```

## Pitfalls & Lessons Learned

- **GCP OAuth Consent Screen "Testing Mode" 7-Day Expiration Trap**: In Google Cloud Console, if the OAuth consent screen publishing status is set to "Testing", OAuth refresh tokens automatically expire after **7 days**, and authorization is blocked with an unverified app / blocked error for any email not explicitly added under "Test users". To avoid constant re-authentication and broken cron pipelines, link client accounts directly under an MCC instead of creating testing-tier OAuth apps.
- **`CUSTOMER_NOT_ENABLED` Error Code**: Raised when querying an unlinked/unauthorized CID with another identity's token. Check token email ownership before assuming account suspension.
- **`USER_PERMISSION_DENIED` with `login-customer-id`**: If querying a standalone client CID that is NOT managed under an MCC, do NOT include `login_customer_id` in the YAML config. Specifying an unrelated MCC ID triggers `USER_PERMISSION_DENIED`.
- **Proto Plus Requirement**: Always include `use_proto_plus: True` in every account-specific YAML file; omitted keys crash the `GoogleAdsClient.load_from_storage()` loader.
- **Hyphen Stripping**: Google Ads API requires 10-digit CIDs without hyphens (e.g., `6104761960` instead of `610-476-1960`).
