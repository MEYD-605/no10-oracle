#!/bin/bash
# session-policy.sh — Hermes-inspired session lifecycle manager
# Replaces watchdog context-reset with smarter per-agent policies
#
# Pattern: Exemplar-driven Architecture Adoption from NousResearch/hermes-agent
# - Session reset policies: daily, idle, both, none
# - Context-aware (token tracking via statusline)
# - Self-healing (auto /forward + /clear when threshold met)
#
# Usage: session-policy.sh [--dry-run] [--agent <name>] [--status]
# Cron: */5 * * * * /root/maw-workspace/scripts/session-policy.sh

set -euo pipefail

DRY_RUN=false
SINGLE_AGENT=""
STATUS_ONLY=false
LOG_FILE="/root/maw-workspace/agents/logs/session-policy.log"

# HARD_CEIL_K is calculated dynamically in the loop per session (200k to 500k)

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --agent) SINGLE_AGENT="$2"; shift 2 ;;
    --status) STATUS_ONLY=true; shift ;;
    *) shift ;;
  esac
done

mkdir -p "$(dirname "$LOG_FILE")"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

# Hardened send-keys (Bo incident 2026-06-03): a momentarily-blocked tmux server
# once froze a bare `tmux send-keys` for 12h, hanging the whole cron run and
# piling zombie session-policy.sh processes. `timeout` caps any single send so a
# stuck client can never freeze the run; failure is logged, not fatal.
send_keys() {
  local sess="$1" keys="$2"
  if ! timeout 10 tmux send-keys -t "$sess" "$keys" Enter 2>/dev/null; then
    log "SEND-KEYS TIMEOUT/FAIL: $sess <- '$keys' (skipped to avoid hang)"
    return 1
  fi
}

# --- Concurrency lock (Bo incident 2026-06-03) ---------------------------------
# do_reset() blocks up to 300s waiting on /forward. Cron fires every 5min (300s),
# so a slow/timed-out reset guarantees the NEXT cron tick starts before this one
# finishes → two+ copies send /forward,/clear,/recap to the SAME pane = corrupted
# session + "ส่งคำสั่งหลายที". flock makes the run mutually exclusive; if one is
# still working, the new tick exits immediately instead of piling on.
# (--status/--dry-run are read-only, exempt so manual inspection still works.)
if ! $STATUS_ONLY && ! $DRY_RUN; then
  exec 200>/tmp/session-policy.lock
  if ! flock -n 200; then
    log "SKIP: another session-policy run is in progress (lock held) — exiting"
    exit 0
  fi
fi

# Per-agent session policies (hermes pattern: daily/idle/both/none)
# Format: "session_name|policy|idle_minutes|context_threshold_pct|daily_reset_hour"
declare -a POLICIES=(
  "00-paladin|both|30|50|03"
  "01-lord-knight|both|30|85|06"
  "03-agent|both|30|50|03"
  "04-mimo|both|30|50|03"
  "99-joker|both|30|50|03"
  "02-high-wizard|both|30|50|03"
  "05-cartographer|both|30|50|03"
  "88-sombo|both|30|50|03"
  "100-lucid|both|30|50|03"
  "06-gemini|both|30|50|03"
  "08-agy-nano2|both|30|50|03"
  "103-no10|both|30|50|03"
)

get_context_tokens_k() {
  local session="$1"
  local raw
  raw=$(tmux capture-pane -t "$session" -p 2>/dev/null | grep -oE '📊 [0-9]+% \([0-9]+k/' || true)
  if [[ -z "$raw" ]]; then
    local pct
    pct=$(tmux capture-pane -t "$session" -p 2>/dev/null | grep -oE '📊 Ctx: [0-9]+%' | grep -oE '[0-9]+' || true)
    if [[ -n "$pct" ]]; then
      echo $(( 1000 * pct / 100 ))
      return
    fi
    echo "0"
    return
  fi
  echo "$raw" | grep -oE '\([0-9]+k' | grep -oE '[0-9]+'
}

get_max_context_tokens_k() {
  local session="$1"
  local raw
  raw=$(tmux capture-pane -t "$session" -p 2>/dev/null | grep -oE '📊 [0-9]+% \([0-9]+k/[0-9]+k\)' || true)
  [[ -z "$raw" ]] && echo "1000" && return
  echo "$raw" | grep -oE '/[0-9]+k' | grep -oE '[0-9]+'
}

get_idle_minutes() {
  local session="$1"
  local last_activity
  last_activity=$(tmux display-message -t "$session" -p "#{window_activity}" 2>/dev/null || echo "0")
  [[ -z "$last_activity" || "$last_activity" == "0" ]] && echo "999999" && return
  local now
  now=$(date +%s)
  local idle_secs=$(( now - last_activity ))
  echo $(( idle_secs / 60 ))
}

