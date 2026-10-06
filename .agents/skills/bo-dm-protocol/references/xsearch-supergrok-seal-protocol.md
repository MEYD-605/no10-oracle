# x_search & SuperGrok 4-Seat SEAL Protocol

## Pattern (2026-08-13)

When SuperGrok OAuth device code flow is completed on maclab (`xai-oauth` credential pool with label `SuperGrok`):

1. **Credential Pool Structure**:
   - Stored under `auth.json` -> `credential_pool.xai-oauth`.
   - Entry format: `{ "label": "SuperGrok", "auth_type": "oauth", "source": "manual:device_code", "access_token": "...", "refresh_token": "...", "expires_at": "..." }`.
   - Scope MUST include `api:access`.
   - Dead `providers.xai-oauth` entries (e.g. Jul 26 corpse) or dead `XAI_API_KEY` (which returns HTTP 403 on `/v1/chat/completions`) DO NOT block `xai-oauth` device_code execution path.

2. **Verification & Proof (Stop-Think-Verify)**:
   - Run `hermes doctor` -> check `xAI OAuth (logged in)` and `x_search` capability.
   - Inspect `auth.json` `credential_pool.xai-oauth` to confirm `access_token` presence and extract `exp` timestamp from JWT payload without printing secrets.
   - Verify local gateway PID is running and not restarting/bouncing.

3. **Cross-Seat Propagation & SEAL Handling**:
   - When auth/toolset is copied to peer seats (`.hermes-no1`, `.hermes-no4`, `.hermes-no5`), peer gateways pick up active pool tokens dynamically on new sessions.
   - DO NOT bounce running peer gateways (e.g. No.1 gateway pid 83030).
   - Once No.1 or any peer seat proves `x_search` citations on X, issue SEAL protocol.
   - Recipients of SEAL ACK:
     a) Verify local state (doctor + auth pool exp + gw pid).
     b) Write local verification leaf to `ψ/data/YYYY-MM-DD_HHMM_verify-seal-xsearch-supergrok.md`.
     c) Send 1-line ACK to No.1 via `maw hey 01-lord-knight`.
     d) Send natural Thai status update to Bo DM via `HERMES_HOME=~/.hermes-gmgrok hermes send --to discord:<chat_id>`.
     e) Update `ψ/focus.md` with SEAL status.
     f) DO NOT re-fire `x_search` test queries (avoids unnecessary token consumption).
