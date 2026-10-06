# xAI OIDC / Grok CLI auth failures (chat · models · fleet)

Bo changes login email · CLI seats 403 · “login ปกติแล้วทำไมพัง” · “ทำไมแมวอื่นได้” · “ต้องเส้นเดียวไหม” · “subscribe เมลไหน”.

## Three different 403s (do not collapse)

| Code / class | Symptom | Meaning | Fix |
|--------------|---------|---------|-----|
| **`permission-denied`** | OIDC token present · **both** `/v1/models` + `/v1/chat/completions` → 403 `permission-denied` · often `reauthable:false` · `auth_mode:Oidc` | Account lacks chat/API **entitlement** (JWT may still list `api:access` / `grok-cli:access`) | Restore working principal **or** SuperGrok/API grant on that email · not tmux thrash |
| **`personal-team-blocked:spending-limit`** | Token **not** expired · 403 text: *run out of credits or need a Grok subscription* · points to `grok.com/?_s=usage` / SuperGrok | **Credits/subs empty** on that personal team | Top up credits / renew SuperGrok on **that email** · then re-probe |
| **`unauthenticated:bad-credentials`** | 403 bad-credentials · JWT `exp` past · or stale process | Expired OAuth **or** stale in-memory token | Refresh OAuth / re-login · or kill+reboot seat if file 200 but process stale |

**Seat missing** (Discord green · relay LIVE · tmux/maw gone) is **not** auth — use `references/no1-seat-restore.md`.

## Two auth worlds (why “แมวอื่นทำได้”)

| Plane | Path | Who |
|-------|------|-----|
| **Grok CLI** | `~/.grok/auth.json` **shared** | No.1 · sombo · mimo · gmlab · any `grok` seat |
| **Hermes** | `~/.hermes-<name>/auth.json` `credential_pool.xai-oauth` | gmgrok · gmforge · per-home |

- One bad CLI login rewrites **all** CLI cats.
- Hermes can stay **200** on a **different JWT `sub`** while CLI is 403.
- Never claim “whole fleet dead” from CLI 403 alone.
- **Login success ≠ API works** · **scopes in JWT ≠ account grant**.

## Fast audit (never print full token)

```bash
python3 - <<'PY'
import json, base64, time, urllib.request, urllib.error
from pathlib import Path
from datetime import datetime, timezone
now=time.time()

def claims(tok):
  p=tok.split('.')[1]+'='*((4-len(tok.split('.')[1])%4)%4)
  return json.loads(base64.urlsafe_b64decode(p))

def probe(label, tok, email=None):
  c=claims(tok)
  exp=c.get('exp')
  print(f'=== {label} email={email} sub={(c.get("sub") or "")[:12]} exp={datetime.fromtimestamp(exp,tz=timezone.utc).isoformat() if exp else None} expired={exp<now if exp else None}')
  for url, method, data in [
    ('models','GET',None),
    ('chat','POST', json.dumps({"model":"grok-4.5","messages":[{"role":"user","content":"p"}],"max_tokens":1}).encode()),
  ]:
    headers={'Authorization':f'Bearer {tok}','User-Agent':'fleet-auth-probe/1.1'}
    if data: headers['Content-Type']='application/json'
    full='https://api.x.ai/v1/models' if url=='models' else 'https://api.x.ai/v1/chat/completions'
    req=urllib.request.Request(full, data=data, headers=headers, method=method)
    try:
      with urllib.request.urlopen(req, timeout=25) as r: print(url, r.status)
    except urllib.error.HTTPError as e:
      body=e.read()[:180].decode('utf-8','replace')
      print(url, e.code, body)

g=next(iter(json.loads((Path.home()/'.grok/auth.json').read_text()).values()))
probe('GROK_CLI', g['key'], g.get('email'))
hpath=Path.home()/'.hermes-gmgrok/auth.json'
if hpath.exists():
  h=json.loads(hpath.read_text())['credential_pool']['xai-oauth'][0]
  probe('HERMES_gmgrok', h['access_token'])
  print('same_token', g['key']==h['access_token'])
PY
```

Classify from **code string** in body, not vibes.

## Recovery matrix

| Situation | Action |
|-----------|--------|
| Hermes **200**, CLI **permission-denied** | Backup CLI auth → map Hermes tokens into Grok OIDC shape → chmod 600 → prove 200 → headless `AUTH_OK` → reboot CLI seats |
| CLI **spending-limit** | Report email + code · Bo tops up / SuperGrok on **that email** · do **not** silent account-swap unless Bo chooses single path |
| Hermes token **expired**, CLI 200 | Refresh Hermes OAuth / re-import from working CLI after prove |
| Multiple emails in bak | Prefer **live 200 probe** over newest mtime |
| Bo wants **one path** | Pick **one** email with 200 + credits · login only that · sync Hermes homes · ban casual re-login overwrites |

### Hermes → Grok restore shape (permission-denied only)

1. `cp -a ~/.grok/auth.json ~/.grok/auth.json.bak-broken-$(date +%Y%m%d_%H%M%S)`
2. Grok entry: `key`←access · `refresh_token`←refresh · `user_id`←JWT sub · `auth_mode=oidc` · map key `https://auth.x.ai::<client_id>`
3. Prove models+chat **200**
4. `GROK_DEBUG_CONTEXT_WINDOW=500000 grok --model grok-4.5 --always-approve -p 'Reply with exactly: AUTH_OK'`
5. Reboot seats: `no1-seat-restore.md` + other Grok CLI cats
6. **Re-overwrite risk:** any Grok CLI login with bad/empty-credit email rewrites file — re-probe before GREEN

## SuperGrok / “subs” vs API key

- OIDC / Hermes `auth_type: oauth` + `loopback_pkce` + scopes `grok-cli:access` = **subscription login path**, not `XAI_API_KEY`
- TUI **Weekly limit left** = package quota signal
- “When before only login worked”: old email already had entitlement+credits · new email can login without either

## Bo DM tone

- Natural Thai · grouped · numbers (email, sub prefix, status code, **which** 403 class)
- “login ปกติ / ทำไมต้องเปิด / แก้ดิ” → **run probe + restore if Hermes 200** · do not only lecture console
- spending-limit → plain: เครดิต/แพ็กหมดที่เมล์นี้ · usage/supergrok · not “ต้องเปิดสิทธิ์ในเครื่อง”
- After fix: short prove · seat LIVE · warn re-login overwrite

## Session bank 2026-07-12 (condensed)

1. `jackson…@hotmail.com` OIDC → **permission-denied** both endpoints · Hermes different `sub` **200** → restore → AUTH_OK
2. Auth re-overwritten by later login · always re-probe
3. Later CLI `ai.no.2bro@gmail.com` token fresh → **spending-limit** (credits) — different class
4. Hermes-gmgrok still other `sub` 200 · other Hermes homes expired bad-credentials
5. Bo single-path ask: yes for ops hygiene · **classify first**

## Related

- `references/no1-seat-restore.md` · `references/fleet-agent-brain-diagnose.md`
- `no1-exec-methods` · `references/no1-ctx500-verify.md` (window ≠ auth)
- `xai-imagine-media` (Imagine needs models **200**; poll `GET /v1/videos/{id}`)
