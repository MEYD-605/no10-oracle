# maw-rs Non-Claude AI Pane Detection — RCA + Fix (2026-07-25)

## Context

Bo asked fleet to investigate why maw-rs has more problems with non-Claude CLIs (Hermes, Grok CLI, Gemini/agy) than the old maw-js that P'Nat built. The RCA found **2 code locations** and discovered that No.1 had already committed one fix.

## Bug #1: `is_claude_like_pane()` — process name detection

**File:** `crates/maw-tmux/src/core_impl/action_resolution_parts/safety_layout_validation.rs`

**Root cause:** Original function only matched `"claude"` substring or three-part numeric versions (`2.1.111`). Non-Claude agents (Hermes=python3.11, Grok=grok-0.2.112-ma, Gemini=agy) returned `false`.

**Impact:** maw didn't detect non-Claude panes as AI agents → no safety guard on `send_command`, wrong session tags (`orphan`), `maw ls` didn't classify them correctly.

**Fix (committed by No.1 as `65ab33b`):**
- Renamed logically to `is_ai_cli_pane()` (kept `is_claude_like_pane` as alias for API stability)
- Added `AI_CLI_KEYWORDS` const array: `claude`, `grok`, `grok-macos`, `gemini`, `agy`, `antigravity`, `codex`, `opencode`, `aider`, `aichat`, `crush`, `hermes`, `hermes_cli`, `qwen`, `kiro`, `cursor`, `copilot`, `mimo`

## Bug #2: `line_is_tui_chrome()` — idle/busy state detection

**File:** `crates/maw-tmux/src/core_impl/action_resolution_parts/pending_input_detection.rs:157-166`

**Root cause:** Function that detects whether an agent pane is showing idle prompt (vs busy thinking) only matched Claude patterns: `gpt-`, `claude`, `opus`, `sonnet`, `haiku`, `fable`, `? for shortcuts`, `context left`.

**Impact:** maw couldn't detect idle state of non-Claude agents → couldn't tell if agent was ready to receive input or mid-turn → messages could collide with active AI thinking.

**Fix (committed by No.1 as `7c6f4fb`, also independently patched by gmgrok):**
Added patterns for:
- Grok: `grok-`, `always-approve`
- Gemini: `gemini`, `flash`, `agy`
- Hermes: `hermes`
- Other: `qwen`, `codex`, `aider`, `opencode`
- Common TUI chrome hints: `enter:send`, `shift+tab:mode`, `esc:cancel`, `ctrl+x:shortcuts`

## Key Lesson: git log before claiming a bug

**Bo fury:** "ไม่เห็นหรือว่าเพื่อนทำอยู่" — gmgrok spent significant effort finding the RCA, only to discover No.1 had already committed both fixes (`65ab33b`, `7c6f4fb`) minutes earlier. The binary running on maclab (`v26.7.16-5-g36fe495`) already included the fixes.

**Rule:** Before presenting a bug discovery, run `git log --oneline -5` in the relevant repo to see if a peer already committed a fix. Check `git show <hash>` for the diff. Don't duplicate work that's already done.

## Build + Deploy procedure (macOS maclab)

```bash
cd /Users/admin/Code/github.com/Soul-Brews-Studio/maw-rs

# 1. Build
cargo build --release -p maw-tmux    # ~3s incremental
cargo build --release -p maw-cli     # ~2-3min full

# 2. Binary location
ls target/release/maw-rs             # NOT "maw" — binary is named maw-rs

# 3. Deploy
cp /Users/admin/.local/bin/maw-rs.real /Users/admin/.local/bin/maw-rs.real.bak.$(date +%Y%m%d_%H%M%S)
cp target/release/maw-rs /Users/admin/.local/bin/maw-rs.real

# 4. Restart serve
kill $(pgrep -f 'maw-rs serve'); sleep 1
nohup /Users/admin/.local/bin/maw-rs.real serve --host 0.0.0.0 --port 3456 > /tmp/maw-rs-serve.log 2>&1 &

# 5. Verify
/Users/admin/.local/bin/maw-rs.real --version
curl -sS -m 3 http://127.0.0.1:3456/ | head -2
```

## Test procedure

```bash
# Unit tests
cargo test -p maw-tmux    # expect: 85 passed, 0 failed

# Live delivery test — send to each CLI type
maw hey 00-gmgrok "test from gmgrok"       # Hermes (python3.11)
maw hey 01-lord-knight "test"               # Grok (grok-0.2.112-ma)
maw hey 06-gemini "test"                    # Gemini (agy)

# Verify delivery — check pane
tmux capture-pane -t "01-lord-knight:0.0" -p | tail -10

# Check idle detection
maw ls -v    # ● = active, ◌ = idle/inactive
```

## Known cosmetic issue

`06-gemini` and `88-sombo` may show `[orphan]` tag in `maw ls -v` even though they are registered as `maclab` in fleet config. This is a session-name matching issue in `session_tag_shell_parsers.rs:114` / `session_list_plan.rs:729-735` — it checks `fleet_sessions.contains(session)` where session = tmux session name. Does NOT affect message delivery. Cosmetic only.

## Process name reference (live fleet)

| CLI | pane_current_command | AI_CLI_KEYWORDS match |
|-----|---------------------|----------------------|
| Claude Code | `claude` | `claude` ✅ |
| Grok CLI | `grok-0.2.112-ma` | `grok` ✅ |
| Hermes Agent | `python3.11` | `hermes` (via pane title/path context, not bare python) ⚠️ |
| Gemini/agy | `agy` | `agy` ✅ |

**Note:** Hermes runs as `python3.11` — bare `python`/`node` is intentionally NOT in AI_CLI_KEYWORDS (too broad). Detection relies on the tmux session being registered in fleet config or the pane title containing `hermes`.
