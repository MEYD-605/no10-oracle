---
name: google-ads-offline-conversions
description: Use when building Google Ads offline conversion webhooks.
version: 1.0.0
license: MIT
author: hermes-gads-skill
metadata:
  category: marketing
  tags: [google-ads, webhook, offline-conversions, gclid, fastapi]
  related_skills: [facebook-marketing, gm-sop-review]
---

# Google Ads Offline Conversions Skill

## When to Use

- Building or debugging Google Ads offline conversion webhook handlers (Click Conversions, GCLID/GBRAID/WBRAID).
- Formatting conversion timestamps and timezones for the Google Ads API.
- Implementing HMAC signature authentication, deduplication ledgers, or dry-run fallbacks for Google Ads imports.

## Key Features & Requirements

1. **Click Identifiers**: Must contain at least one of `gclid`, `gbraid`, or `wbraid`.
2. **Timestamp Precision & Timezone**:
   - Format: `yyyy-mm-dd hh:mm:ss+hh:mm` or `yyyy-mm-dd hh:mm:ss-hh:mm` (timezone offset MUST include colon, e.g. `+07:00`, not `%z`'s default `+0700`).
   - Microseconds (`.123456`) are rejected by the Google Ads API. Microseconds MUST be truncated (`dt.replace(microsecond=0)`).
   - GCLID max age is 90 days. Allow up to 24h clock skew for future timestamps to prevent rejecting misconfigured client clocks.
3. **Webhook Ingestion Robustness**:
   - Support both single event dicts (`{...}`) and batched arrays (`{"events": [...]}`).
   - Reject JSON root arrays (`[...]`) with `400 Bad Request` instead of letting parsing crash with `500 Internal Server Error`.
4. **Deduplication Ledger**:
   - Persist accepted events to an append-only JSONL ledger using a composite dedupe key: `gclid:conversion_name:order_id` (or `event_type`).
   - On server startup, reload existing dedupe keys from disk. Ensure the reloader inspects both top-level keys and nested `events` fields so deduplication survives server restarts.
5. **HMAC Signature Verification**:
   - Compute SHA-256 HMAC of raw HTTP request body using `x-gads-signature` header.
   - Use `hmac.compare_digest` for constant-time comparison to prevent timing attacks.

## Implementation Architecture

```
[ Incoming Webhook ]
        │
        ▼
1. HMAC SHA-256 Check (x-gads-signature) ──▶ Fail: 403 Forbidden
        │ Pass
        ▼
2. JSON Parsing & Structure Validation  ──▶ Invalid List/JSON: 400 Bad Request
        │ Pass
        ▼
3. Deduplication Check (Ledger memory)   ──▶ Duplicate: 400 (skip re-upload)
        │ Pass
        ▼
4. Timestamp & Identifier Validation     ──▶ Invalid: 400 Bad Request
        │ Pass
        ▼
5. Persist to Ledger (disk JSONL)
        │
        ▼
6. Upload to Google Ads API (or Dry-Run Fallback)
```

## Recommended Setup & Code Snippet

### Timestamp Formatting (Python)

```python
from datetime import datetime, timezone, timedelta

def format_gads_datetime(dt: datetime) -> str:
    """Format datetime for Google Ads API: yyyy-mm-dd hh:mm:ss+hh:mm (no microseconds)."""
    # Truncate microseconds
    dt = dt.replace(microsecond=0)
    formatted = dt.strftime("%Y-%m-%d %H:%M:%S%z")
    # Insert colon into timezone offset (+0700 -> +07:00)
    if len(formatted) >= 5 and formatted[-5] in ("+", "-") and formatted[-3] != ":":
        formatted = formatted[:-2] + ":" + formatted[-2:]
    return formatted
```

### Dry-Run SDK Fallback Pattern

```python
def upload_conversion(event: dict, dry_run: bool = True) -> dict:
    """Upload click conversion to Google Ads API with graceful fallback when SDK is absent."""
    try:
        from google.ads.googleads.client import GoogleAdsClient
        # Perform real ConversionUploadService API call here
        ...
    except ImportError:
        # Graceful degradation if SDK is missing or dry_run is active
        return {
            "uploaded": False,
            "reason": "google-ads SDK missing" if not dry_run else "dry_run",
            "event": event
        }
```

## Pitfalls & Common Mistakes

- **Python `%z` Timezone Format**: Standard library `strftime("%z")` returns `+0700` (no colon). Google Ads API rejects offsets without colons. Always convert `+0700` to `+07:00`.
- **Microseconds in Conversion Time**: `datetime.now().isoformat()` produces microseconds. Google Ads API throws invalid timestamp error if microseconds are present.
- **Dedupe Ledger Persistence Bug**: If dedupe keys are stored in nested event objects in JSONL, ensure the startup reload parser unwraps `record.get("events")` or top-level `record["dedupe_key"]`. Otherwise, duplicate detection works during runtime but fails after server restarts.
- **Root JSON List Crash**: If a webhook receiver receives `[{"event": ...}]` directly instead of a dict, `body.get("events")` throws an AttributeError or `raw_events` stays `None`, causing `ingest_events` to crash with 500. Always validate `isinstance(body, dict)`.
- **FastAPI Nested Router Path Inspection in Tests**: In FastAPI >= 0.140, routers mounted via `app.include_router(..., prefix="/...")` use lazy `_IncludedRouter` objects which lack a `.path` attribute. Checking `getattr(r, "path")` or `r.routes` on `app.routes` directly will miss prefix paths or raise AttributeError. The simplest, authoritative way to test that a route is mounted on `app` is to inspect `app.openapi()["paths"].keys()`.
- **Integration Test Config Initialization**: When testing mounted endpoints with FastAPI `TestClient`, missing environment variables like `GOOGLE_ADS_CUSTOMER_ID` cause batch responses to return status `207 Multi-Status` with `config_error` instead of `200 OK`. Ensure `os.environ["GOOGLE_ADS_CUSTOMER_ID"] = "1234567890"` and `os.environ["GOOGLE_ADS_WEBHOOK_SECRET"]` are set prior to initializing or testing requests.
- **Test Helper Parameter Hardcoding**: When writing test helper functions like `_sign(body, secret=DEFAULT_SECRET)`, ensure the internal implementation uses the passed `secret` parameter rather than hardcoding `DEFAULT_SECRET`. Otherwise, testing negative authentication cases (e.g. invalid HMAC signature -> 403) will silently send valid signatures and fail assertions.

## Verification Protocol

1. Run unit test suite covering validation, HMAC signature, deduplication, timestamp formatting, and payload structure.
2. Run live smoke test by spawning a test server (`uvicorn` or FastAPI `TestClient`), sending signed HTTP POST requests, and verifying:
   - Valid signed request returns HTTP 200.
   - Replayed duplicate request returns HTTP 400 with duplicate count.
   - Invalid HMAC signature returns HTTP 403.
   - Non-dict / JSON array body returns HTTP 400.
