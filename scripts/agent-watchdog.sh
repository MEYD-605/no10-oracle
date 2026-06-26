#!/bin/bash
# agent-watchdog.sh — Oracle Council Agent Watchdog
# Detects dead claude processes in tmux sessions and restarts them
# Usage: ./agent-watchdog.sh [--dry-run]

set -euo pipefail

# flock guard (added 2026-06-12 after watchdog-storm incident): never let cron stack instances.
# If a prior run is still alive (e.g. tmux slow/wedged), exit immediately instead of piling up.
exec 9>/tmp/agent-watchdog.lock
flock -n 9 || { echo "$(date -Is) watchdog: another instance running — skip" >> /root/maw-workspace/agents/logs/watchdog.log 2>/dev/null; exit 0; }

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

LOG_FILE="/root/maw-workspace/agents/logs/watchdog.log"
FLEET_STATUS_FILE="/root/maw-workspace/agents/fleet-status.json"
RESTART_DELAY=3  # seconds before starting claude after shell is ready
CONTEXT_ALERT_PCT=50   # log warning when context reaches this %
CONTEXT_RESET_PCT=60   # auto /rrr /clear when context reaches this % (default for 200k agents)
# Per-agent absolute-token override (Bo directive 2026-04-27): for 1M-context agents,
# trigger reset at 500k tokens (= 50%) rather than 60% (=600k) which is too late/expensive.
# Sessions listed here use TOKENS_K threshold instead of percentage.
declare -A CONTEXT_RESET_TOKENS_K=(
    ["00-paladin"]=500
    ["01-lord-knight"]=500
    ["03-agent"]=500
    ["04-mimo"]=500
    ["88-sombo"]=500
    ["99-joker"]=500
    ["100-lucid"]=500
)
MAW_URL="http://localhost:3456"
SPAWN_PROMPTS="/root/maw-workspace/agents/1/ψ/memory/mailbox/teams/oracle-council"
# Post-reboot: --continue pulls broken MCP state. Start fresh if uptime < 10 min.
FRESH_BOOT_THRESHOLD=600
UPTIME_SEC=$(awk '{print int($1)}' /proc/uptime)
IS_FRESH_BOOT=false
[[ "$UPTIME_SEC" -lt "$FRESH_BOOT_THRESHOLD" ]] && IS_FRESH_BOOT=true

mkdir -p "$(dirname "$LOG_FILE")"

log() {
    local ts
    ts=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$ts] $*" | tee -a "$LOG_FILE"
}

# Get current foreground command in a tmux session
# Returns "claude", "node", "bash", "zsh", etc.
pane_cmd() {
    local session="$1"
    tmux display-message -t "$session" -p "#{pane_current_command}" 2>/dev/null || echo "DEAD"
}

# Check if a tmux session exists
session_exists() {
    tmux has-session -t "$1" 2>/dev/null
}

# Send command to tmux pane
send_cmd() {
    local session="$1"
    local cmd="$2"
    if $DRY_RUN; then
        log "[DRY-RUN] Would send to $session: $cmd"
    else
        tmux send-keys -t "$session" "$cmd" Enter
    fi
}

# Check if agent is alive by walking the process tree from the pane shell
# This avoids false positives when claude is temporarily running a bash subcommand
is_alive() {
    local session="$1"
    local pane_pid

    # Get the shell PID of the tmux pane
    pane_pid=$(tmux display-message -t "$session" -p "#{pane_pid}" 2>/dev/null) || return 1
    [[ -z "$pane_pid" ]] && return 1

    # Walk up to 4 levels deep in the process tree looking for claude/node
    local pids="$pane_pid"
    local depth=0
    while [[ $depth -lt 5 ]]; do
        local next_pids=""
        for pid in $pids; do
            local comm
            comm=$(cat /proc/"$pid"/comm 2>/dev/null) || continue
            # Match claude binary or node running claude
            if [[ "$comm" == "claude" ]]; then
                return 0
            fi
            if [[ "$comm" == "node" ]]; then
                # Verify it's actually running claude (not some other node process)
                local cmdline
                cmdline=$(tr '\0' ' ' < /proc/"$pid"/cmdline 2>/dev/null)
                if [[ "$cmdline" == *"claude"* ]]; then
                    return 0
                fi
            fi
            # Collect children for next iteration
            local children
            children=$(pgrep -P "$pid" 2>/dev/null | tr '\n' ' ')
            next_pids="$next_pids $children"
        done
        [[ -z "$next_pids" ]] && break
        pids="$next_pids"
        ((depth++)) || true
    done
    return 1
}

