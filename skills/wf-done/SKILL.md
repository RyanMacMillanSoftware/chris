---
description: "Close a completed project. Generate release artifacts. Clean up git."
---

# /wf-done

Close a project after its PR has been merged. Generate release artifacts, clean up worktrees and branches, and archive the project as done.

`$ARGUMENTS` — optional project slug

## Detect the current project

Same detection logic as other wf-* skills. Project should be at stage `"review"`, but also accept `"build"` (in case review was skipped).

## Read project type

Read `project_type` from `status.json`. Default to `"code"` if absent.

## Program children check

If `project_type == "program"`:
1. Read `children[]` from `status.json`.
2. For each child, read its `status.json` and check the stage.
3. If any child is not at `"done"`, warn:
   ```
   ⚠️ Not all children are done:
     <child-slug> — <stage>
   Continue anyway? (y/n)
   ```
   If no, stop. If yes, proceed.

## Confirm before proceeding

For code projects:
Ask: "Is the PR for '<slug>' merged and the work complete? This will generate release artifacts and archive the project. Confirm? (y/n)"

For non-code projects:
Ask: "Is the work for '<slug>' complete? This will generate release artifacts and archive the project. Confirm? (y/n)"

If no, print: "Cancelled. Run again when ready."

## Generate release artifacts

Create directory `~/Code/chris/projects/<slug>/release/` if it doesn't exist.

Read the full project history:

For code projects:
- `<project_dir>/PRD.md`
- `<project_dir>/SPEC.md`
- `<project_dir>/TASKS.md`
- `status.json` (for PR URL, repos, branch)

For non-code projects:
- `<project_dir>/PLAN.md`
- `status.json`
- Any files in `research/`, `drafts/`, or `handoffs/`

Get the commit log for each repo:
```bash
git -C ~/Code/<repo> log chris/<slug> --oneline --no-merges 2>/dev/null
# or from worktree if it still exists
```

**Write `~/Code/chris/projects/<slug>/release/PRESS-RELEASE.md`:**

Write this as a brief, human-readable announcement — as if for public consumption. Include:
- A punchy headline
- **What We Built** — one paragraph describing the project outcome
- **Why It Matters** — one paragraph on the value or problem it solved
- **Key Highlights** — 3–5 bullet points on notable features or decisions

Base content on the PRD goals, problem statement, and completed tasks.

**Write `~/Code/chris/projects/<slug>/release/RELEASE-NOTES.md`:**

Technical changelog for future reference. Audience: future maintainers, future agents. Include:
- Project name, completion date, repos touched, PR URL
- **Completed Tasks** — list all `[x]` tasks from TASKS.md
- **Decisions Made During Build** — any notable choices, trade-offs, or things that diverged from the spec
- **Deferred / Out of Scope** — anything intentionally left out
- **Known Issues** — anything to watch for post-merge

**Write `~/Code/chris/projects/<slug>/release/UPDATE-LOG.md`:**

Terse commit log, grouped by repo. Format:
```markdown
# Update Log: <project-name>

## <repo-name>
- <sha> <commit message>
- <sha> <commit message>

## <repo-name-2>
- <sha> <commit message>
```

## Clean up git

**Skip this section entirely for non-code projects** (`research`, `investigation`, `writing`, `communication`, `program`). Non-code projects don't use git branches or worktrees.

For each repo in `status.json` repos (code projects only):

1. If a worktree exists (check `status.json` worktrees map):
   ```bash
   git -C ~/Code/<repo> worktree remove ~/Code/.chris-worktrees/<slug>/<repo>/ --force
   git -C ~/Code/<repo> worktree prune
   ```
   Print: `✅ Removed worktree for <repo>`

2. Delete the local branch:
   ```bash
   git -C ~/Code/<repo> branch -d chris/<slug>
   ```
   If the branch can't be deleted (unmerged), warn: "⚠️ Branch chris/<slug> in <repo> couldn't be deleted (may not be fully merged). Delete manually: `git branch -D chris/<slug>`"

## Update status.json

```json
{
  "stage": "done",
  "active_agents": [],
  "worktrees": {},
  "closed_at": "<current ISO8601 timestamp>",
  "updated": "<current ISO8601 timestamp>"
}
```

## Dashboard regeneration

If `vault_path` is configured in `~/.chris/config.yml`, regenerate the dashboard:
- Scan all projects, write `<vault_path>/dashboard.md` (same logic as `/wf-status --dashboard`).

## Commit release artifacts

```bash
git -C ~/Code/chris/projects add <slug>/release/ <slug>/status.json && git -C ~/Code/chris/projects commit -m "docs: add release artifacts for <slug>"
```

## Print summary

```
✅ Project '<slug>' closed.

Release artifacts:
  ~/Code/chris/projects/<slug>/release/PRESS-RELEASE.md
  ~/Code/chris/projects/<slug>/release/RELEASE-NOTES.md
  ~/Code/chris/projects/<slug>/release/UPDATE-LOG.md

Git cleaned up:
  Worktrees removed ✅
  Branch chris/<slug> deleted from: <repo-list> ✅

PR: <pr_url>
```
