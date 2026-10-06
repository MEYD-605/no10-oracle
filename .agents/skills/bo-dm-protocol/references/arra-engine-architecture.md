# Arra Oracle Engine Architecture & Status Reference

## Arra Engine Implementation
- **Core Server (`arra-oracle-v3`)**: Built with **Bun (TypeScript / ElysiaJS)**, SQLite, `sqlite-vec`, and `drizzle-orm`.
- **Location**: `/Users/admin/Code/github.com/MEYD-605/arra-oracle-v3`
- **Port**: Local `127.0.0.1:47778` (public CF tunnel: `https://maclab.clubsxai.com/api/`)
- **Performance**: High-throughput hybrid search (<100ms response time), embedded vector search using `bge-m3`.

## Clarification on Arra vs Rust (RS)
- Bo query pattern: *"ยังไม่เป็น rsหรา มีผลไหม"*
- Answer structure:
  1. Arra Oracle v3 is currently TypeScript/Bun-based (`arra-oracle-v3`), NOT Rust.
  2. The Rust (`-rs`) components in the fleet are **`maw-rs`** (federation & CLI tools) and **`discord-reply-rust`** (MCP/relay binary).
  3. No performance degradation — Bun engine executes queries in sub-100ms vector lookup speeds. Zero impact on fleet operations.
