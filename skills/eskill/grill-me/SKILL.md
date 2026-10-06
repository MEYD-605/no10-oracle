---
name: grill-me
description: '[engineering] E-SKLL | Run a grilling session on the current plan or Bo request. Use when user says "grill me", "grill หน่อย", or wants to sharpen design before work starts. Loads /grilling behavior.'
origin: utarn/engineer-skills
disable-model-invocation: false
---

# /grill-me

Run a **`/grilling`** session on the **current topic** (last Bo request or stated plan).

## Steps

1. Restate the plan in 1–2 sentences (what you think Bo wants)
2. Load `.grok/skills/grilling/SKILL.md` rules
3. Ask question #1 with your recommended answer
4. Continue until Bo says go / สรุปพอ / ลุยเลย
5. Output **Decision summary** then stop (unless Bo says implement)

## maclab note

- Verify infra claims with `curl` / `ssh` / `maw hey` — don't grill about facts you can check
- Secrets stay off Discord