# Multi-Bot Git Workflow, Silent Standby, Node Onboarding & ARRA Vector Primary (2026-08-11)

## 1. Multi-Bot Git Workflow (Wind / Sonic T.2 Lesson)
- **SSOT Repository**: `AI-TEAMWORK/team-workflow` (or project repo).
- **Issue/PR Driven**: Every task, feature, or fix MUST track through GitHub Issues & Pull Requests. No un-tracked production code changes.
- **User ID Mention Rules**: Mention specific bots by their exact handle/ID when dispatching work.
- **Silent Standby**: When a message explicitly addresses another bot, all un-addressed bots must remain silent to prevent bot chatter loops.

## 2. New Node Onboarding without `pass` (natz-ai-03 Pattern)
When onboarding a new node (like `natz-ai-03`) that lacks `pass` / GPG password store:
1. **Do NOT rely on `maw discord serve`**.
2. **Create HERMES_HOME**: `mkdir -p ~/.hermes-<seat> && chmod 700 ~/.hermes-<seat>`.
3. **Set Token**: Put `DISCORD_BOT_TOKEN=...` in `~/.hermes-<seat>/.env` (`chmod 600`) or `config.yaml` (`gateway.platforms.discord.token`).
4. **Run Hermes Gateway**: `HERMES_HOME=~/.hermes-<seat> hermes gateway run`.

## 3. 2-Way Federation Handshake & `refuse-missing-peer-key`
- When `maw hey` between nodes returns `401: unauthorized (refuse-missing-peer-key)`:
  - Both nodes must have each other in `namedPeers` in `~/.config/maw/maw.config.json`.
  - Both nodes must have the remote host's pubkey registered in `~/.maw/peers.json`.
  - `maw-rs serve` on the receiver side must reload/verify keys.

## 4. ARRA Oracle v3 Cloudflare Vectorize Primary Configuration (`vector-server.json`)
- **Primary Vector Adapter**: Cloudflare Vectorize (`oracle_knowledge_bge_m3`, 1024d) is the primary semantic index for the fleet.
- **Configuration Pattern** (`~/.arra-oracle-v2/vector-server.json`):
  - Set `adapter` for `bge-m3` and all collections to `"cloudflare-vectorize"`.
  - Set `"primary": true` on `bge-m3`.
  - Remove `"vectorProxyUrl"` to eliminate proxy fallback loops.
- **Verification**:
  - `curl http://127.0.0.1:47778/api/health` -> `status: "ok"`, `vectorMode: "embedded"`.
  - `curl http://127.0.0.1:47778/api/stats` -> `vector.enabled: true`, `vector.count` > 0 (`oracle_knowledge_bge_m3`).
  - Run `bash ψ/tools/arra-cf-verify.sh` -> `== 4/4 GREEN ==`.
