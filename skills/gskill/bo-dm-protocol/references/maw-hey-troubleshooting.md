# maw hey Target & Federation Troubleshooting

## Overview
When Bo or an operator asks why `maw hey <target>` fails (e.g., `maw hey team hermes` or `maw hey ai-core:01-lord-knight`), diagnose target syntax vs. router status systematically.

## Target Syntax Verification
`maw hey` requires a valid target form:
1. **Local Window Name**: `<oracle-window>` (e.g. `05-gmforge`, `88-sombo`)
2. **Explicit Local Agent**: `local:<agent>` (e.g. `local:gmgrok`)
3. **Cross-Node Target**: `<node>:<session>` or `<node>:<session>:<window>` (e.g. `ai-core:01-lord-knight`)

`team` or un-registered bare names are **not** valid targets. Use `maw locate <target>` to verify whether an agent is registered locally or in the federation.

## Cross-Node Router Probe
When sending cross-node (e.g., to `ai-core`):
1. Test node reachability and router API identity:
   `curl -s http://<node_ip>:3456/api/identity`
2. Check active registered agents on remote node:
   `curl -s http://<node_ip>:3456/api/agents`
3. Test router message dispatch (`/api/send`):
   - `404 not_found` / `peer-forward-unavailable`: Router daemon on remote host is down, un-registered, or missing the endpoint.
   - Note: Local `maw hey` between local sessions on the same node continues to work independently of cross-node router status.

## Two SEPARATE peer registries exist — `maw hey` CLI resolves against the OLDER one, not the newer `peers.json`

