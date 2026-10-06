# Vision on Non-Vision Models — Fast Failure Handling

## Symptom
Bo sends an image via Discord DM → `vision_analyze` returns immediately with
"model has no vision support" or "[image omitted: model has no vision support]".
This is NOT a hang (unlike the provider-fallback case in hermes-vision-routing.md)
— it fails fast.

## Root Cause
The active primary model (e.g. `glm-5.2`, some Flash tiers) simply has no
multimodal capability. `vision_analyze` may route to an auxiliary vision model,
but if none is configured or reachable, the call returns empty/no-vision.

## DO NOT Waste Tool Calls on Workarounds (learned 2026-07-27)
When `vision_analyze` returns "no vision support", do NOT try these — they all
fail or are useless for understanding screenshots:
- `computer_use action=capture` → captures YOUR desktop, not the image file
- `tesseract` → usually not installed on maclab
- `PIL/numpy` pixel analysis → gives brightness numbers, not content
- `sips` → gives dimensions only, not content
- Multiple `vision_analyze` retries with different URL formats → same no-vision result

Each failed attempt costs a tool round-trip and makes Bo wait.

## Correct Fast Response (≤2 tool calls)
1. First `vision_analyze` attempt returns "no vision support" → **stop immediately**.
2. Tell Bo directly in natural Thai:
   "ผมรันโมเดลที่ไม่มี vision อยู่ตอนนี้ครับ อ่านรูปไม่ได้ — บอสเล่าสั้นๆ ได้ไหมครับ หรือให้ผมสลับโมเดลก่อน?"
3. Do NOT loop through alternative OCR/image tools.

## Vision-Capable Models on maclab
- `ag/gemini-3.6-flash-high` (9router) — default primary, has vision
- `grok-4.5` (xai-oauth) — has vision
- `ag/claude-opus-4-6` / `ag/claude-sonnet-4-6` (9router) — have vision
- `glm-5.2` — **NO vision** (text only)

## Prevention
Before a session where Bo is likely to send screenshots/images, check if the
active model supports vision. If running glm-5.2 or another text-only model,
proactively mention this to Bo when an image arrives, rather than discovering
it through multiple failed attempts.

## Related
- `hermes-vision-routing.md` — provider fallback hang (different symptom: hangs vs fails fast)
- Skill `bo-dm-protocol` → NEW pitfall: "Active model lacks vision"
