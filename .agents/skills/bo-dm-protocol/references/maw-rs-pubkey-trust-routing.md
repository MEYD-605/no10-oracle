# maw-rs Pubkey Trust & Cross-Node Routing Troubleshooting Guide

## Core Architecture & Wire Protocol
`maw-rs serve` enforces Ed25519 signature authentication (`x-maw-signature-v3` / `x-maw-timestamp`) for all inbound `/api/send` calls.

When sending messages cross-node (e.g. `maclab` ↔ `note20`):

### 1. HTTP 401 Unauthorized (Auth / Pubkey Mismatch)
**Root Cause**: The receiving `maw-rs serve` daemon does not match the sender's Ed25519 Public Key against its trusted key store or `peers.json`.

**Remediation Steps**:
1. Check local & remote `peer-key`:
   - `cat ~/.maw/peer-key`
2. Update local trust relationship:
   - If key changed / re-pinning: `maw trust remove <sender> <target> --yes`
   - Add new key: `maw trust add <sender> <target> --peer-key <pubkey>`
3. Synchronize `~/.maw/peers.json` on both sides:
   ```json
   {
     "peers": {
       "note20": {
         "url": "http://100.80.0.2:3456",
         "node": "local",
         "pubkey": "<64-char-hex-pubkey>",
         "pubkeyFirstSeen": "2026-07-27T23:15:00.000Z"
       }
     }
   }
   ```

---

### 2. HTTP 404 Not Found (Target Router / Session Missing)
**Root Cause**:
- Remote `maw-rs serve` cannot route the message to the requested target session (e.g., `10-gmgrub`).
- The remote target session / tmux pane is not active or hasn't been awakened via `maw wake`.
- `namedPeers` in `maw.config.json` on the remote node is improperly structured or missing.

**Remediation Steps**:
1. Ensure the target session is awake on the remote node:
   - `ssh <node> "maw wake <target-session> --no-attach"`
2. Verify `namedPeers` format in `maw.config.json` (must be array format):
   ```json
   {
     "namedPeers": [
       { "name": "maclab", "url": "http://100.83.0.1:3456" },
       { "name": "ai-core", "url": "http://100.81.0.110:3456" }
     ]
   }
   ```
3. Verify `maw-rs serve` process is running on port `3456`:
   - `maw-rs serve status`
