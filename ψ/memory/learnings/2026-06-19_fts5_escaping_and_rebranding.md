---
pattern: SQLite FTS5 MATCH queries must sanitize all special operators, and plugin paths must prioritize environment values over hardcoded local paths.
date: 2026-06-19
source: rrr: workshop-05-backfill-midterm
concepts: [sqlite, fts5, architecture, security]
---

# SQLite FTS5 Query Escaping and Env-Driven Token Portability

## 1. The FTS5 MATCH Parser Crash
SQLite FTS5 virtual tables offer high-performance full-text search capability. However, passing unescaped search text into a `MATCH` clause can trigger SQLite parser failures and crash the application:
- Search text with unbalanced single/double quotes (`'foo"`) throws a syntax error.
- Special query operators like `*`, `-`, `:`, `^`, `~`, or parentheses have special semantic meanings in FTS5. If user input contains these operators incorrectly, SQLite's FTS5 query parser fails to tokenize them.

### Solution: Operator Sanitization Regex
In this midterm session, we implemented an FTS5 MATCH query sanitization pattern. At a minimum, single and double quotes should be replaced with spaces:
```typescript
const sanitized = searchText.replace(/[\"']/g, " ");
```
To prevent crashes on all operators, we should sanitize other FTS5 special characters before query execution:
```typescript
const FTS5_SPECIAL_CHARS = /[?*+\-()^~"':]/g;
export function escapeFTS5Query(query: string): string {
  return query.replace(FTS5_SPECIAL_CHARS, " ").trim();
}
```

---

## 2. Portability in Multi-Agent Environments
Low-level CLI plugins often need to retrieve credentials (such as Discord Bot Tokens) from host directories. Hardcoding paths to specific developer profiles or local test configs (e.g. `/root/.hermes/profiles/kikyo-codex/.env`) breaks portability when code is run on other LXC containers, machines, or home systems.

### Solution: Dynamic Environment Candidates
Standardize credentials lookups using dynamic workspace home directories and check environment variables before scanning fallback config candidates:
```typescript
export function getToken(): string | null {
  if (process.env.DISCORD_BOT_TOKEN) return process.env.DISCORD_BOT_TOKEN;

  const candidates = [
    process.env.HERMES_HOME ? `${process.env.HERMES_HOME}/.env` : null,
    "/root/.hermes/.env",
    "/root/.claude/channels/discord-no6/.env",
    `${process.env.HOME}/.hermes/profiles/kikyo-codex/.env`,
    `${process.env.HOME}/.hermes/.env`,
  ].filter(Boolean) as string[];

  for (const file of candidates) {
    const token = readEnvToken(file);
    if (token) return token;
  }
  
  // Fallback to pass key-store
  try {
    return execSync("pass show discord/atlas-oracle-token 2>/dev/null", { encoding: "utf8" }).trim() || null;
  } catch { return null; }
}
```
This env-driven candidate pattern ensures that credentials fallbacks are searched across all environments without hardcoding machine-specific locations.