is_claude_alive() {
  local session="$1"
  local pane_pid
  pane_pid=$(tmux display-message -t "$session" -p "#{pane_pid}" 2>/dev/null) || return 1
  [[ -z "$pane_pid" ]] && return 1
  pgrep -P "$pane_pid" -f "(claude|agy)" &>/dev/null
}

check_daily_reset() {
  local session="$1"
  local reset_hour="$2"
  [[ -z "$reset_hour" ]] && return 1

  local current_hour
  current_hour=$(date +%H)
  local flag_file="/tmp/session-policy-daily-${session}-$(date +%Y%m%d)"

  if [[ "$current_hour" == "$reset_hour" ]] && [[ ! -f "$flag_file" ]]; then
    touch "$flag_file"
    return 0
  fi
  return 1
}

do_reset() {
  local session="$1"
  local reason="$2"

  log "RESET: $session — $reason"

  if $DRY_RUN; then
    log "[DRY-RUN] Would /forward --only + /clear $session"
    return
  fi

  # Phase 1: /forward --only (P'Nat's design — handoff without plan mode)
  # Old approach used bare /forward which enters plan mode → hangs → 0% success
  send_keys "$session" '/forward --only' || true
  local waited=0
  local forward_ok=false
  while [[ $waited -lt 300 ]]; do
    sleep 15
    ((waited+=15)) || true
    local pane_out
    pane_out=$(tmux capture-pane -t "$session" -p 2>/dev/null | tail -5)
    if echo "$pane_out" | grep -qE "❯|Handoff|handoff.*written|/plan"; then
      forward_ok=true
      log "FORWARD OK: $session — completed in ${waited}s"
      break
    fi
  done

  if ! $forward_ok; then
    log "FORWARD TIMEOUT: $session — fallback to git commit ψ/"
    # Fallback: at least save uncommitted vault files
    local agent_repo=""
    case "$session" in
      00-paladin)      agent_repo="/root/Code/github.com/MEYD-605/paladin-oracle" ;;
      01-lord-knight)  agent_repo="/root/Code/github.com/MEYD-605/lord-knight-oracle" ;;
      03-agent)        agent_repo="/root/Code/github.com/MEYD-605/dev-oracle" ;;
      04-mimo)         agent_repo="/root/Code/github.com/MEYD-605/mimo-oracle" ;;
      05-cartographer) agent_repo="/root/Code/github.com/MEYD-605/cartographer-oracle" ;;
      88-sombo)        agent_repo="/root/Code/github.com/MEYD-605/sombo-oracle" ;;
      99-joker)        agent_repo="/root/Code/github.com/MEYD-605/joker-oracle" ;;
      100-lucid)       agent_repo="/root/Code/github.com/MEYD-605/lucid-oracle" ;;
      02-high-wizard)  agent_repo="/root/Code/github.com/MEYD-605/high-wizard-oracle" ;;
      06-gemini)       agent_repo="/root/Code/github.com/MEYD-605/gemini-oracle" ;;
      08-agy-nano2)    agent_repo="/root/Code/github.com/MEYD-605/agy-nano2-oracle" ;;
      103-no10)        agent_repo="/root/Code/github.com/MEYD-605/no10-oracle" ;;
    esac
    if [[ -n "$agent_repo" && -d "$agent_repo/ψ" ]]; then
      ( cd "$agent_repo" 2>/dev/null && \
        git add ψ/ 2>/dev/null && \
        git diff --cached --quiet 2>/dev/null || \
        git commit -m "auto: pre-reset save (session-policy daily)" 2>/dev/null ) && \
        log "FALLBACK SAVED: $session — committed ψ/ changes"
    fi
  fi

  # Phase 2: /clear + /recap
  sleep 3
  send_keys "$session" '/clear' || true
  sleep 3
  send_keys "$session" '/recap' || true
  log "RESET COMPLETE: $session — forward=$forward_ok + /clear + /recap"
}

# Main loop
log "=== Session Policy Check (dry_run=$DRY_RUN) ==="

