---
name: quotation
description: Generate Club S quotation PDFs and deliver via MEDIA or URL.
version: 1.0.0
tags: [quotation, pdf, club-s, invoice, receipt, discord]
---

# Quotation Generator (Club S Pipeline)

Generate PDF quotations, invoices, and receipts for Club S and deliver them to customers.

## When to use
Use when asked to generate a quotation, invoice, receipt, or PDF quote (e.g. "ออกใบเสนอราคา", "quote pdf", "/quotation").

## Architecture & Sources
- Python entrypoint: `/Users/admin/Code/github.com/MEYD-605/facebook-mcp-server/quotation/quote_final.py`
- FastMCP Server: `/Users/admin/Code/github.com/MEYD-605/facebook-mcp-server/server.py` (Registered under `facebook-mcp` MCP tool)
- Shell wrapper: `/Users/admin/Code/github.com/MEYD-605/mimo-oracle/ψ/tools/quote.sh`
- Template engine: `generate_doc.py`
- Output archive: `/Users/admin/Code/github.com/MEYD-605/mimo-oracle/projects/clubsxai-documents/QUO/`

## Requirements & Environment Setup
- FastMCP / Quotation script requires Python virtual environment setup with `mcp[cli]`, `fpdf2`, `python-dotenv`, and `requests`.
- When setting up for a specific profile (e.g. `~/.hermes-no4`), run `/Users/admin/.hermes-no4/venv/bin/python -m ensurepip` and install `mcp[cli]==1.2.0` in that profile's venv.

## Quick Execution & Benchmark (Async Fast Mode)

To make quotation generation instant for the user (~3s vs ~15s full sync build):
1. `ψ/tools/quote.sh` generates local PDF and returns PDF_PATH and PUBLIC_URL immediately.
2. Background deployment is fired via `nohup` detached subshell with Cloudflare credentials re-sourced.

```bash
# Fast Mode (~3s execution, bg deployment):
bash ψ/tools/quote.sh Q-2026-XXXX "ชื่อลูกค้า" "รายการสินค้า/บริการ" 3500 1000 "หมายเหตุ" "ที่อยู่ลูกค้า" "fast"

# Sync Mode (~12-15s execution, wait for Cloudflare Pages 200 OK before return):
bash ψ/tools/quote.sh Q-2026-XXXX "ชื่อลูกค้า" "รายการสินค้า/บริการ" 3500 1000 "หมายเหตุ" "ที่อยู่ลูกค้า" "sync"
```

### Async Background Deploy Pitfall:
When launching background deployment in bash scripts via `nohup` or `&`, always re-source `~/.cloudflare.env` and set `CLOUDFLARE_API_KEY` inside the detached child shell, because parent subshell environment variables may not persist cleanly across subshell detachment.

### Python Direct Execution (Custom Data)
```python
import os, sys
sys.path.insert(0, os.path.expanduser("~/Code/github.com/MEYD-605/facebook-mcp-server/quotation"))
from quote_final import create_quotation

out_path = os.path.expanduser("~/Code/github.com/MEYD-605/mimo-oracle/projects/clubsxai-documents/QUO/Q-2026-XXXX.pdf")
res = create_quotation({
  "number": "Q-2026-XXXX",
  "client_name": "ชื่อลูกค้า",
  "date": "31 สิงหาคม 2026",
  "deposit": 1000,
  "items": [{"description": "รายการสินค้า/บริการ", "price": 3500, "qty": 1}],
  "note": "รายละเอียดเพิ่มเติม"
}, output_path=out_path)
```

## Review Gate (MANDATORY — Bo 2026-09-01)
Every quotation MUST be reviewed by Bo or P'Mo (both can approve) BEFORE the customer sees it. Send a PNG screenshot preview of the PDF in Discord DM (render: `sips -s format png <pdf> --out <png>` then downscale `sips -Z 1400`). Never send to the customer until approved.

Self-check the screenshot before showing (vision or pdf text extract):
1. NO floating job-details text in the middle of the page — the `NOTE`/5th arg of quote.sh renders as a standalone centered line. Keep NOTE **empty**; put ALL job details (date/time/place/conditions) inside the DESCRIPTION (3rd arg) only.
2. Items live ONLY in the DESCRIPTION table.
3. Deposit line: `generate_doc.py` auto-inserts a deposit (photo >2,000 THB → 1,000; video → 2,000-3,000) when deposit=0 on quotations — do not report "no deposit" to Bo when the PDF shows one; either pass the real deposit explicitly or flag the auto value.
4. Verify the actual PDF text (`pypdf` extract or vision) — never trust the command args alone.

