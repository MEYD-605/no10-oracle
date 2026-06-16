#!/bin/bash
# agy-watchdog.sh — Centralized Watchdog & Auto-Recovery for AGY Bots (No.6, No.8, No.10)
# Created by No.6 Gemini (Research + QA) in collaboration with No.10 X.

set -euo pipefail

LOG="/var/log/oracle/agy-watchdog.log"
STATUS_FILE="/var/log/oracle/agy-fleet-status.json"
mkdir -p "/var/log/oracle"

DAEMON_MODE=false
LOOP_INTERVAL=30 # seconds

for arg in "$@"; do
  if [ "$arg" = "--daemon" ]; then
    DAEMON_MODE=true
  fi
done

# Sessions and config definitions
declare -A NAMES=(
  ["06-gemini"]="No.6 Gemini"
  ["103-no10"]="No.10 X"
  ["08-agy-nano2"]="No.8 SuperNovice"
)

declare -A CMDS=(
  ["06-gemini"]="cd /root/Code/github.com/MEYD-605/gemini-oracle && HOME=/root/.no6-home agy --dangerously-skip-permissions --continue --add-dir /root/.gemini --add-dir /root/maw-workspace --add-dir /root/ψ"
  ["103-no10"]="cd /root/Code/github.com/MEYD-605/no10-oracle && HOME=/root/.no10-home agy --dangerously-skip-permissions --continue --add-dir /root/.no10-home/.gemini --add-dir /root/maw-workspace --add-dir /root/ψ"
  ["08-agy-nano2"]="cd /root/Code/github.com/MEYD-605/agy-nano2-oracle && HOME=/root/.no8-home agy --dangerously-skip-permissions --continue --add-dir /root/.no8-home/.gemini --add-dir /root/maw-workspace --add-dir /root/ψ"
)

declare -A TOKENS=(
  ["06-gemini"]="/root/.claude/channels/discord-no6/.env"
  ["103-no10"]="/root/.claude/channels/discord-no10/.env"
  ["08-agy-nano2"]="/root/.claude/channels/discord-no8/.env"
)

declare -A HOMES=(
  ["06-gemini"]="/root/.no6-home"
  ["103-no10"]="/root/.no10-home"
  ["08-agy-nano2"]="/root/.no8-home"
)

load_token() {
  local session="$1"
  local env_path="${TOKENS[$session]}"
  if [ -f "$env_path" ]; then
    grep "DISCORD_BOT_TOKEN=" "$env_path" | cut -d= -f2 | tr -d ' '
  fi
}

register_respawn() {
  local session="$1"
  local hist_file="/tmp/keepalive_${session}_respawn.history"
  local locked_file="/tmp/keepalive_${session}_locked"
  echo "$(date +%s)" >> "$hist_file"
  local now
  now=$(date +%s)
  local count=0
  if [ -f "$hist_file" ]; then
    local tmp_hist="/tmp/keepalive_${session}_respawn.tmp"
    while read -r ts; do
      if [ -n "$ts" ] && [ $((now - ts)) -le 300 ]; then
        echo "$ts" >> "$tmp_hist"
        count=$((count + 1))
      fi
    done < "$hist_file"
    mv "$tmp_hist" "$hist_file" 2>/dev/null
  fi
  
  if [ "$count" -ge 5 ]; then
    echo "$(date '+%F %T') session $session triggered loop spam protection ($count restarts in 5m) — LOCKING session!" >> "$LOG"
    touch "$locked_file"
    local bot_token
    bot_token=$(load_token "$session")
    if [ -n "$bot_token" ]; then
      curl -s -X POST -H "Authorization: Bot $bot_token" -H "Content-Type: application/json" \
        -d "{\"content\": \"🚨 **[Watchdog Alert]** Session \`$session\` has been **LOCKED** due to infinite restart loop spam protection ($count restarts in 5m). Awaiting manual check!\"}" \
        "https://discord.com/api/v10/channels/1492084191175774209" >/dev/null
      curl -s -X POST -H "Authorization: Bot $bot_token" -H "Content-Type: application/json" \
        -d "{\"content\": \"🚨 **[Watchdog Alert]** Session \`$session\` has been **LOCKED** due to infinite restart loop spam protection ($count restarts in 5m). Awaiting manual check!\"}" \
        "https://discord.com/api/v10/channels/1511429347863433438" >/dev/null
    fi
  fi
}

do_respawn() {
  local session="$1"
  local cmd="${CMDS[$session]}"
  echo "$(date '+%F %T') agy DEAD in $session — respawning" >> "$LOG"
  rm -f "/tmp/keepalive_${session}_loading.time"
  rm -f "/tmp/keepalive_${session}_cpu.time"
  register_respawn "$session"
  tmux send-keys -t "$session" "$cmd" Enter
}

