# Project Detection

All `wf-*` skills use the same three-step detection sequence. Stage gating is a separate step that follows.

## Detection sequence

1. **Slug arg** — if `$ARGUMENTS` provides a slug, use it directly.
2. **cwd match** — scan `~/Code/chris/projects/*/status.json`; match where `repos` contains the current working directory repo.
3. **Ask** — if no cwd match, list all projects at valid stages and ask the user to pick one.

## Stage gating (separate step, after detection)

```
❌ Project '<slug>' is at stage '<stage>', not <expected>. Run /wf-<prev> first.
```

- Warn but don't block if re-running the same stage (e.g., wf-tasks on a tasks-stage project).
- Do not combine detection and stage filtering into a single pass.
