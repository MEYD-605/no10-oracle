# Discord MCP re-test after restore (gmgrok)

## Failure mode

Hermes bootstrap can wipe `mcp_servers` in `~/.hermes-gmgrok/config.yaml` (e.g. defaulted to no8). Symptoms: Discord REST may still be 200 while MCP reply path is missing / wrong state-dir.

## Expected restore (No.1)

```yaml
mcp_servers:
  arra-oracle: ...
  discord-reply:
    command: /Users/admin/maw-workspace/tools/discord-reply-rust/target/release/discord-reply-mcp
    env:
      DISCORD_STATE_DIR: /Users/admin/.claude/channels/discord-gmgrok
```

- Bot: Gm grok `1518452865750794320`
- Prefer **MCP** `mcp_discord_reply_reply`; REST direct = fallback only

## One-shot re-test sequence

1. Verify REST `@me` 200 with discord-gmgrok token (do not print token).
2. Call MCP once → Bo DM `chat_id=1518456063224189090` short LIVE line + status footer.
3. Capture returned message `id`.
4. `maw hey maclab:01-lord-knight "[maclab:gmgrok] ACK re-test MCP reply OK · msg <id> · … · STANDBY · PONG only on state change"`
5. Seal `ψ/focus.md` + `ψ/activity.log` · hold silence until real delta.

## After No.1 `ACK STANDBY SEALED · silence hold`

- Append activity line only if useful.
- **No** further health PONGs unless state change.
