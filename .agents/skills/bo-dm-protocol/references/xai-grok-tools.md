# xAI / Grok tools (Hermes) — inventory for Bo

When Bo asks “tools ฝั่ง grok มีอะไร / x_search เป็น tools grok หรา” — answer from this inventory. Verify live enablement with:

```bash
HERMES_HOME=~/.hermes-gmgrok hermes tools list
```

Credential gate for **xAI-native** tools: SuperGrok OAuth (`hermes auth`) **or** `XAI_API_KEY`. Prefer OAuth when both exist (subscription quota).

## Present to Bo first (LEGIBILITY — mandatory)
Do **not** open with a dense Layer A/B monospaced dump. Preferred shape:
1. One short sentence: “ของ Grok แท้มีไม่กี่อย่าง หลักๆ …”
2. **2–4 groups in spoken Thai** with emoji (ค้น X / เว็บแบบ Grok / วิดีโอ / รูป)
3. Optional: PNG card map (HTML→Chrome headless screenshot → `MEDIA:` or `hermes send`)
4. One-line “ตอนนี้ gmgrok เปิดอะไร” after live `hermes tools list`
5. Split if near Discord 2000-char limit

For **Grok CLI / Grok Build** (terminal `grok`, not Hermes toolsets) see `references/grok-cli-tools-map.md`.

## Layer A — xAI/Grok-native (credential-gated)

| Tool / surface | Toolset | Capability | Notes |
|----------------|---------|------------|--------|
| **`x_search`** | `x_search` | Search X posts, profiles, threads | Server-side via xAI Responses API (`api.x.ai/v1/responses`). Prefer over `web_search` for “what’s being said on X”. |
| **`web_search` (backend xai)** | `web` | Web search run by Grok server-side | Config `web.backend: xai`. Not a separate tool name. |
| **`video_generate`** | `video_gen` | text→video / image→video | Often disabled by default. |
| **`xai_video_edit`** | `video_gen` | Edit existing video | Provider-specific. |
| **`xai_video_extend`** | `video_gen` | Extend video length | Provider-specific. |
| **`image_generate`** | `image_gen` | Image gen / image-to-image | Backend may be FAL, OpenAI, or xAI Grok Imagine — check config. |

## Layer B — Hermes general tools (not Grok-only)

terminal, file, browser, vision, code_execution, memory, session_search, cronjob, delegation, computer_use, tts, skills, todo, clarify, etc.

## gmgrok typical snapshot (re-check live)
- `x_search` often enabled · `image_gen` often on · `video_gen` often off
- MCP extras are not Grok tools (arra-oracle, discord-reply)

## Pitfalls
- Claiming `x_search` works without xAI credentials.
- A value in `XAI_API_KEY` that starts `eyJ` is a **stale OAuth JWT**, not an
  xAI API key (`xai-…`). Hermes prefers `xai-oauth` first; a dead token with
  no refresh yields `unauthenticated:bad-credentials` even when the toolset
  shows enabled. Fix: `hermes auth add xai-oauth` (SuperGrok) or a real
  `xai-` API key. Do not copy JWT leftovers across seats.
- Conflating Hermes xAI auth with `~/.grok/auth.json`.
- Dumping SEAL/tool-ID walls after Bo complained about legibility.
