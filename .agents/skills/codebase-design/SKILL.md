---
name: codebase-design
description: '[engineering] E-SKLL | Deep-module design vocabulary — small interface, large implementation, clean seams. Use when designing modules, refactoring for testability, or supporting /tdd and /grilling. Source: utarn/engineer-skills.'
origin: utarn/engineer-skills
---

# /codebase-design — Deep modules

Design **deep modules**: lots of behaviour behind a small interface at a clean **seam**, testable through that interface.

## Glossary (use exactly)

| Term | Meaning |
|------|---------|
| **Module** | Anything with interface + implementation (function → tier) |
| **Interface** | What callers must know: types, invariants, errors, perf |
| **Implementation** | Code inside the module |
| **Depth** | Behaviour per unit of interface learned |
| **Seam** | Where behaviour can change without editing callers |
| **Adapter** | Concrete thing at a seam filling an interface role |
| **Leverage** | Callers get more capability per interface learned |
| **Locality** | Maintainers fix/verify in one place |

## Deep vs shallow

- **Deep** ✅ — small interface, complex hidden implementation
- **Shallow** ❌ — interface almost as big as implementation (pass-through)

## Use with

- `/grilling` — where should the seam go?
- `/tdd` — test through the interface, not internals
- `/improve-codebase-architecture` (future cherry-pick)

## Quick check

Before merging: can a caller do more with fewer concepts? Can tests hit the seam without mocks of internals?