# Agent definitions: session_name|working_dir|start_command
# Format: "session|dir|cmd"
declare -a AGENTS=(
    # All agents now have per-bot Discord identity. Use `export` form so DISCORD_STATE_DIR
    # sticks in the pane shell — survives manual `claude` re-invocations without re-typing env.
    # Fixed 2026-04-23 (Bo directive): reboot scenario where inline prefix was lost caused
    # 5 agents to spawn with unset DSD → Discord plugin couldn't route inbound messages.
    # NOTE: 2026-04-20 Bo directive — fleet on Opus 4.6; only No.0 Paladin retains 4.7[1m] for strategic layer
    # ALL agents on acc-2 (Bo directive 2026-05-22: acc1 expired)
    # Explicit paths — no symlink dependency
    "00-paladin|/root/Code/github.com/MEYD-605/paladin-oracle|export CLAUDE_CONFIG_DIR=/root/.claude-acc-2 FLEET_AGENT_NAME=00-paladin MAW_SENDER=ai-core:00-paladin DISCORD_STATE_DIR=/root/.claude/channels/discord-no0 && claude --model 'claude-opus-4-6' --name 'No.0 Paladin' --continue --channels plugin:discord@claude-plugins-official"
    "01-lord-knight|/root/Code/github.com/MEYD-605/lord-knight-oracle|export CLAUDE_CONFIG_DIR=/root/.claude-acc-2 FLEET_AGENT_NAME=01-lord-knight MAW_SENDER=ai-core:01-lord-knight DISCORD_STATE_DIR=/root/.claude/channels/discord-no1 && claude --model 'claude-opus-4-8[1m]' --name 'No.1 Lord Knight' --continue --channels plugin:discord@claude-plugins-official"
    "03-agent|/root/Code/github.com/MEYD-605/developer-oracle|export CLAUDE_CONFIG_DIR=/root/.claude-acc-2 FLEET_AGENT_NAME=03-agent MAW_SENDER=ai-core:03-agent DISCORD_STATE_DIR=/root/.claude/channels/discord-no3 && claude --model 'claude-opus-4-6' --name 'No.3 Developer' --continue --channels plugin:discord@claude-plugins-official"
    "04-mimo|/root/Code/github.com/MEYD-605/mimo-oracle|export CLAUDE_CONFIG_DIR=/root/.claude-acc-2 FLEET_AGENT_NAME=04-mimo MAW_SENDER=ai-core:04-mimo DISCORD_STATE_DIR=/root/.claude/channels/discord-no4 && claude --model 'claude-opus-4-6' --name 'No.4 MIMO' --continue --channels plugin:discord@claude-plugins-official"
    "99-joker|/root/Code/github.com/MEYD-605/joker-oracle|export CLAUDE_CONFIG_DIR=/root/.claude-acc-2 FLEET_AGENT_NAME=99-joker MAW_SENDER=ai-core:99-joker DISCORD_STATE_DIR=/root/.claude/channels/discord-no99 BG_REVIEW_ENABLE=1 BG_REVIEW_THRESHOLD=40 && claude --model 'claude-sonnet-4-6' --name 'No.99 Joker' --continue --channels plugin:discord@claude-plugins-official"
    # No Discord agents (No.2, No.5) — no --channels flag, no DISCORD_STATE_DIR
    "02-high-wizard|/root/Code/github.com/MEYD-605/high-wizard-oracle|export CLAUDE_CONFIG_DIR=/root/.claude-acc-2 FLEET_AGENT_NAME=02-high-wizard MAW_SENDER=ai-core:02-high-wizard && claude --model 'claude-opus-4-6' --name 'No.2 High Wizard' --continue"
    "05-cartographer|/root/Code/github.com/MEYD-605/cartographer-oracle|export CLAUDE_CONFIG_DIR=/root/.claude-acc-2 FLEET_AGENT_NAME=05-cartographer MAW_SENDER=ai-core:05-cartographer && claude --model 'claude-opus-4-6' --name 'No.5 Cartographer' --continue"
    # Secretary tier — Sonnet 4.6[1m], Bo-facing, routes heavy work to No.1
    "88-sombo|/root/Code/github.com/MEYD-605/sombo-oracle|export CLAUDE_CONFIG_DIR=/root/.claude-acc-2 FLEET_AGENT_NAME=88-sombo MAW_SENDER=ai-core:88-sombo DISCORD_STATE_DIR=/root/.claude/channels/discord-sombo && claude --model 'claude-opus-4-6[1m]' --name 'No.88 Sombo' --continue --channels plugin:discord@claude-plugins-official"
    # Lucid (No.100) — Opus 4.7[1m], handles P'Nat channels (Lucid primary per Bo directive 2026-05-09)
    "100-lucid|/root/Code/github.com/MEYD-605/lucid-oracle|export CLAUDE_CONFIG_DIR=/root/.claude-acc-2 FLEET_AGENT_NAME=100-lucid MAW_SENDER=ai-core:100-lucid DISCORD_STATE_DIR=/root/.claude/channels/discord-lucid && claude --model 'claude-sonnet-4-6' --name 'No.100 Lucid' --continue --channels plugin:discord@claude-plugins-official"
    # No.7 Hermes — runs as Hermes Agent gateway (systemd --user daemon), NOT claude.
    # DO NOT add a claude entry here. Hermes self-manages via: hermes gateway run --replace
    # Watchdog + fleet-boot should skip this slot. See: PID via pgrep -f hermes_cli.main
    # "07-high-class" entry REMOVED 2026-05-30 — was spawning wrong claude over Hermes.
    # No.6 Gemini — runs `agy` (Antigravity CLI), NOT claude. DO NOT add a claude entry here
    # (would spawn wrong claude over agy, same trap as Hermes). Liveness is handled separately
    # by /root/maw-workspace/scripts/gemini-keepalive.sh (cron */2) which respawns
    # `agy --dangerously-skip-permissions --continue` in 06-gemini if dead. Added 2026-06-03
    # (No.6 was going dark on Discord when agy died with no auto-restart).
)

