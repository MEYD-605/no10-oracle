---
version: "1.1.0"
name: office-suite-notes
aliases: ["办公套件原子笔记", "办公套件便签"]
description: "(alias=办公套件原子笔记, 办公套件便签) Manage Notes via CLI — list, view, create, update, search notes and folders"
---

# Notes CLI

Use the `notes` CLI to manage the user's notes. It communicates with the Office Suite (Chinese alias: 办公套件) HTTP service via `127.0.0.1` (port 9200–9700, configured via `notes config`).

## Script location & platform selection

The CLI scripts live next to this `SKILL.md` in the skill directory. They are **not on `PATH`** — invoke by path:

| Platform | Script | Invocation |
|---|---|---|
| macOS / Linux | `notes` (bash) | `${SKILL_DIR}/notes <cmd>` (chmod +x first) |
| Windows | `notes.ps1` (PowerShell 5.1+) | `powershell -NoProfile -ExecutionPolicy Bypass -File ${SKILL_DIR}\notes.ps1 <cmd>` |

`${SKILL_DIR}` = absolute path to this skill's directory (replace it, or `export SKILL_DIR=...`). The two scripts are feature-equivalent. Below, `notes` refers to whichever one applies to your platform.

> **Note**: When installing or upgrading this skill, copy the **entire skill directory** (`SKILL.md` + `notes` / `notes.ps1` scripts) — not just `SKILL.md` — since the CLI scripts are required for all commands.

## Use Cases

- User asks to view, create, update, search, or list notes
- User asks about note folder operations (list, create, rename, move)
- User wants to search within notes

## Prerequisites

Before performing any operation, verify the connection:

```bash
notes health
```

If it returns "Connection refused" or the connection fails, prompt the user to check whether Office Suite is running.

## Command Reference

| Command | Description |
|---------|-------------|
| `notes health` | Check service connection status |
| `notes version` | View App and API version |
| `notes list [--folder=<id>] [--limit=20] [--page=1] [--json]` | List notes (summary only, no body) |
| `notes read <id> [--json]` | View full note details (including body) |
| `notes create --title="..." (--content="..." \| --content-b64="...") [--folder=<id>] [--json]` | Create a new note (content is required — omitting `--content` / `--content-b64` creates an empty note) |
| `notes update <id> [--title="..."] [--content="..."] [--content-b64="..."] [--folder=<id>] [--json]` | Update a note (content is appended) |
| `notes search --query="..." [--limit=10] [--folder=<id>] [--json]` | Search notes by title/content |
| `notes folders [--parent=<id>] [--json]` | List all folders |
| `notes folder <id> [--json]` | View folder details |
| `notes folder:create --name="..." [--parent=<id>] [--json]` | Create a folder |
| `notes folder:update <id> [--name="..."] [--parent=<id>] [--json]` | Rename or move a folder |
| `notes folder:notes <id> [--limit=20] [--page=1] [--json]` | List notes in a folder |
| `notes config [--token=<token>] [--port=<port>]` | View or modify configuration |
| `notes cli:check` | Check for CLI/Skill updates (requires no Token) |

## Examples

```bash
# List all notes
notes list

# Search for notes containing "meeting"
notes search --query="meeting"

# Create a note — pass content via --content (simple text) or --content-b64 (anything else)
notes create --title="Shopping List" --content="<p>Milk, eggs, bread</p>" --folder=work

# Create a note with base64 (for content with special characters)
b64=$(base64 -i /path/to/file.md)
notes create --title="From File" --content-b64="$b64" --folder=work

# View a specific note
notes read n810e769e

# Append content to a note
notes update n810e769e --content="<p>And some butter</p>"

# List all folders
notes folders

# Create a folder
notes folder:create --name="Projects" --parent=work

# List notes in a folder
notes folder:notes work --limit=5
```

### Content with special characters (BASE64)

When the note body contains characters that are awkward to pass on the command line — quotes, backslashes, newlines, emoji, or non-ASCII text — pass it as **base64** via `--content-b64` instead of `--content`. Base64 only uses `[A-Za-z0-9+/=]`, which is completely shell-safe, so the content can never break argument parsing or get mangled by the shell.

- `--content-b64="<base64>"` is supported by both `create` and `update`. It takes precedence over `--content` when both are given.
- The CLI decodes the base64 string back to a **UTF-8 plaintext** string and sends it as the normal `content` field — the server receives exactly the same body it would for `--content`. Nothing on the server side changes.
- The caller is responsible for base64-encoding the **UTF-8 bytes** of the content before invoking the CLI.

Example — encoding a file and creating the note:

Windows (PowerShell):
```powershell
$b64 = [System.Convert]::ToBase64String(
    [System.Text.Encoding]::UTF8.GetBytes(
        [System.IO.File]::ReadAllText("C:\path\to\README.md", [System.Text.Encoding]::UTF8)))
& notes.ps1 create --title="README" --content-b64=$b64
```

macOS / Linux (bash):
```bash
B64=$(base64 -i /path/to/README.md)
notes create --title="README" --content-b64="$B64"
```

> Note: very large notes may still hit the OS command-line length limit when base64 is passed inline. For big files, prefer reading the file directly inside your upload script (UTF-8 `ReadAllText` on Windows, `base64 -i` on macOS/Linux) rather than stuffing a huge base64 string into the command line.

## Output Format

- Default: human-readable text format
- `--json`: raw server JSON (`{"status":"success","data":[...],"meta":{...}}`)

Always use `--json` when you need to parse results programmatically.

## Important Notes

- The service listens only on the local loopback address — no external network access
- All commands except `health`, `cli:check`, and `config` require a Token
- If you get a 401 Unauthorized, the Token is invalid or expired — prompt the user to run `notes config --token=<new-token>` to reconfigure
- Note body supports HTML/MARKDOWN format (use tags like `<p>`, `<br>`, `<b>`, etc.)
- `update` appends content to the end of the note; the `folder` parameter moves the note to a target folder
- Search ranking: title prefix match > title contains > content contains
- Deleted notes (in trash) will not appear in any results
- URL encoding is handled automatically by the CLI — no need to manually encode parameters
- macOS/Linux uses `notes` (bash), Windows uses `notes.ps1` (PowerShell) — see "Script location & platform selection" above
- **Folder references are always by `id`, never by name.** `--folder=<id>`, `--parent=<id>`, and the `<id>` argument to `folder` / `folder:notes` / `folder:update` all expect the folder's id (a hex string like `90ec6218f4594ab79c4e1f15cb6d3d27`), not its display name. To find a folder's id, run `notes folders --json` (root) or `notes folders --parent=<id> --json` (subfolders) and read `id` from the output. There is no by-name lookup.
- For note bodies that contain quotes, backslashes, newlines, or non-ASCII characters, pass `--content-b64="<base64>"` instead of `--content` to avoid all shell-escaping problems. The CLI decodes it to UTF-8 plaintext before sending. See "Content with special characters (BASE64)" above.
