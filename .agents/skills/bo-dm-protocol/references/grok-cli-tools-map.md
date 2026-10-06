# Grok CLI (Grok Build) tools map — maclab ~/.grok

Source: local `~/.grok/README.md` Built-in Tools + docs (e.g. grok 0.2.93). Use when Bo asks what **Grok CLI / `grok` binary** can do — **not** Hermes `x_search` (`references/xai-grok-tools.md`).

## Present to Bo (mandatory style)
Use **6 groups + icons + optional PNG diagram**. Proven pattern: write HTML cards → Chrome headless `--screenshot` → send via `MEDIA:/abs/path.png` or `HERMES_HOME=… hermes send --to discord:<id> "MEDIA:/abs/path.png"`, then short Thai prose. Never dump only raw tool IDs.

## Built-in groups
1. **Files/code** — `read_file`, `search_replace`, `grep_search`/`grep`, `list_dir`, write/Edit aliases, optional `lsp`
2. **Terminal** — `bash` / `run_terminal_command`, background + `get_task_output` / `kill_task`
3. **Web** — `web_search`; `web_fetch` often off by default (`GROK_WEB_FETCH=1`)
4. **Imagine** — `image_gen`, `image_edit`; video via `image_to_video` (image-first; slash `/imagine`, `/imagine-video`)
5. **Work/memory** — `todo_write`, `task`/subagents, `memory_search`/`memory_get` (experimental memory), `ask_user_question`
6. **MCP bridge** — `search_tool` + `use_tool`; machine may have arra-oracle, discord-reply, playwright, notion, codebase-memory-mcp

## Control
- Headless: `--tools` allowlist · `--disallowed-tools` · `--disable-web-search`
- Profile frontmatter: `tools` / `disallowedTools`
- Auth: browser SuperGrok / `XAI_API_KEY` / OIDC · tokens in `~/.grok/auth.json` (≠ Hermes auth)

## Pitfalls
- Conflating Hermes `x_search` with Grok CLI built-ins (CLI table has no first-class `x_search` name).
- Claiming every MCP on the machine is “Grok built-in”.
- Dense monospaced inventory after Bo asked for diagrams/icons.