# Sessions to skip (managed separately or expected to be non-claude)
SKIP_SESSIONS=(
    # "00-paladin" — now managed as AGENT (migrated from VM 101 to LXC 110)
    "maw-server"
    "99-overview"
)

# Map tmux session name → oracle-council agent role for reincarnation
session_to_role() {
    case "$1" in
        "03-agent")       echo "no3" ;;
        "04-mimo")        echo "no4" ;;
        "99-joker")       echo "no99" ;;
        "00-paladin")     echo "no0" ;;
        "01-lord-knight") echo "no1" ;;
        "02-high-wizard") echo "no2" ;;
        "05-cartographer") echo "no5" ;;
        "88-sombo")       echo "no88" ;;
        "100-lucid")      echo "no100" ;;
        *)                echo "" ;;
    esac
}

# Inject past life from spawn prompt after /clear
# Falls back to /recap if no spawn prompt found
inject_past_life() {
    local session="$1"
    local role
    role=$(session_to_role "$session")

    if [[ -z "$role" ]]; then
        log "REINCARNATION: $session — no role mapping, falling back to /recap"
        send_cmd "$session" '/recap'
        return
    fi

    local prompt_file="$SPAWN_PROMPTS/${role}-spawn-prompt.md"

    if [[ ! -f "$prompt_file" ]]; then
        log "REINCARNATION: $session ($role) — no spawn prompt found, falling back to /recap"
        send_cmd "$session" '/recap'
        return
    fi

    # Regenerate spawn prompt to include latest findings before injecting
    if command -v maw &>/dev/null; then
        maw team spawn oracle-council "$role" &>/dev/null || true
    fi

    if $DRY_RUN; then
        log "[DRY-RUN] Would inject past life for $session ($role)"
        return
    fi

    # Load multiline prompt via tmux buffer (safe for special chars + Thai)
    local tmpfile
    tmpfile=$(mktemp /tmp/reincarnation-XXXXXX.md)
    cat "$prompt_file" > "$tmpfile"
    tmux load-buffer "$tmpfile"
    rm -f "$tmpfile"

    tmux paste-buffer -t "$session"
    sleep 0.5
    tmux send-keys -t "$session" "" Enter
    sleep 1
    tmux send-keys -t "$session" "" Enter

    log "REINCARNATION: $session ($role) — past life injected from $prompt_file"
}

