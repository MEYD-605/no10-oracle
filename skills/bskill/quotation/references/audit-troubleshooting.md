# Audit & Keepalive Troubleshooting Guide for No.4 MIMO

## Overview
This reference documents key operational patterns and fixes discovered during No.4 MIMO self-audits and keepalive maintenance.

## Relay Keepalive Patterns (`no4-relay-keepalive.sh`)
- **Binary Target**: Use TypeScript relay `~/.maw/discord-relay-ws.ts` run via `bun`, NOT non-existent Rust binary paths.
- **Bun Resolution**: Locate `bun` dynamically across `~/.bun/bin/bun`, `command -v bun`, and `/usr/local/bin/bun`.
- **pgrep Pattern**: Match `pgrep -f "discord-relay.*--agent 04-mimo"` to catch both TS and legacy binary signatures reliably.

## Quotation D1 Integration Gap
- `quote.sh` handles PDF generation and Cloudflare Pages deployment, but does not invoke `save_to_d1.py`.
- When generating quotations manually or via scripts, call `save_to_d1.py` as an explicit post-generation step.
- Ensure strings passed to `save_to_d1.py` escape single quotes (`'`) to avoid SQL syntax errors on Cloudflare D1.

## Audit Checklist for Subagents
1. **Relay status**: `pgrep -fl "discord-relay.*04-mimo"`
2. **Bash syntax**: `bash -n ψ/tools/*.sh`
3. **Python syntax**: `python3 -m py_compile ψ/tools/*.py`
4. **Handoff metadata**: Check `ψ/handoff.md` for empty key file paths (`- `).
5. **Outbox stale files**: Check `ψ/outbox/` for unresolved `*_pending.md` files older than 30 days.
