---
description: "Show all Chris projects and their current stage."
---

# /wf-status

Show all active Chris projects and their current stage. Output is formatted as a plain list — no markdown tables — so it renders correctly in plain-text surfaces.

`$ARGUMENTS` — optional: `all` to include done projects (default hides them)

## Read all projects

Scan `~/Code/chris/projects/*/status.json`. Read each file.

## Sort projects

Order:
1. `build` (active agent running — highest priority)
2. `tasks`
3. `spec`
4. `spec-research`
5. `prd`
6. `prd-research`
7. `new`
8. `review` (PR open, awaiting merge)
9. `done` (only shown if `$ARGUMENTS` is `all`)

## Format the output

Use this exact format — plain text, emoji for stage, no tables:

```
📋 Chris Projects

🟢 <slug> — build (agent running)
   Repos: <repo1>, <repo2>
   ⚠️  Conflict: <repo> ↔ <competing-project>

🟡 <slug> — tasks
   Repos: <repo>

🔵 <slug> — prd
   Repos: (not yet assigned)

🔵 <slug> — review
   Repos: <repo>
   PR: <pr_url>

✅ <slug> — done
   (only shown with /wf-status all)
```

**Stage emoji:**
- 🔵 `new` — just created
- 🟡 `prd`, `spec`, `tasks` — in planning
- 🟡 `prd-research`, `spec-research` — researching
- 🟢 `build` — actively building
- 🔵 `review` — PR open
- ✅ `done` — merged and closed

**Conflict indicator:** Only show the `⚠️ Conflict` line if the project's `conflicts` array contains entries where `resolved` is `false`.

**Active agent indicator:** Show `(agent running)` in the build line if `active_agents` array is non-empty.

**PR URL:** Show the PR URL for projects in `review` stage if `pr_url` is set in status.json.

## Empty state

If no projects (or all are `done` and `all` flag not set):
```
No active projects. Run /wf-new to start one.
```

## Print the output

Just print it. No preamble. No markdown code blocks. Plain text.