restart_agent() {
    local session="$1"
    local dir="$2"
    local cmd="$3"

    if $IS_FRESH_BOOT; then
        cmd="${cmd// --continue/}"
        log "RESTART (fresh boot, uptime ${UPTIME_SEC}s): $session — launching WITHOUT --continue"
    fi

    log "RESTART: $session — launching: $cmd (in $dir)"

    if $DRY_RUN; then
        log "[DRY-RUN] Would restart $session"
        return
    fi

    # Navigate to agent dir, then launch
    send_cmd "$session" "cd $dir && $cmd"
}

# Get context % from tmux pane status bar (reads "📊 61% (122k/200k)" format)
# Returns 0-100 or empty string if not found
get_context_pct() {
    local session="$1"
    local raw
    raw=$(tmux capture-pane -t "$session" -p 2>/dev/null | grep -o '📊 [0-9]*%' || true)
    [[ -z "$raw" ]] && return
    echo "$raw" | grep -o '[0-9]*' | tail -1
}

# Get current context tokens (in k) from "📊 61% (122k/200k)" format
# Returns the numerator (e.g. "122") or empty if not found
get_context_tokens_k() {
    local session="$1"
    local raw
    raw=$(tmux capture-pane -t "$session" -p 2>/dev/null | grep -oE '📊 [0-9]+% \([0-9]+k/' || true)
    [[ -z "$raw" ]] && return
    echo "$raw" | grep -oE '\([0-9]+k' | grep -oE '[0-9]+'
}

# Auto-reset agent when context is too high
# Sends /forward first (handoff), waits, then /clear
auto_reset_context() {
    local session="$1"
    local pct="$2"
    log "AUTO-RESET: $session (${pct}%) — sending /forward then /clear"
    if $DRY_RUN; then
        log "[DRY-RUN] Would send /forward to $session"
        return
    fi
    # Send /forward to create handoff (Bo directive 2026-04-19: use /forward not /rrr)
    tmux send-keys -t "$session" '/forward' Enter
    # Wait for /forward to complete (up to 3 minutes)
    local waited=0
    while [[ $waited -lt 180 ]]; do
        sleep 15
        ((waited+=15)) || true
        # Check if /forward is done by looking for idle prompt
        local pane_out
        pane_out=$(tmux capture-pane -t "$session" -p 2>/dev/null | tail -3)
        if echo "$pane_out" | grep -q "❯"; then
            # Idle prompt visible — /forward done, extract findings then /clear + inject
            local role
            role=$(session_to_role "$session")
            if [[ -n "$role" ]]; then
                /root/maw-workspace/scripts/retro-extract.sh "$role" &>/dev/null || true
                log "EXTRACT: $session ($role) — findings extracted"
            fi
            tmux send-keys -t "$session" '/clear' Enter
            sleep 3
            inject_past_life "$session"
            log "AUTO-RESET: $session — extract + /clear + reincarnation after /forward"
            return
        fi
    done
    # Timeout — force /clear anyway, extract + inject past life
    local role
    role=$(session_to_role "$session")
    if [[ -n "$role" ]]; then
        /root/maw-workspace/scripts/retro-extract.sh "$role" &>/dev/null || true
    fi
    tmux send-keys -t "$session" '/clear' Enter
    sleep 3
    inject_past_life "$session"
    log "AUTO-RESET: $session — extract + /clear + reincarnation (timeout)"
}

# Write fleet status to JSON file
write_fleet_status() {
    local ts
    ts=$(date '+%Y-%m-%dT%H:%M:%S+07:00')
    local entries=""
    for key in "${!FLEET_DATA[@]}"; do
        [[ -n "$entries" ]] && entries="$entries,"
        entries="$entries${FLEET_DATA[$key]}"
    done
    cat > "$FLEET_STATUS_FILE" <<EOF
{
  "updated_at": "$ts",
  "agents": {
    $entries
  },
  "summary": {
    "ok": $OK,
    "restarted": $RESTARTED,
    "skipped": $SKIPPED
  }
}
EOF
    log "Fleet status written → $FLEET_STATUS_FILE"
}

