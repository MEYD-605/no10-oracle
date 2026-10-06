# maw-rs Sender Identity Fallback Chain & `pane/unknown` Diagnosis

## 1. Sender Identity Fallback Chain (`crates/maw-cli/src/core_impl/sender_identity.rs`)

When `maw hey` constructs the sender tag for outgoing messages, it evaluates a 4-tier fallback chain:

```rust
tmux_pane
    .filter(|pane| !pane.trim().is_empty())
    .and_then(|pane| tmux_window_name_with(runner, Some(pane))) // 1. Active $TMUX_PANE window name
    .or_else(|| resolve_hey_canonical_sender_oracle(config))   // 2. Configured canonical oracle
    .unwrap_or_else(|| {
        if in_tmux {
            let focused = tmux_window_name_with(runner, None);
            return format!("pane/{}", resolve_sender_oracle(None, focused.as_deref(), None)); // 3. Focused window
        }
        send_headless_sender_marker()                          // 4. Headless marker
    })
```

`send_headless_sender_marker()` checks if the process cwd is inside a git repo:
- Git repo found -> `job/<repo-stem>`
- No git repo / bare headless -> `pane/unknown`

## 2. Issue #519 Design Rationale

Emitting `pane/unknown` when running headless (no `$TMUX_PANE` or `$TMUX`) is intentional:
> *"Headless (no TMUX/TMUX_PANE): the focused-window query would name whatever window the attached client happens to show — another oracle's identity (#519). Emit a truthful marker instead."*

## 3. Investigating `pane/unknown` Reports

When a peer or user reports seeing `[maclab:pane/unknown]` tags:

1. **Check Live Process Environment**:
   Verify if `maw hey` is being executed from:
   - A live tmux pane with `$TMUX_PANE` set (e.g. `%13` -> window `gmgrok`).
   - A cron job, LaunchAgent, or background script lacking tmux environment variables.

2. **Query the Message Ledger (`~/.maw/message-ledger.sqlite`)**:
   ```bash
   sqlite3 ~/.maw/message-ledger.sqlite "select count(*), min(ts), max(ts) from messages where from_id like '%unknown%';"
   ```
   Determine whether `pane/unknown` entries are **active/current** or **historical transcripts**. Past session respawns or window renames resolve `pane/unknown` for new messages, but historical transcript renders will still display the old `pane/unknown` tag.
