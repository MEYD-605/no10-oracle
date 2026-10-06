# Marketplace + Discord plugin seal (maclab 2026-07-12)

## Symptom classes
- Hang / high load after reboot (historical storm: marketplace discord `server.ts` orphans).
- Bo: “gtik/grok market ออกไปแล้วไม่ใช่เหรอ มันยังมี”.
- `load-guard` may say `server.ts=0` while count threshold is **>2** — one leftover still burns CPU.

## Two separate install paths
| Path | Location | Config |
|------|----------|--------|
| Grok CLI market | `~/.grok/config.toml` `[marketplace]` + `~/.grok/installed-plugins/` | `official_marketplace_auto_installed` · `[plugins] enabled/disabled` |
| Claude/Antigravity | `~/.claude/plugins/installed_plugins.json` + `cache/claude-plugins-official/discord/` | IDE language_server may spawn `bun …/discord/0.0.4 … start` |

Sealing Grok alone does **not** stop Claude path.

## Seal recipe (Grok)
1. `official_marketplace_auto_installed = false` (drift can flip **true** after config edits — re-verify).
2. `[plugins] enabled = []` · keep `"discord"` in `disabled = [...]`.
3. Empty or clear `~/.grok/installed-plugins/registry.json` repos.
4. Move active `discord-*` install dirs to `.DISABLED` / `.STASH-*` (both can coexist — stash the non-DISABLED active).
5. Optional: leave `[[marketplace.sources]]` git URL; auto_install false is the re-install gate.

## Seal recipe (Claude discord)
1. Remove key `discord@claude-plugins-official` from `installed_plugins.json` (backup first).
2. Rename cache dir → `discord.DISABLED-<date>`.
3. `pgrep -fl claude-plugins-official/discord` + `bun server.ts` — **kill** matches.
4. Orphans: child may reparent **ppid=1** after parent kill and keep cwd under DISABLED path — kill by cwd/cmdline, not name alone.

## Legit server.ts
- `arra-oracle-v3/src/server.ts` is **not** marketplace storm — do not kill as orphan.

## Buddy / house
- gmlab dual-care standing: `ψ/data/BUDDY-GMLAB-MACLAB-HOUSE-2026-07-12.md`
- Re-check market flag whenever someone rewrites `~/.grok/config.toml`.
