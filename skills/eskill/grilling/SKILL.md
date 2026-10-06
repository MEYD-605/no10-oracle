---
name: grilling
description: '[engineering] E-SKLL | Interview relentlessly to sharpen a plan or design before building. Use when user says "grill", "grill me", stress-test a plan, or before large infra/code changes. Source: utarn/engineer-skills (fork mattpocock/skills).'
origin: utarn/engineer-skills
---

# /grilling — Stress-test a plan

Interview the user relentlessly about every aspect of the plan until shared understanding.

## Rules

1. **One question at a time** — wait for answer before next question
2. **Recommend an answer** with each question (don't just ask)
3. **Explore codebase first** when a question can be answered by reading code — use `rtk read`, `rtk grep`, `rtk git`
4. Walk the design tree branch-by-branch; resolve dependencies between decisions
5. End with a **short decision summary** (3–7 bullets) before any implementation

## When to use

- Bo gives a vague or high-stakes task (deploy, migrate, refactor)
- Multiple valid approaches — need to pick one deliberately
- Before `/tdd` or large PRs

## Anti-patterns

- Asking 5 questions in one message
- Starting to code before grilling finishes
- Guessing instead of surveying (`Survey before action`)