# Hermes Vision Provider Routing — Diagnostic Recipe

## Symptom
Bo sends an image via Discord DM → response hangs/freezes ("ทำไมตอบค้างๆ").

## Root Cause (2026-07-17)
Config sets `auxiliary.vision: xai-oauth/grok-4.3`, but when Hermes can't resolve
the `xai-oauth` provider (no `providers:` section in config.yaml), it silently
falls back to the **default provider** (zai). ZAI doesn't know `grok-4.3` → returns
error 1211 "Unknown Model". The fallback + retry loop appears as a "hang" to Bo.

## Diagnostic Steps
1. **Read config.yaml** — check `auxiliary.vision` provider/model vs `model.default` provider.
2. **Check if providers section exists** — if config has no top-level `providers:` block,
   `xai-oauth` as a provider name may not resolve. Hermes falls back to default.
3. **Verify the JWT directly:**
   ```python
   import json, base64
   d = json.load(open('~/.grok/auth.json'))
   # auth.json uses "https://auth.x.ai::<uuid>" as key, value = {"key": "<JWT>"}
   for k,v in d.items():
       if isinstance(v, dict) and 'key' in v:
           token = v['key']
           parts = token.split('.')
           payload = json.loads(base64.b64decode(parts[1] + '=='))
           # Check exp field — token may be expired
   ```
4. **Direct API test (bypass Hermes):**
   ```bash
   TOKEN=$(python3 -c "import json; d=json.load(open('$HOME/.grok/auth.json')); [print(v['key']) for v in d.values() if isinstance(v,dict) and 'key' in v]")
   curl -s https://api.x.ai/v1/chat/completions \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"model":"grok-4.3","messages":[{"role":"user","content":"say hi"}],"max_tokens":10}'
   ```
5. **If token works but Hermes falls back** → the issue is provider resolution, not credentials.

## Known Quirks
- `~/.grok/auth.json` structure: top-level key is `"https://auth.x.ai::<client_id>"`,
  value is `{"key": "<JWT string>"}` — not a flat `{"access_token": "..."}`.
- JWT payload contains `exp`, `scope`, `tier`, `principal_type`, `client_id`.
- Token expiry: JWTs from x.ai OAuth expire ~6 hours (21600s). Check `exp` field.
- Error 1211 from ZAI = "Unknown Model" — this is NOT a rate limit or quota issue,
  it means the wrong provider received the request for a model it doesn't serve.
- Error "Bad credentials" when testing api.x.ai = either token expired or wrong
  extraction path (check auth.json structure above).

## Config Audit Checklist (when Bo asks "เปิดโหมดต่ายๆที่จำเป็นหรือยัง")
Compare current `config.yaml` against `cli-config.yaml.example` in the Hermes repo:
| Setting | What it does | Default |
|---------|-------------|---------|
| `streaming.enabled` | Real-time token streaming to Discord | `false` |
| `reasoning_effort` | Model thinking depth (none→ultra) | provider default |
| `compression.enabled` | Auto-shrink long conversations | `true` |
| `compression.threshold` | % of context before compress | `0.50` |
| `verify_on_stop` | Extra verification on task stop | `false` |
| `max_turns` | Max agent turns per task | varies |
| `gateway_timeout` | Max gateway call duration (s) | `1800` |
| `parallel_tool_call_guidance` | Batch independent tool calls | `true` |
| `image_input_mode` | auto/manual vision image handling | `auto` |

Present to Bo as compact table: mode · current value · recommendation.

## Fix Path (when provider resolution fails)
- Add explicit `providers:` section to config.yaml with the xai-oauth provider definition.
- OR change `auxiliary.vision.provider` to a resolvable provider name.
- The provider name in `auxiliary.vision.provider` must match a configured provider
  (either built-in or declared in `providers:` section).

## Related
- Skill `bo-dm-protocol` pitfall: "ทำไมตอบค้างๆ" (2026-07-17)
- Hermes repo: `/Users/admin/Code/github.com/NousResearch/hermes-agent`
- Config: `~/.hermes-gmgrok/config.yaml`
- Auth: `~/.grok/auth.json`
- Example config: `<hermes_repo>/cli-config.yaml.example`
