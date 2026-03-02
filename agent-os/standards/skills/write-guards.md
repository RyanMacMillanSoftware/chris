# Write Guards

Apply to any skill that writes project documents (PRD, SPEC, TASKS). Guards prevent writing to the wrong project when the target was inferred rather than explicit.

## Gate 1 — Confirm inferred target

If `$ARGUMENTS` provided no slug and the target project was detected from cwd:

```
Writing <document> for '<slug>'. Confirm? (y/n)
```

Abort on `n`.

## Gate 2 — Block slug mismatch

If `$ARGUMENTS` provided a slug **and** cwd also matches a different project:

```
❌ Slug mismatch: argument is '<arg-slug>' but cwd matches '<detected-slug>'. Check your working directory.
```

Always stop. Do not prompt to continue.

## When to skip

- Skills that only read project files (wf-status, wf-review pre-read phase) skip both gates.
- The gates fire immediately before the first file write, not at detection time.
