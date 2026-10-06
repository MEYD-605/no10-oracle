# Local LLM inference (Ollama) on ClubSGame

Ollama serves local models for Hermes and other clients. Install: `C:/Users/noone/AppData/Local/Programs/Ollama/`; models live on `E:/models/ollama` (`OLLAMA_MODELS` env var, User scope). Native API on `127.0.0.1:11434`, OpenAI-compatible `/v1` on the same port.

## Model inventory (as configured)
- `qwen-coder:latest` — alias of `qwen2.5-coder:7b` Q4_K_M, ~4.7GB, HAS `tools` capability (required for agent use). Default pick for local Hermes (`local-coder` alias).
- `qwen3:latest` / `hf.co/Qwen/Qwen3-30B-A3B-GGUF:Q4_K_M` — same 18.6GB blob (MoE 30.5B, thinking, native ctx 40960). Too big for Hermes sessions here (see context floor below); raw API one-shots only.
- `qwen30b-cpu` — variant created FROM `qwen3:latest` with `PARAMETER num_gpu 0` + `num_ctx 65536`; Hermes alias `qwen30b` points at it. `model.ollama_num_ctx: 65536` is set in this profile's config.
- `deepseek-coder-v2:16b` (~8.9GB), `qwen2.5:1.5b` (~1GB) — latter for light/fast jobs.

## Vulkan (iGPU) vs CPU-only — pick per model size
- Ollama 0.34.x loads via **Vulkan on the 780M iGPU by default**: a 7B shows `100% GPU` in `ollama ps` (~4.9GB) but only ~7 tok/s — no faster than CPU, because the iGPU has no own VRAM and shares system RAM.
- Any model with weights ≳8GB (30B Q4 = 18GB) **OOMs at Vulkan startup** (`ggml_vulkan: ErrorOutOfDeviceMemory`, `failed to allocate buffer for kv cache`) even with ~20GB RAM free — the Vulkan pinned-memory path can't allocate it. Don't chase RAM freeing; switch that model to CPU-only.
- CPU-only escape hatch: Modelfile `FROM <model>` + `PARAMETER num_gpu 0` (+ `num_ctx`), then `ollama create <name>-cpu -f <file>`. The 30B-A3B MoE runs ~13 tok/s CPU-only at ctx 2k (only ~3B active params) — usable for one-shot questions.

## Hermes context floor (64k) — why big models can't be agent brains here
- Hermes refuses an Ollama model whose effective/runtime context is under 64,000 tokens (two gates: "context window ... below the minimum 64,000", then "Ollama runtime context is too small for tool use"). It asks for `hermes config set model.ollama_num_ctx 65536`; a Modelfile `num_ctx` alone may not satisfy the runtime check.
- 18GB weights + KV cache at 40k ctx ≈ **33GB resident on a 32GB box → free RAM ~1GB → swap thrash** (one trivial query = many minutes). The Qwen3-30B GGUF's native max (40960) also clamps below the floor anyway.
- **Hardware Scaling (32GB vs 64GB vs Strix Halo):**
  - **On 32GB Handhelds (ClubSGame / 7840U / 780M)**: 30B MoE cannot be an agent brain. The sweet spot is `local-3b` (Qwen 2.5 3B, 7.6GB residency, leaves ~12GB free, finishes tasks in ~2 min) or one-shot raw API queries.
  - **On 64GB LPDDR5X-7500 Handhelds (Ryzen AI 9 HX 370 / Radeon 890M)**: 30B MoE (18GB weights + 6GB KV cache) fits with 35-40GB RAM to spare for OS/tools, eliminating swap thrash. Measured community inference yields **20–37 tok/s** via Vulkan / ROCm.
  - **Future 256-bit Unified (Strix Halo / Ryzen AI Max)**: Memory bandwidth jumps from 120 GB/s to 270+ GB/s, unlocking 70B models at 15–20 tok/s and 30B at 40–50 tok/s natively.
- vLLM does not rescue this: no CUDA on the box, the 780M (gfx1152) is outside ROCm's support matrix, vLLM's Vulkan plugin is experimental/dGPU-validated, and single-stream decode is bounded by shared-RAM bandwidth, not engine batching. Engine swaps only start mattering on a real dGPU node.

## Testing a local alias through Hermes — verify it's actually local
- A 500 from Ollama (classic cause: Vulkan OOM on load) makes Hermes **silently fall back up the provider chain** — the printed answer may be gemini's, not the local model's. Grep the run output for `Model fallback` before reporting any local-model result.
- Small models are unreliable at the tool protocol through the full agent loop: a 7B has answered a trivial math query by printing raw `{"name":"terminal", ...}` JSON as visible text, after 3+ minutes. Local models = short no-tool queries or last-resort fallback; agent work stays on the remote brain (the glm → gemini-flash → local-coder fallback chain in config is the intended shape).
- Any local model evaluating Hermes's full system prompt takes MINUTES per turn, not seconds — don't mistake it for a hang. Watch `ollama ps` and `netstat -ano | grep 11434 | grep ESTAB` instead of staring at the CLI.

## UTF-8 payloads and speed measurement
- Inline Thai in `curl -d '{"...ไทย..."}'` from git-bash arrives mangled (model sees `????`). Write the JSON payload to a file (write_file, UTF-8) and use `curl -d @file`.
- Measure with `/api/chat` + `"stream":false`: tok/s = `eval_count / (eval_duration/1e9)` from the response; `load_duration` shows model-load cost. For qwen3 thinking models append `/no_think` to the prompt or all tokens go to reasoning.

## Diagnosis: "model won't answer / connection refused on 11434"
1. `tasklist | grep -iE "ollama|llama"` — if `llama-server.exe` PIDs exist but no `ollama.exe`, the daemon died and left orphans holding 3–13GB RAM each.
2. Map each orphan to its model: `powershell Get-CimInstance Win32_Process | Where-Object {$_.CommandLine -match "llama-server"}` → the `--model E:\models\ollama\blobs\sha256-<digest>` arg, then match `<digest>` against layer digests in `E:/models/ollama/manifests/**` (python json walk). `wmic` is dead on Win11 — use CIM.
3. Kill orphans: `powershell Stop-Process -Id <pid>,<pid> -Force`.
4. Restart daemon as a BACKGROUND terminal process (`"C:/Users/noone/AppData/Local/Programs/Ollama/ollama.exe" serve`, background=true) — a PS `Start-Process` launch died quietly within minutes once; the bash-background launch held. Verify: `netstat -ano | grep 11434` LISTENING, then `curl -s 127.0.0.1:11434/api/tags`.
5. Prove generation end-to-end: `curl -s 11434/api/generate -d '{"model":"qwen-coder:latest","prompt":"Say OK","stream":false,"options":{"num_predict":10}}'` — first call after a kill pays ~7s+ model (re)load.

## Binding into Hermes (this profile)
```
hermes config set model.aliases.local-coder.model "qwen-coder:latest"
hermes config set model.aliases.local-coder.provider custom
hermes config set model.aliases.local-coder.base_url "http://127.0.0.1:11434/v1"
```
- Setting the three leaf keys one-by-one works; the short scalar form (`custom/qwen-coder:latest`) leaves no base_url and must be overwritten by the full form anyway.
- An alias with its own `base_url` authenticates independently — no key needed for local Ollama.

## Thermal envelope
- Under full CPU eval (from `get_sensors.ps1`): CPU Tctl ~73°C @ ~22W package — heavy but normal-load; battery warning 89°C / critical 94°C. The fan ramps; the machine holds.
