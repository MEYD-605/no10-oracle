# No.1 seat restore (maclab 01-lord-knight)

Bo: `เอากลับมาดิ` · peer silent after self-reboot · green Discord but no brain.

## Prove layers first
| Layer | Probe | Note |
|-------|--------|------|
| Discord | bot may show green | **not enough** |
| Relay | `pgrep -fl 'discord-relay --agent 01-lord-knight'` | often still LIVE while seat dead |
| Session | `tmux has-session -t 01-lord-knight` · `maw agents \| rg 01-lord` | missing = seat DEAD |
| Brain | pane capture · `pgrep -f lord-knight-oracle.*grok` | |
| Forward | latest `lord-knight-oracle/ψ/inbox/handoff/*` mtime | reboot without new forward is common |

## Canonical restore (keepalive)
```bash
# Clear stuck cooldown if respawn blocked (900s default)
rm -f ~/.maw/no1-keepalive.cooldown

# Fresh 500k bind (skip --continue) — Bo/No.1 ctx window work
touch ~/.maw/no1-fresh.pending   # or NO1_FRESH=1

# Kill half-dead session if any
tmux kill-session -t 01-lord-knight 2>/dev/null || true

# Create / heal
bash ~/.maw/no1-keepalive.sh
# launchd label: com.maclab.no1-keepalive → same script every 300s
```

`grok_cmd` inside keepalive (sealed pattern):
- `cd …/lord-knight-oracle`
- `FLEET_AGENT_NAME=01-lord-knight` · `MAW_SENDER=maclab:01-lord-knight`
- `GROK_DEBUG_CONTEXT_WINDOW=500000`
- `grok --model grok-4.5 --always-approve` (+ `--continue` unless fresh)

## Verify GREEN before telling Bo
1. `tmux ls | rg 01-lord-knight`
2. `maw agents | rg 01-lord-knight` → active
3. `ps eww` on pane shows `GROK_DEBUG_CONTEXT_WINDOW=500000` and model grok-4.5
4. Capture pane: ready prompt / not crash loop
5. `maw hey maclab:01-lord-knight "…"` delivers
6. **Remove** `~/.maw/no1-fresh.pending` after successful fresh boot so later restarts can `--continue`

## Bo DM tone
- Natural Thai · empathy if ท้อ · **facts not SEAL walls**
- State: seat was missing · restored · fresh/500k env · relay was not proof of brain
- Do not claim No.1 “forwarded this reboot” unless a handoff file exists after the announce timestamp

## Related
- `references/fleet-agent-brain-diagnose.md` — layer table
- Keepalive source: `~/.maw/no1-keepalive.sh`
