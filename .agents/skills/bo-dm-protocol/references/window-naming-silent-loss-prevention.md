# Window Naming Discipline & Silent Message Loss Prevention (2026-08-13)

## The Problem
When a tmux window is named with a bare seat prefix (e.g., `gmgrok` instead of `gmgrok-oracle`), `maw hey` targeting logic resolves the target to that bare window (often an interactive `zsh` shell window).
When text formatted with `[node:seat]` transport brackets arrives in `zsh`, `zsh` attempts glob expansion on the brackets, throws `zsh: no matches found`, and swallows the text without delivering it to the agent process. This results in **silent message loss**.

## Prevention Rules
1. **Window Naming Standard**:
   - Window 0: `0 ops-shell` (zsh)
   - Window 1: `1 gmgrok-oracle` (python3 agent process / TUI)
   - Window 2+: `2 scratch-zsh` or explicit non-colliding names
2. **Prevent Automatic Renaming**:
   Ensure `tmux set-option automatic-rename off` is configured so zsh doesn't dynamically rename window 1 back to `gmgrok` or `zsh`.
3. **Fleet Verification**:
   Run `/Users/admin/.hermes-gmgrok/bin/check-window-names.sh` after any setup or window change to verify all 4 local seats (`00-gmgrok`, `01-lord-knight`, `04-mimo`, `05-gmforge`) have clean, non-colliding window names without bare seat prefixes.
