# Black Machine Architecture & Access (2026-07-26)

- Host: `black.alchemycat.org` (`meyd@black.alchemycat.org`)
- Access: Direct SSH key pre-configured for `meyd` user (`ssh meyd@black.alchemycat.org`).
- Multi-user isolation: 1 Linux user per agent (`meyd`, `nat`, `black`, `golf`, `maw-rs`, `noah-oracle`).
- Orchestration: `maw-rs` (`/home/<user>/.local/bin/maw`) running as `maw serve` + `maw a/attach`, `maw wake`, `maw work`.
- Proxy: `9router` running on `meyd` port `:20128`.
- Note: Never claim `black` is unreachable or missing without running `ssh meyd@black.alchemycat.org` first.