# ── Main loop ──────────────────────────────────────────────────────────────────

log "=== Oracle Watchdog START (dry_run=$DRY_RUN) ==="

RESTARTED=0
SKIPPED=0
OK=0
ctx_pct=""
declare -A FLEET_DATA

for entry in "${AGENTS[@]}"; do
    IFS='|' read -r session dir cmd <<< "$entry"

    if ! session_exists "$session"; then
        log "MISSING SESSION: $session — skipping (session does not exist)"
        ((SKIPPED++)) || true
        FLEET_DATA["$session"]="\"$session\": {\"status\": \"missing\", \"context_pct\": null, \"uptime\": null}"
        continue
    fi

    # Get process uptime (best-effort)
    pane_pid=$(tmux display-message -t "$session" -p "#{pane_pid}" 2>/dev/null || echo "")
    uptime_sec=""
    if [[ -n "$pane_pid" ]]; then
        uptime_sec=$(ps -o etimes= -p "$pane_pid" 2>/dev/null | tr -d ' ') || uptime_sec=""
    fi

    if is_alive "$session"; then
        # Check context — per-agent token override for 1M sessions (No.0, No.1)
        ctx_pct=$(get_context_pct "$session")
        should_reset=false
        if [[ -n "${CONTEXT_RESET_TOKENS_K[$session]+x}" ]]; then
            ctx_tokens=$(get_context_tokens_k "$session")
            token_limit=${CONTEXT_RESET_TOKENS_K[$session]}
            if [[ -n "$ctx_tokens" && "$ctx_tokens" -ge "$token_limit" ]]; then
                log "CONTEXT CRITICAL: $session (${ctx_tokens}k tokens ≥ ${token_limit}k limit) — auto-resetting"
                should_reset=true
            fi
        elif [[ -n "$ctx_pct" && "$ctx_pct" -ge "$CONTEXT_RESET_PCT" ]]; then
            log "CONTEXT CRITICAL: $session (${ctx_pct}%) — auto-resetting"
            should_reset=true
        fi
        # DISABLED 2026-05-14: context reset consolidated into session-policy.sh
        # Watchdog now only handles dead-process restarts, not context management.
        # — No.1, Bo directive "ระบบซ้ำ 3 ตัว ทำ forward รัวๆ"
        if false; then
            :
        elif [[ -n "$ctx_pct" && "$ctx_pct" -ge "$CONTEXT_ALERT_PCT" ]]; then
            log "CONTEXT NOTE: $session (${ctx_pct}%) — session-policy.sh handles reset"
            FLEET_DATA["$session"]="\"$session\": {\"status\": \"warn\", \"context_pct\": $ctx_pct, \"uptime_sec\": ${uptime_sec:-null}}"
        else
            log "OK: $session ($(pane_cmd "$session")${ctx_pct:+ ctx=${ctx_pct}%})"
            FLEET_DATA["$session"]="\"$session\": {\"status\": \"ok\", \"context_pct\": ${ctx_pct:-null}, \"uptime_sec\": ${uptime_sec:-null}}"
        fi
        ((OK++)) || true
    else
        log "DEAD: $session ($(pane_cmd "$session")) — restarting"
        restart_agent "$session" "$dir" "$cmd"
        ((RESTARTED++)) || true
        FLEET_DATA["$session"]="\"$session\": {\"status\": \"restarted\", \"context_pct\": null, \"uptime_sec\": ${uptime_sec:-null}}"
        sleep "$RESTART_DELAY"
    fi
done

log "=== DONE: $OK alive, $RESTARTED restarted, $SKIPPED skipped ==="

# ── Discord window pass — DISABLED (Bo directive 2026-04-24) ──────────────────
# Superseded: Discord is now built into main claude command via --channels flag.
# Each agent runs 1 window only (no separate discord window).
# Old directive (2026-04-23) created separate discord windows; that's no longer needed.
log "=== DISCORD WINDOWS: skipped (built into main command) ==="

# Write fleet status JSON
write_fleet_status

# Print summary for Discord reporting
echo ""
echo "Watchdog Summary:"
echo "  OK:        $OK"
echo "  Restarted: $RESTARTED"
echo "  Skipped:   $SKIPPED"
echo "  Log:       $LOG_FILE"
echo "  Fleet:     $FLEET_STATUS_FILE"
