# Customer Chat & Payment Slip Audit Recipe

When auditing customer booking history, past quotations, or amounts paid from Facebook Messenger / LINE in the Club S workflow:

## Problem Pattern
- In Facebook Messenger / Graph API / local database message dumps, attachments (transfer slips, schedule image briefs) often appear with `message: ""` (empty text).
- Relying only on text search or database messages will cause the agent to miss actual bank transfer slips, leading to incorrect payment totals and customer history.

## Standard Audit Workflow
1. **Fetch Message Attachments via Graph API / Inbox**:
   ```bash
   # Query conversation messages including attachment image URLs
   https://graph.facebook.com/v24.0/<thread_id>/messages?fields=id,created_time,from,message,attachments{id,mime_type,image_data{url}}&limit=100&access_token=<token>
   ```
2. **Filter & Download Image Attachments**:
   - Filter messages where `attachments.data[].mime_type` starts with `image/` and exclude standard stickers (`sticker_*`).
   - Download the image files locally to `/tmp/`.
3. **Run OCR / Vision on Slips & Event Cards**:
   - Use macOS Native Vision framework via Swift (`VNRecognizeTextRequest`) or OpenRouter/Hermes Vision models (e.g. `ag/gemini-3.7-flash-high` / `gemini-3.1-pro-preview`).
   - Swift Native Vision one-liner:
     ```bash
     swift - << 'EOF'
     import Foundation
     import Vision
     import AppKit

     let imageURL = URL(fileURLWithPath: "/tmp/slip.jpg")
     guard let image = NSImage(contentsOf: imageURL),
           let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { exit(1) }
     let request = VNRecognizeTextRequest { req, _ in
         for obs in (req.results as? [VNRecognizedTextObservation]) ?? [] {
             if let top = obs.topCandidates(1).first { print(top.string) }
         }
     }
     request.recognitionLanguages = ["th-TH", "en-US"]
     request.usesLanguageCorrection = true
     try? VNImageRequestHandler(cgImage: cgImage).perform([request])
     EOF
     ```
   - Extract and verify:
     - Transfer Date & Time
     - Event/Ceremony Date from invitation cards (e.g. การ์ดงานบวช/งานแต่งงาน — verify if job date differs from transfer/inquiry date)
     - Sender Name & Bank
     - Receiver Name & Account / PromptPay (Must verify against `นาย สุจริต มานิตยกุล` SCB `9292223492`)
     - Exact Amount (THB)
4. **Reconcile with Messenger Payment Requests & Bookings**:
   - Match slip amounts against Messenger payment request bubbles (e.g. "คุณร้องขอไป ฿2,300.00", "โอนมัดจำ 800 บาท").
   - Audit customer schedule: check conversation start vs customer's specified job start time (e.g. "8.30-10.30", "16:00-17:30 น.").
   - Do NOT confuse the booking transfer date with the actual event date on customer invitations/cards.


## Tone & Communication Rule
- Address the user with natural polite Thai (คุณ / พี่ / บอส Bo / ครับ).
- Never use alienating honorifics (e.g. "เสี่ย") unless explicitly instructed.
