# Black Machine (black.alchemycat.org) Architecture & Access

> Host: `black.alchemycat.org` (`10.10.0.6`) · Owner: P'Nat (nazt_)

## Access & SSH
- Direct SSH: `ssh meyd@black.alchemycat.org` (works out-of-the-box via SSH config/key).
- Primary user on node: `meyd`

## Architecture Pattern (P'Nat Model)
1. **User-per-Agent Isolation**:
   - Each agent/oracle runs under its own Linux OS user: `nat`, `black`, `golf`, `maw-rs`, `meyd`, `noah-oracle`, `dustboy`, `1dfx`, `ampere`, etc.
   - User homes (`/home/<agent>/`) isolate agent configs, sessions, and permissions.

2. **maw-rs Execution & Attachment Bus**:
   - `maw-rs` binary (`/home/<user>/.local/bin/maw`) manages multi-agent commands:
     - `maw serve` — background daemon for cross-user coordination.
     - `maw a|attach <target>` — attach to agent's tmux session.
     - `maw wake <target>` / `maw work <repo>` / `maw hey <target> <msg>`.

3. **Tmux Engine Anchor**:
   - Agents run in dedicated named tmux sessions (e.g. `33-maw-rs`, `71-black`).

4. **Multi-Provider Proxy**:
   - `9router` runs under `meyd` at `http://127.0.0.1:20128` (`node 9router -n -l -p 20128`).
