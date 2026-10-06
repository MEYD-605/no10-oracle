# GmGrub Note20 Study & Task-Splitting Reference (2026-07-25)

## 📌 Summary of GmGrub Note20 Analysis
- **Node**: `note20` (`100.80.0.2:8022`, user `u0_a377`, `~/.hermes-no101`)
- **Key Virtues Learned**:
  1. **Communication Discipline**: Direct, concise Thai to Bo, no polite/repetitive padding ("ห้ามขึ้นต้นทุกประโยคด้วยครับพี่โบ"), verify before claims.
  2. **Auto Image Input**: Configured `agent.image_input_mode: auto` for seamless Discord image processing.
  3. **Task-Splitting Concept**: Splitting workloads across specialized models (e.g. Chat vs Vision vs Gen) rather than forcing one model.
  4. **Strict Model Tier Rule for Maclab**: While adopting GmGrub's workflow and prompt discipline, `maclab` MUST maintain top-tier models (`ag/gemini-3.6-flash-high`, `ag/claude-opus-4-6-thinking`, `grok-4.5`) and NEVER downgrade to lower-tier models.

## 🛠️ Real-time Rate Limit Verification Pattern (xAI / Grok 4.5)
To extract exact live rate limits from xAI without guessing:
```python
import json, urllib.request

url = 'https://api.x.ai/v1/chat/completions'
headers = {'Authorization': f'Bearer {tok}', 'Content-Type': 'application/json'}
body = json.dumps({'model': 'grok-4.5', 'messages': [{'role': 'user', 'content': 'hi'}], 'max_tokens': 5}).encode('utf-8')
req = urllib.request.Request(url, data=body, headers=headers)
with urllib.request.urlopen(req, timeout=10) as resp:
    headers = resp.headers
    # Extract x-ratelimit-remaining-tokens, x-ratelimit-remaining-requests
```
