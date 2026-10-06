# Quotation Delivery & Formatting Checklist

## Delivery Standards
1. **REST API Discord Multipart Upload**: Always execute `python3 ψ/tools/discord-upload.py --bot no4 --channel <channel_id> --file <pdf_path> --text "..."` to push PDF attachments directly to Discord DMs.
   - Bo DM Channel: `1523587194642497606`
   - P'Mo DM Channel: `1536810824306393148` (User ID `811599337665986561`)
   - *DM Channel Resolution:* `discord-upload.py` requires a Discord Channel ID. If given a User ID (e.g. for team member delivery), open/resolve the DM Channel ID first via `POST https://discord.com/api/v10/users/@me/channels` with payload `{"recipient_id": "<user_id>"}` using `Authorization: Bot <token>`.
2. **Cloudflare Pages Public URL**: Deploy the PDF to `clubs-xno1` at `public/documents/QUO/<doc_number>.pdf` and provide `https://clubsxai.com/documents/QUO/<doc_number>.pdf`.
3. **Customer Message Template**: When asked to draft message text for sending to customers (LINE/Messenger), always incorporate the generated PDF direct link (`https://clubsxai.com/documents/QUO/<doc_number>.pdf`) directly inside the draft message or alongside it in the first reply. Never omit the link when drafting customer transmission text.
4. **Markdown Hyperlink Formatting**: Wrap all links in markdown format `[Label](url)` so they render as easy-to-click buttons on mobile clients.
5. **Document Revision & CDN Cache Busting**: When updating an existing quotation (e.g. name change), ALWAYS increment the sequence number suffix (`Q-2026-0814-01` -> `Q-2026-0814-02`) and push changes to Git main branch before deploying via Wrangler. Reusing the exact same file path causes Cloudflare Pages / browser CDN to serve cached 404s or stale PDFs.
6. **No Blind Post Selection**: When boosting/promoting Facebook posts, verify the exact post content, type, and creation date via Graph API to avoid boosting cover photos or old posts by mistake.
7. **Content Pre-Approval**: Always draft post captions, select specific image sets, and present them for user screening/approval before publishing to social media pages.
8. **SMM Boosting & Order Actions**:
   - For PerfectPanel SMM Panel APIs (iPlusView), the order creation action parameter is `action=order` (not `action=add`).
   - Monitor order status until `Completed` or set up a background watchdog.