run_scan() {
  local ENTRIES=""
  local NOW_TS
  NOW_TS=$(date '+%Y-%m-%dT%H:%M:%S+07:00')

  echo "=== AGY Watchdog Scan: $(date) ===" >> "$LOG"

  for session in "06-gemini" "103-no10" "08-agy-nano2"; do
    local name="${NAMES[$session]}"
    local status="DEAD"
    local cpu=0
    local mem=0
    local locked="false"
    local pid=""
    local pane_pid=""
    local pane_content=""

    # Check lock file
    if [ -f "/tmp/keepalive_${session}_locked" ]; then
      locked="true"
      echo "$(date '+%F %T') session $session is locked — skipping" >> "$LOG"
    fi

    # Skip if session is locked
    if [ "$locked" = "true" ]; then
      local ENTRY="\"${session}\": {\"name\": \"${name}\", \"status\": \"LOCKED\", \"pid\": null, \"cpu_pct\": 0, \"memory_mb\": 0, \"locked\": true}"
      if [ -z "$ENTRIES" ]; then ENTRIES="$ENTRY"; else ENTRIES="${ENTRIES}, ${ENTRY}"; fi
      continue
    fi

    # Check tmux session existence
    if ! tmux has-session -t "$session" 2>/dev/null; then
      echo "$(date '+%F %T') session $session absent — skipping recovery (maw owns creation)" >> "$LOG"
      local ENTRY="\"${session}\": {\"name\": \"${name}\", \"status\": \"ABSENT\", \"pid\": null, \"cpu_pct\": 0, \"memory_mb\": 0, \"locked\": false}"
      if [ -z "$ENTRIES" ]; then ENTRIES="$ENTRY"; else ENTRIES="${ENTRIES}, ${ENTRY}"; fi
      continue
    fi

    pane_pid=$(tmux list-panes -t "$session" -F '#{pane_pid}' 2>/dev/null | head -1 || echo "")
    if [ -z "$pane_pid" ]; then
      echo "$(date '+%F %T') no pane pid for $session — skipping" >> "$LOG"
      local ENTRY="\"${session}\": {\"name\": \"${name}\", \"status\": \"ERROR\", \"pid\": null, \"cpu_pct\": 0, \"memory_mb\": 0, \"locked\": false}"
      if [ -z "$ENTRIES" ]; then ENTRIES="$ENTRY"; else ENTRIES="${ENTRIES}, ${ENTRY}"; fi
      continue
    fi

    # 1. Process Check
    if ! pstree -p "$pane_pid" 2>/dev/null | grep -q "agy"; then
      do_respawn "$session"
      local ENTRY="\"${session}\": {\"name\": \"${name}\", \"status\": \"RESTARTED\", \"pid\": null, \"cpu_pct\": 0, \"memory_mb\": 0, \"locked\": false}"
      if [ -z "$ENTRIES" ]; then ENTRIES="$ENTRY"; else ENTRIES="${ENTRIES}, ${ENTRY}"; fi
      continue
    fi

    pid=$(pgrep -P "$pane_pid" -f agy | head -1 || echo "")
    if [ -z "$pid" ]; then
      do_respawn "$session"
      local ENTRY="\"${session}\": {\"name\": \"${name}\", \"status\": \"RESTARTED\", \"pid\": null, \"cpu_pct\": 0, \"memory_mb\": 0, \"locked\": false}"
      if [ -z "$ENTRIES" ]; then ENTRIES="$ENTRY"; else ENTRIES="${ENTRIES}, ${ENTRY}"; fi
      continue
    fi

    status="ALIVE"
    cpu=$(ps -p "$pid" -o %cpu= 2>/dev/null | cut -d. -f1 | tr -d ' ' || echo 0)
    local rss
    rss=$(ps -p "$pid" -o rss= 2>/dev/null | tr -d ' ' || echo 0)
    mem=$((rss / 1024))

    pane_content="$(tmux capture-pane -t "$session" -p 2>/dev/null || echo "")"

    # 2. Stuck at prompt ("What should Antigravity CLI do instead?")
    # GRACE PERIOD (2026-06-10): only kill if the prompt PERSISTS >90s across
    # checks — killing on first sight nuked No.6 mid-work (15:04). A transient
    # prompt (agy between tasks / asking) must NOT trigger an instant kill.
    if echo "$pane_content" | grep -q "What should Antigravity CLI do instead?"; then
      local pf="/tmp/keepalive_${session}_prompt.time"
      local pnow; pnow=$(date +%s)
      if [ ! -f "$pf" ]; then
        echo "$pnow" > "$pf"
      else
        local pstart; pstart=$(cat "$pf"); local pdiff=$((pnow - pstart))
        if [ "$pdiff" -gt 90 ]; then
          echo "$(date '+%F %T') agy STUCK at prompt in $session for ${pdiff}s — killing to force clean respawn" >> "$LOG"
          pkill -9 -P "$pane_pid" -f agy 2>/dev/null
          rm -f "$pf"
          sleep 1
          do_respawn "$session"
          status="RESTARTED"
        fi
      fi

    # 3. Stuck in Loading... deadlock (Threshold 120s)
    elif echo "$pane_content" | grep -q "Loading..."; then
      local time_file="/tmp/keepalive_${session}_loading.time"
      local now
      now=$(date +%s)
      if [ ! -f "$time_file" ]; then
        echo "$now" > "$time_file"
      else
        local start_time
        start_time=$(cat "$time_file")
        local diff=$((now - start_time))
        if [ "$diff" -gt 120 ]; then
          echo "$(date '+%F %T') agy DEADLOCKED on Loading... in $session for ${diff}s — killing" >> "$LOG"
          pkill -9 -P "$pane_pid" -f agy 2>/dev/null
          rm -f "$time_file"
          sleep 1
          do_respawn "$session"
          status="RESTARTED"
        fi
      fi
    else
      rm -f "/tmp/keepalive_${session}_loading.time"
      rm -f "/tmp/keepalive_${session}_prompt.time"
    fi

    # 4. CPU Hung Check (Threshold 90s at >95% CPU - Softened: Log warning only)
    if [ "$status" = "ALIVE" ] && [ -n "$cpu" ] && [ "$cpu" -gt 95 ]; then
      local cpu_time_file="/tmp/keepalive_${session}_cpu.time"
      local now
      now=$(date +%s)
      if [ ! -f "$cpu_time_file" ]; then
        echo "$now" > "$cpu_time_file"
      else
        local start_time
        start_time=$(cat "$cpu_time_file")
        local diff=$((now - start_time))
        if [ "$diff" -gt 180 ]; then
          echo "$(date '+%F %T') [WARNING] agy CPU high usage at ${cpu}% in $session for ${diff}s (not killing)" >> "$LOG"
          # pkill -9 -P "$pane_pid" -f agy 2>/dev/null
          # rm -f "$cpu_time_file"
          # sleep 1
          # do_respawn "$session"
          # status="RESTARTED"
        fi
      fi
    else
      rm -f "/tmp/keepalive_${session}_cpu.time"
    fi


    # 5. MCP Discord Liveness Check
    if [ "$status" = "ALIVE" ] && [ -n "$pid" ] && [ "$session" != "06-gemini" ]; then
      if ! pgrep -P "$pid" -f "claude-plugins-official/discord" >/dev/null; then
        echo "$(date '+%F %T') [WARNING] Discord MCP process missing under agy PID $pid in $session — restarting to restore gateway" >> "$LOG"
        pkill -9 -P "$pane_pid" -f agy 2>/dev/null
        sleep 1
        do_respawn "$session"
        status="RESTARTED"
      fi
    fi

    # 6. Memory Leak Check (>1.5GB)
    if [ "$status" = "ALIVE" ] && [ -n "$rss" ] && [ "$rss" -gt 1500000 ]; then
      echo "$(date '+%F %T') agy MEMORY LEAK detected (${mem} MB) in $session — restarting" >> "$LOG"
      pkill -9 -P "$pane_pid" -f agy 2>/dev/null
      sleep 1
      do_respawn "$session"
      status="RESTARTED"
    fi

    # 7. Silent Hang Check (Log idle time > 300s and no waiting prompt in pane)
    # FIXED 2026-06-15 (No.3, No.1 dispatch — false-hang storm: 1211 bogus nudges):
    #   Bug (a): the prompt gate matched only the claude `❯`. agy's idle prompt is `>`
    #     (bare `>` or `> [..]`), so a healthy agy idle-waiting for input was misread as
    #     hung and Enter-nudged every cycle. Now the gate also matches agy's `>` prompt.
    #   Bug (b): the KILL decision trusted cli.log mtime alone, but cli.log only bumps
    #     while agy does I/O — a quietly-working agy (no prompt drawn) could be false-killed.
    #     Now liveness is cross-checked against tmux PANE ACTIVITY (content hash): a pane
    #     that CHANGES between checks is alive and is never nudged/killed, regardless of log.
    #   KNOWN LIMITATIONS (No.99 lane-B review 2026-06-15 — low-risk, accepted post-storm):
    #     note 1: a `>`-prefixed line in agy OUTPUT (e.g. a markdown quote) scrolled into
    #             the last lines can match the idle-prompt gate → a genuinely-hung agy may
    #             be read as healthy (false-negative). Direction is SAFE (suppresses a kill,
    #             never causes one); a human notices a stuck agy faster than a wrong kill.
    #     note 2: a flickering/intermittent hang (pane changes just enough each cycle) keeps
    #             resetting the hash → never auto-killed. Also SAFE-direction; surfaced by
    #             eyeballing, not auto-recovered. Both deemed acceptable vs the nudge storm.
    if [ "$status" = "ALIVE" ]; then
      local log_file="${HOMES[$session]}/.gemini/antigravity-cli/cli.log"
      if [ -f "$log_file" ]; then
        local mtime
        mtime=$(stat -L -c %Y "$log_file" 2>/dev/null || echo 0)
        if [ "$mtime" -gt 0 ]; then
          local now
          now=$(date +%s)
          local idle_sec=$((now - mtime))
          if [ "$idle_sec" -gt 300 ]; then
            local last_lines
            # Strip blank lines first: agy's TUI pads the bottom with blanks, pushing the
            # `>` prompt above a raw `tail`. Inspect the last non-blank content instead.
            last_lines=$(echo "$pane_content" | grep -vE '^[[:space:]]*$' | tail -n 15)
            # Healthy waiting/idle prompt? agy uses `>` (bare or `> [..]`); claude used `❯`.
            if echo "$last_lines" | grep -qE "(What should Antigravity CLI do instead\?|Do you want to run this command\?|What would you like me to do\?|❯)" \
               || echo "$last_lines" | grep -qE "^[[:space:]]*>([[:space:]]|$)"; then
              rm -f "/tmp/keepalive_${session}_unblock.time" "/tmp/keepalive_${session}_panehash"
            else
              # No prompt visible — could be a real hang OR a quietly-working agy.
              # Cross-check pane ACTIVITY: only act while the pane is also FROZEN.
              local unblock_file="/tmp/keepalive_${session}_unblock.time"
              local hash_file="/tmp/keepalive_${session}_panehash"
              local cur_hash
              cur_hash=$(printf '%s' "$pane_content" | md5sum | cut -d' ' -f1)
              if [ ! -f "$unblock_file" ]; then
                echo "$(date '+%F %T') agy silent hang suspected (log idle ${idle_sec}s, no prompt) in $session — sending Enter key to unblock" >> "$LOG"
                echo "$now" > "$unblock_file"
                echo "$cur_hash" > "$hash_file"
                tmux send-keys -t "$session" Enter
              else
                local prev_hash
                prev_hash=$(cat "$hash_file" 2>/dev/null || echo "")
                if [ "$cur_hash" != "$prev_hash" ]; then
                  # pane moved since the nudge → agy is alive/working → stand down, no kill
                  echo "$(date '+%F %T') agy pane ACTIVE after nudge in $session (log idle ${idle_sec}s) — not a hang, resetting" >> "$LOG"
                  rm -f "$unblock_file" "$hash_file"
                else
                  local unblock_start
                  unblock_start=$(cat "$unblock_file")
                  local unblock_diff=$((now - unblock_start))
                  if [ "$unblock_diff" -gt 300 ]; then
                    echo "$(date '+%F %T') agy silent hang persistent (log idle ${idle_sec}s, pane FROZEN, unblock ${unblock_diff}s) in $session — killing" >> "$LOG"
                    pkill -9 -P "$pane_pid" -f agy 2>/dev/null
                    rm -f "$unblock_file" "$hash_file"
                    sleep 1
                    do_respawn "$session"
                    status="RESTARTED"
                  fi
                fi
              fi
            fi
          else
            rm -f "/tmp/keepalive_${session}_unblock.time" "/tmp/keepalive_${session}_panehash"
          fi
        fi
      fi
    fi

    local ENTRY="\"${session}\": {\"name\": \"${name}\", \"status\": \"${status}\", \"pid\": ${pid:-null}, \"cpu_pct\": ${cpu:-0}, \"memory_mb\": ${mem:-0}, \"locked\": ${locked}}"
    if [ -z "$ENTRIES" ]; then ENTRIES="$ENTRY"; else ENTRIES="${ENTRIES}, ${ENTRY}"; fi
  done

  # Write JSON output
  cat > "$STATUS_FILE" <<EOF
{
  "updated_at": "${NOW_TS}",
  "sessions": {
    ${ENTRIES}
  }
}
EOF
}

if [ "$DAEMON_MODE" = "true" ]; then
  echo "Starting AGY Fleet Watchdog in Daemon Mode (interval: ${LOOP_INTERVAL}s)..."
  while true; do
    run_scan || echo "Scan failed at $(date)" >> "$LOG"
    sleep "$LOOP_INTERVAL"
  done
else
  run_scan
fi