Verified 2026-08-01 on maclab: a peer (B3/white iMac) was correctly registered in
`~/.maw/peers.json` (the modern TOFU-paired store, managed via `maw peers add/list/info`)
under the clean alias `b3`, with `maw peers info b3` returning the right node/pubkey/URL.
But `maw hey b3:<session>:<window>` still failed with `error: node 'b3' not in namedPeers
or peers` / `hint: add to maw.config.json namedPeers`. The actual working alias for the
`maw hey` command was a DIFFERENT, legacy entry in `~/.config/maw/maw.config.json` →
`namedPeers[]`, which on this node had FOUR duplicate entries pointing at the same peer IP
(`b3`, `rdda`, `boom`, `pimpim` all → `100.70.182.22:3456`) — stale aliases accumulated
before TOFU pairing existed, never cleaned up. `maw hey pimpim:b3:0` worked;
`maw hey b3:b3:0` and `maw hey white:b3:0` (the peer's own self-announced node name) both
failed despite `b3` being correct in `peers.json`.

**Diagnostic sequence when `maw hey <alias>:...` fails with "not in namedPeers or peers":**
1. `maw peers info <alias>` — confirms whether the alias is valid in the NEW registry (doesn't mean `maw hey` can use it).
2. `cat ~/.config/maw/maw.config.json | python3 -c "import json,sys; print(json.dumps(json.load(sys.stdin)['namedPeers'], indent=2))"` — list every alias `maw hey` can actually route through, and check for duplicate URLs (multiple names pointing at the same peer = legacy cruft, pick the one that resolves and works, don't assume the "official" one from peers.json is wired into the CLI's target resolution).
3. If a peer's self-reported node name (from their `maw peers info` / handshake identity) doesn't match ANY working `namedPeers` alias, try each duplicate alias in `namedPeers` until one delivers — do not conclude the peer is unreachable from one alias failing.
4. Flag the mismatch to the peer/operator rather than silently standardizing on whichever alias happens to work — a `peers.json` alias and a `namedPeers` alias can drift apart (e.g. one system TOFU-repairs on IP change, the other doesn't), and future sessions need to know the true peer identity, not just "the string that worked".

## A THIRD config file can exist: `maw.config.50.json` — check `maw config sources` before trusting an edit landed

Verified 2026-08-01: after editing `namedPeers` in `~/.config/maw/maw.config.json` to fix
a peer's changed IP, `maw hey <alias>:...` STILL failed with a `network error` hitting the
OLD IP. `maw config sources` revealed the active source is actually
`~/.config/maw/maw.config.50.json` — a differently-numbered file that also has its own
`namedPeers[]` array, edited independently of the one without the suffix. Editing the
`.json` file without the number changes nothing if `maw` is actually reading the `.50.json`
variant. **Before troubleshooting a `namedPeers` edit that "didn't take", run `maw config
sources` first** — it prints which file(s) are actually active — rather than assuming the
un-suffixed `maw.config.json` is the only or authoritative one. Fix the file `maw config
sources` names, not the one that happens to match the base filename.

## Protocol for a peer's TEMPORARY re-homing (e.g. Tailscale outage workaround) — expect a revert, don't treat the new address as permanent

A peer (B3/white) hit a broken Tailscale network extension update on macOS and worked
around it by installing open-source `tailscaled` in userspace mode (no `sudo`, no network
extension dependency) — this gave them a genuinely new Tailscale IP and node name for as
long as the workaround was active. They explicitly flagged it as temporary: "when my
machine gets rebooted, the original Tailscale app comes back with the original IP, I'll
tell you to revert."

**What to do when a peer reports this kind of temporary re-homing:**
1. Verify the NEW address actually works before touching any config (`curl <new-ip>:3456/info`
   — confirm 200 + real identity payload) — don't trust the announcement alone.
2. Run the peer's requested `forget` / `remove` / `add` sequence on the modern `peers.json`
   TOFU store — but ALSO check every legacy `namedPeers` alias across ALL active config
   files (see "third config file" section above) that points at the peer's OLD IP. A peer
   can have 3-4 duplicate legacy aliases (`b3`, `rdda`, `boom`, `pimpim` in one observed
   case) all sharing one old IP from pre-TOFU days — fix only the ones that are genuinely
   THIS peer, see next point.
3. **Don't cascade the new IP to every alias that happens to share the old IP without
   verifying each is really the same peer first.** In the same incident, one of the
   duplicate-old-IP aliases (`boom`) was actually a DIFFERENT, unrelated real peer that
   just happened to have been mis-registered under the same old IP in the legacy file at
   some point in the past — the modern `peers.json` confirmed `boom`'s real distinct
   address. Blindly find/replacing the old IP across all `namedPeers` entries would have
   silently redirected messages meant for a different peer. Cross-check each alias against
   `peers.json` / the peer's own claimed identity before overwriting its URL, one at a time.
4. Confirm the peer's identity didn't change under the address change — `maw peers info
   <alias>` after the re-add should show the SAME `pubkey` as before the move. A matching
   pubkey after `forget`+re-`add` at a new URL is strong evidence this really is the same
   peer re-homing, not an impersonation opportunity.
5. When the peer later reports the revert (old address reachable again, new address dead —
   confirm both with a live curl before reverting, don't just trust the ping), reverse
   EVERY file touched in step 2, and re-run the `forget`/`remove`/`add` cycle back to the
   original address. Verify pubkey still matches across the whole round trip.

## Advanced `maw hey` & Federation Probe Pitfalls (2026-08-12)

1. **Bracket-Prefixed Message Rejection (CLI, `-f <file>`, stdin)**:
   - `maw hey` sender identity framing: `maw` automatically prepends `[node:seat]` on delivery.
   - **Pitfall**: Prefixing outgoing message text (via inline CLI string, `-f <file>`, or stdin) with `[maclab:gmgrok]` or any `[node:seat]` bracket syntax causes immediate rejection:
     `hey: bracket-prefixed hey text is reserved for signed transport prefixes`.
   - **Fix**: Write outgoing text or files starting with plain prose (e.g. `"ACK audit from gmgrok — ..."`). Let `maw` attach the header framing automatically.

2. **Timeout & Endpoint Failures on Long / Slashed Text**:
   - Messages containing multiple `/` slashes, heavy markdown, or length > 300 chars can cause `/api/send` HTTP POST to time out (30s+).
   - **Fix**: Keep text concise (< 300 chars), omit unnecessary URL slashes or raw path syntax, or split into short multi-line messages.

3. **Discrepancy Between `maw federation` and `maw peers probe`**:
   - `maw federation` listing a peer as `offline` while `maw peers probe <peer>` returns `✓ ok` and `authOk: true`:
     - **Root Cause**: `maw federation` summary probe sends an unsigned `POST /api/probe` request. If the target peer (e.g., `bigboy-vps`) enforces strict authentication, unsigned requests return `401 Unauthorized`, making the peer look `offline` in the summary table.
     - `maw peers probe` sends a signed request via `federation_probe_auth()`, succeeding with HTTP 200.
     - **Fix**: Do NOT change the probe path to `/api/status` or `/health` (especially on nodes like `maclab` where `/health` is 404). Fix `maw-rs` federation summary logic to use `federation_probe_auth()` instead.

4. **Timeout False Positives on `/health` Probes**:
   - `curl http://<peer>:3456/health` returning `000` (timeout) may be caused by slow response times (e.g., 6.4s response time exceeding a default 5s curl timeout), NOT a 404 missing route.
   - **Fix**: Always specify `-m <seconds>` (e.g., `-m 15`) when probing remote peer endpoints over Tailscale/networks.

5. **Self-Node Cross-Node Prefix Rejection (`addresses this node via its own cross-node name`)**:
   - **Pitfall**: Addressing a target on the SAME local node using the cross-node format `<this_node>:<seat>` (e.g. `maw hey maclab:01-lord-knight`). `maw-rs` detects self-addressing and refuses to deliver:
     `hey: refusing to deliver — 'maclab:01-lord-knight' addresses this node via its own cross-node name and resolved back to a local pane (01-lord-knight:0); use a plain local target instead`.
   - **Fix**: Strip the self-node prefix when messaging local peers: use plain local target syntax `maw hey 01-lord-knight "<text>"` or `local:01-lord-knight`.
