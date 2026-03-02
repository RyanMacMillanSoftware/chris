# Shared Fragments

Reusable skill logic lives in `skills/_shared/`. Current fragments:
- `preflight.md` — stage/file/branch checks before any build
- `brief.md` — agent brief assembly with section budgets
- `handoff.md` — handoff JSON schema and field responsibilities

## When to extract to _shared/

Extract when either condition is true:
- **Duplicated across 2+ skills** — same instructions appear verbatim in multiple SKILL.md files
- **Long procedure** — content is long enough to dominate a skill file

## How to reference

Prose pointer in the skill body:

```
Follow the procedure in `skills/_shared/preflight.md`.
```

No special import syntax. The agent reads the referenced file directly.

## What stays inline

- Short, skill-specific logic that is not reused
- Steps that differ even slightly between skills (inline with a comment, not extracted)