for entry in "${POLICIES[@]}"; do
  IFS='|' read -r session policy idle_min threshold_k daily_hour <<< "$entry"

  [[ -n "$SINGLE_AGENT" && "$session" != "$SINGLE_AGENT" ]] && continue

  if ! tmux has-session -t "$session" 2>/dev/null; then
    [[ "$STATUS_ONLY" == true ]] && echo "$session: no session"
    continue
  fi

  if ! is_claude_alive "$session"; then
    [[ "$STATUS_ONLY" == true ]] && echo "$session: claude not running"
    continue
  fi

  local_tokens_k=$(get_context_tokens_k "$session")
  local_tokens_k=${local_tokens_k:-0}

  local_max_k=$(get_max_context_tokens_k "$session")
  local_max_k=${local_max_k:-1000}

  local_threshold_k=$(( local_max_k * threshold_k / 100 ))

  # Dynamic hard context ceiling: dynamic between 300k and 500k
  local_hard_ceil_k=$(( local_max_k / 2 ))
  if [ "$local_hard_ceil_k" -lt 300 ]; then
    local_hard_ceil_k=300
  fi
  if [ "$local_hard_ceil_k" -gt 500 ]; then
    local_hard_ceil_k=500
  fi

  if $STATUS_ONLY; then
    echo "$session: policy=$policy tokens=${local_tokens_k}k/${local_max_k}k threshold=${local_threshold_k}k (${threshold_k}%) hard_ceil=${local_hard_ceil_k}k idle_min=${idle_min}"
    continue
  fi

  idle_min_actual=$(get_idle_minutes "$session")

  # Hard ceiling first — fires regardless of policy/idle (anti-runaway, Bo 2026-06-01)
  # Cooldown (Bo incident 2026-06-03): after a reset, /clear takes ~1-2 cron ticks
  # to actually drop the statusline number, and on a BUSY agent /forward can time
  # out (300s) so the number even climbs further before it lands. Without a cooldown
  # the next ticks each re-detect >500k and fire AGAIN (7x today: 508→638k while the
  # clear was still in flight). Hold off re-firing for HARD_CEIL_COOLDOWN_MIN so the
  # reset can take effect; if it's STILL over after the cooldown, then re-fire.
  HARD_CEIL_COOLDOWN_MIN="${HARD_CEIL_COOLDOWN_MIN:-20}"
  if [[ "$local_tokens_k" -ge "$local_hard_ceil_k" ]]; then
    cooldown_flag="/tmp/session-policy-hardceil-${session}"
    if [[ -f "$cooldown_flag" ]]; then
      flag_age_min=$(( ( $(date +%s) - $(stat -c %Y "$cooldown_flag") ) / 60 ))
      if [[ "$flag_age_min" -lt "$HARD_CEIL_COOLDOWN_MIN" ]]; then
        log "OK: $session (HARD CEILING ${local_tokens_k}k, in cooldown ${flag_age_min}m/${HARD_CEIL_COOLDOWN_MIN}m — reset still landing)"
        continue
      fi
    fi
    touch "$cooldown_flag"
    do_reset "$session" "HARD CEILING ${local_tokens_k}k >= ${local_hard_ceil_k}k (idle-independent)"
    continue
  fi
  # Below the ceiling → clear stale cooldown flag so a future spike fires immediately
  [[ "$local_tokens_k" -lt "$local_hard_ceil_k" ]] && rm -f "/tmp/session-policy-hardceil-${session}" 2>/dev/null || true

  case "$policy" in
    none)
      log "OK: $session (policy=none, skip)"
      ;;
    daily)
      if check_daily_reset "$session" "$daily_hour"; then
        do_reset "$session" "daily pre-backup reset (hour=$daily_hour)"
      else
        log "OK: $session (policy=daily, tokens=${local_tokens_k}k)"
      fi
      ;;
    idle)
      if [[ "$idle_min_actual" -ge "$idle_min" && "$local_tokens_k" -ge "$local_threshold_k" && "$local_threshold_k" -gt 0 ]]; then
        do_reset "$session" "idle ${idle_min_actual}m + context ${local_tokens_k}k >= ${local_threshold_k}k"
      else
        log "OK: $session (policy=idle, tokens=${local_tokens_k}k/${local_threshold_k}k, idle=${idle_min_actual}m)"
      fi
      ;;
    both)
      if check_daily_reset "$session" "$daily_hour"; then
        do_reset "$session" "daily pre-backup reset (hour=$daily_hour)"
      elif [[ "$idle_min_actual" -ge "$idle_min" && "$local_tokens_k" -ge "$local_threshold_k" && "$local_threshold_k" -gt 0 ]]; then
        do_reset "$session" "idle ${idle_min_actual}m + context ${local_tokens_k}k >= ${local_threshold_k}k"
      else
        log "OK: $session (policy=both, tokens=${local_tokens_k}k/${local_threshold_k}k, idle=${idle_min_actual}m)"
      fi
      ;;
  esac
done

log "=== Session Policy Done ==="
