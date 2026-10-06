# Discord DM ↔ tmux/maw-hey pane: separate processes, separate sessions (2026-08-01)

## Trigger
Bo asks something like "กูdmหาพวกมึงมันขึ้นอยู่ที่เดียวกันกับเกตเวย์ดีไหม" (shouldn't
my DM show up in the same place as the gateway/pane?), or expresses confusion that an
agent doesn't seem to know what he said in a Discord DM when he's looking at the
tmux/Oracle-Board pane (or vice versa). This is a real architectural gap, not a
misunderstanding on Bo's part — confirm it, don't argue it away.

## What's actually happening (verified 2026-08-01 on gmgrok/maclab)

A seat has (at least) two live OS processes sharing one `HERMES_HOME` but NOT sharing
a session:

1. **Discord DM gateway** — `python -m hermes_cli.main gateway run --replace`,
   launchd-supervised (`ai.hermes.gateway-<seat>.plist`). This is what Bo's Discord DMs
   hit.
2. **Interactive tmux pane** (`maw hey`, Oracle Board) — a *different* process,
   `hermes chat --yolo`, started inside a tmux session (e.g. `00-gmgrok`), used for
   agent-to-agent `maw hey`/`maw run` traffic and any human watching the Oracle Board.

Verify which is which on any seat:
```bash
ps aux | grep 'hermes_cli.main gateway run' | grep -v grep   # DM gateway process
tmux list-panes -t <seat-tmux-session> -F "#{pane_pid} #{pane_start_command}"
ps -p <pane_pid> -o pid,ppid,command                          # the chat --yolo process
```
Both processes read the same `HERMES_HOME` (config.yaml, skills, memory), but each
runs its OWN session/conversation — a DM to the seat and a `maw hey` message to the
same seat do NOT appear in the same transcript, and neither process's agent loop sees
the other's traffic. This is a real gap inherited from the Claude Code → Hermes
migration: the old Claude relay merged both channels into one Discord channel; Hermes
never rebuilt that bridge (this fact is already in long-term memory — this reference
is the "what to do about it" companion).

## Answering Bo when he raises this

1. **Confirm the gap with live process evidence** (the two-liner above) rather than
   describing it abstractly — Bo responds better to "ยืนยันแล้วครับ นี่คือ process จริง"
   with real PIDs than to a theoretical explanation.
2. **Don't claim you already fixed it or that it's trivial** — merging two independent
   OS-level chat sessions safely (without double-processing an incoming message) is
   real engineering work, not a config flag.
3. **Offer graded options, cheapest/safest first** — don't jump straight to "let's
   merge the sessions":
   - **(A) Mirror only** (low risk): a Hermes **Gateway Hook** on `agent:end` (see
     Hermes docs `user-guide/features/hooks.md` — Gateway Event Hooks, events table
     includes `agent:end` with `platform`/`user_id`/`session_id`/`response` context)
     that echoes DM traffic into the seat's own tmux pane (e.g. via `maw run <seat>
     "..."` or a direct `tmux send-keys`). Peers see what Bo said in DM; Bo's DM
     conversation is not touched. Reversible, no risk to the live gateway.
   - **(B) True session merge** (high risk, NOT default): routing DM input and
     tmux/maw-hey input into one shared agent session. Real risk of double-processing
     (a DM arrives → could trigger both the gateway's own turn AND get replayed into
     the pane, producing two responses or state corruption). This needs a deliberate
     routing-layer design, ideally coordinated with No.1/fleet before touching any
     live seat's gateway.
4. **This affects every seat, not just the one being asked** — no1, no4, no5, gmgrok
   all have the same gateway/pane split (same launchd pattern). If Bo wants (A) or (B)
   built, treat it as a fleet-wide rollout question (coordinate via `maw hey` /
   No.1), not a one-seat fix.

## Do NOT

- Don't assert the DM and pane already share context — verify process split first
  (they don't, on the standard launchd multi-seat pattern).
- Don't silently attempt a session merge (option B) on a live seat's gateway without
  explicit Bo/No.1 sign-off — a bad routing change here can break Bo's primary DM
  channel to that seat.
- Don't conflate this with the already-known "maw hey and Discord DM gateway are
  separate channels, no mirror" fact (already in long-term memory) — that fact states
  the problem; this reference is the actionable fix-options doc for when Bo asks about
  it directly.
