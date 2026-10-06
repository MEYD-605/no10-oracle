# maw federation — fleet coordination via maclab

Run on maclab through `ssh maclab` unless noted. The WSL node runs `maw-serve.service` behind Windows portproxy `0.0.0.0:3456` → current WSL IP (IP changes on every VM boot; the keepalive re-points it).

## Command map
- `maw ls -v` — live oracles + engine + age + title (the fleet dashboard).
- `maw hey <target> "msg"` — message an oracle; `--inbox` writes receiver inbox only.
- `maw peers map` — federation nodes up/down. `maw a <target>` — attach to a pane.

## Delivery pitfalls
- Cross-node form `node:session` used ON that node resolves back to a local pane and is REFUSED — when already on the target node, use the plain local target (`maw hey lord-knight-oracle "..."`).
- Target pane busy (agent mid-turn) → `hey` fails with "pending input after Enter retries"; the message instead sits in the target's input box until the agent submits. Always verify delivery with `tmux capture-pane -t <session>:0 -p | tail -30` before retrying — the captured screen also shows what that oracle is actually working on.

## Reading sibling oracle state
- Live screen: `tmux capture-pane -t <session>:<win> -p [-S -300]` over ssh.
- Claude CLI history: `~/.claude*/projects/<project-dir>/*.jsonl` on maclab (one dir per engine, e.g. `~/.claude-no5/`, `~/.claude-sombo/`). Parse per line with python: `type=user` → `message.content` is a plain string; `type=assistant` → it's a list of blocks with `type=="text"`. Sort files by mtime for the latest session.
- The tmux screen only shows the current step (often a spinner), and grepping scrollback misses most of it. To get the actual conversation, filter the jsonl like this:
  - **Bo's Discord asks:** `type=user` strings that contain `borde9902`. Strip the `<channel ...>` wrapper with a regex.
  - **The agent's Discord replies:** `tool_use` blocks whose `input` has both `chat_id` and `text`. The plain `text` blocks are mostly internal summaries.
  - Print only the last ~6 of these pairs, truncated to about 1500 chars each.
- Run the python as `ssh maclab 'python3 - "$f" <<"EOF" ... EOF'`, with the quoted heredoc inside the single-quoted remote command, so that neither shell expands `$`.

## `maw atlas` (Discord fleet plugin) — known broken as CLI
- `maw atlas <cmd>` exits 0 with no output (entry file lacks `import.meta.main`). Workarounds: (a) write a small bun script INSIDE `~/.maw/plugins/atlas/` importing `lib/discord` and run it with `bun run` from that dir — module resolution fails from /tmp; or (b) skip the plugin and call the Discord REST API directly with a bot token via curl (see SKILL.md Discord section).
- Discord API from maclab in python: default urllib user-agent → 403 Forbidden; the same token via curl → 200. Use curl or set a browser-like UA.