## Business Rules & Standards
- **Bank Account Standard (SSOT):** นาย สุจริต มานิตยกุล (SCB: 929-222-3492 / 9292223492 / English: Mr. Sujarit Manittayakul) — ONLY use this account name across all PDF templates, scripts, and message drafts.
- **Accent Seal:** `#3F51B1` (RGB: 63, 81, 177)
- **Deposit Policy:** Photo sessions > 2,000 THB typically require 1,000 THB deposit (Club S standard).
- **Archive:** PDFs must be saved in `projects/clubsxai-documents/QUO/`.
- **Revision & CDN Cache Rule (Document Versioning):** When correcting or revising a document (e.g., updating bank account name, address, or items), ALWAYS bump the document sequence number (e.g., `Q-2026-0814-02.pdf` instead of reusing `Q-2026-0814-01.pdf`). Overwriting the exact same URL leads to stale Cloudflare Pages / browser CDN caching where customers see the un-updated file.
- **Git Tracking for Deployment:** Files deployed under `clubs-xno1/public/documents/QUO/` must be committed and pushed to `main` branch (`git add`, `git commit`, `git push origin main`) alongside `wrangler pages deploy` to ensure Cloudflare Pages serves the file reliably without 404s.
- **User Preference / Prompting:** When the user asks to send/copy text & link to customer via LINE/Messenger (e.g., "ขอข้อความพร้อมลิงก์พร้อมส่งให้ลูกค้าหน่อย"), ALWAYS include BOTH the copyable message template AND the direct clickable PDF URL (`https://clubsxai.com/documents/QUO/<doc_number>.pdf`) in the initial response. Do not require the user to ask again for the link ("แล้วมึงไม่ส่ง PDF ส่งลิ้งค์ใหม่มา").
- **Customer Delivery Template & Mobile Behavior:** 
  - Android vs iOS Behavior Note: Chrome/Android handles `Content-Disposition: attachment` by downloading directly, while Safari/iOS opens and previews the PDF inside the browser tab.
  - Delivery Message Standard: When providing a customer-ready message with a PDF link, always include brief, friendly viewing/download guidance for both iOS and Android users so customers on any phone know how to open or save the file easily.
- **3-Bill Post-Event Package Standard ("รวมทั้ง 3 บิล"):** When issuing a post-shoot balance collection call or invoice ("ใบเรียกเก็บเงินส่วนที่เหลือ"), ALWAYS generate and bundle all 3 documents into a complete 3-bill package:
  1. Quotation (`Q-...`): Full breakdown of all services (photo, video, etc.).
  2. Deposit Receipt (`REC-...`): Proof of deposit paid (e.g., 1,000 THB).
  3. Invoice (`INV-...`): Final bill for the remaining balance.
  The copyable customer message must explicitly include links to all 3 PDFs, total fee, deposit paid, remaining balance, bank transfer account (SCB 929-222-3492), and mobile viewing instructions.

## Verification & Testing
- **Temp Output Override:** Pass `QUOTE_OUT=/tmp` in environment when testing PDF generation to avoid cluttering production document archives.
- **PDF Integrity Check:** Always verify generated PDF file exists and has non-zero byte size before reporting success.

## Delivery Methods & Mandatory Checklist
1. **Discord DM Attachment:** ALWAYS upload the generated PDF file directly.
   - If using `ψ/tools/discord-upload.py`, pass `--file <path>` explicitly (e.g. `--file /path/to/pdf`).
   - If `discord-upload.py` returns 401 Unauthorized or in Hermes native platform delivery, attach `MEDIA:/path/to/file.pdf` at the end of the response for native delivery.
2. **Web Deployment & Public URL (Mandatory):**
   - Copy the generated PDF from `projects/clubsxai-documents/QUO/` to `projects/clubs-xno1/public/documents/QUO/`.
   - Deploy to Cloudflare Pages with Global API Key credentials (from `~/.cloudflare.env`):
     ```bash
     cd ~/Code/github.com/MEYD-605/clubs-xno1 && (test -f dist/index.html || bun run build) && wrangler pages deploy dist --project-name=clubs-xno1 --branch=main
     ```
     *Note on Cloudflare Auth:* In non-interactive Wrangler deployments using Global API Keys (as stored in `~/.cloudflare.env`), `CLOUDFLARE_API_TOKEN` causes HTTP 10000/9109 authentication errors. Always `unset CLOUDFLARE_API_TOKEN` and set `CLOUDFLARE_API_KEY="$CLOUDFLARE_API_TOKEN"` with `CLOUDFLARE_EMAIL`.
   - Provide the public URL: `https://clubsxai.com/documents/QUO/<doc_number>.pdf`
3. **Clickable Link Formatting:** Always format all web URLs as explicit Markdown links `[Label](https://...)` so they render as clean, easy-to-click buttons on mobile chat clients (e.g. `[Q-2026-0915-01.pdf](https://clubsxai.com/documents/QUO/Q-2026-0915-01.pdf)`).
4. **D1 Record:** Document metadata is automatically saved to Cloudflare D1 via `save_to_d1.py` integrated into `quote.sh`. Ensure client names with quotes/special characters are sanitized/parameterized (`escape_sql()`) to prevent SQL syntax errors. All D1 queries are optimized for Cloudflare Workers/D1 $5/mo plan limits to avoid billing overage.
5. **Support Reference:** Additional delivery details are in `references/delivery-formatting-guide.md` and audit/troubleshooting procedures are in `references/audit-troubleshooting.md`.
