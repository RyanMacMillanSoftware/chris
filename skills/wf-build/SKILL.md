---
description: "Spawn an agent to work on the next task. Manages git and loads context."
---

# /wf-build

Spawn an agent to work on the next incomplete task in a project. Set up worktrees if needed. Load all relevant context. Manage git.

`$ARGUMENTS` — optional: `<project-slug>`, `<project-slug> --local`, `<project-slug> --no-arch`, `<project-slug> --sequential`

**Flags:**
- `--local` — Print the agent brief to the terminal instead of spawning a subagent.
- `--no-arch` — Skip the architect pass entirely for this invocation.
- `--sequential` — Disable parallel execution; pick only the first ready task and proceed as single-task flow.

## Determine the target project

If `$ARGUMENTS` provides a slug, use it. Otherwise scan `~/Code/chris/projects/*/status.json` for projects whose `repos` contains the cwd repo and `stage` is `"tasks"` or `"build"` — use the single match, or ask if multiple. If no cwd match either, list all `tasks`/`build` projects and ask.

## Stage preflight

Follow the procedure in `skills/_shared/preflight.md`. Stop on any failure before proceeding.

## Find the next task

Read TASKS.md. Find the first unchecked `- [ ] TASK-NNN`. If all checked, print `✅ All tasks complete for '<slug>'. Run /wf-review.` and stop.

## Parallel detection

Find ready tasks (all `Deps:` are `"none"` or checked `[x]`). From those, collect tasks tagged `[P]`.

- `--sequential`: skip parallel detection, pick only the first ready task.
- **2+ ready `[P]` tasks:** show `⚡ N parallelizable tasks ready: TASK-XXX, TASK-YYY. Spawn in parallel? (y/n)`. Yes → treat all as current batch (each gets its own brief + subagent, all IDs added to `status.json.active_agents`). No → single-task flow.
- **0–1 ready `[P]` tasks:** single-task flow.

## Check for conflicts

For each repo, find other `chris/*` branches and compare their changed files against this project's changed files (use `git diff --name-only $(git merge-base main <branch>) <branch>`). If any files overlap, notify the user and add an entry to `status.json` conflicts array: `{"repo", "competing_project", "files", "detected_at", "resolved": false}`.

## Set up worktrees

If a competing branch exists on the repo, use a worktree at `~/Code/.chris-worktrees/<slug>/<repo>/` (create with `git worktree add` if absent; run `install_cmd` from AGENTS.md front matter if set; update `status.json` worktrees map). Otherwise check out `chris/<slug>` directly in `~/Code/<repo>/`.

## Assemble agent context

Read PRD.md, SPEC.md, TASKS.md, and each involved repo's AGENTS.md. Assemble the brief following `skills/_shared/brief.md` (AGENTS.md excerpt, CONTEXT.md excerpt, task block, standards via `/inject-standards`, prior handoff — all with section budgets). Working directory is the worktree path if set up, else `~/Code/<repo>/`.

## Architect pass (per task)

Skip if `--no-arch` is set. For parallel tasks run passes sequentially, confirm all, then spawn builders.

Spawn a synchronous architect sub-agent (Task tool, in-session) with the task description + acceptance criteria + SPEC.md Architecture section + any injected standards. Instruction: "Produce a short implementation plan — no file writes. Which files, what changes, what approach. Max one screen."

Display the plan. Prompt `Proceed? [y / n to revise / s to skip]`:
- **y** → append plan to brief as `## Architect Plan`, spawn builder
- **n** → ask what to change, re-run with feedback, loop until y or s
- **s** → skip plan, spawn builder immediately

## Spawn the agent

**Default (no `--local` flag):**

Spawn a subagent with a brief assembled per `skills/_shared/brief.md`, plus:
```
You are working on project '<slug>', task <TASK-NNN>: <title>.
Working directory: <worktree-or-repo-path>
Branch: chris/<slug>

[Assembled context per skills/_shared/brief.md]

## Architect Plan
<approved architect plan, if any>

Git instructions:
- You are on branch chris/<slug>. Do not switch branches.
- Commit at logical checkpoints using conventional commits (feat:, fix:, chore:, etc.)
- Do not push — /wf-review handles pushing

## Handoff instructions (section E)

When done with this task:
1. Mark the task [x] in TASKS.md
2. Generate handoff per `skills/_shared/handoff.md`
3. Commit all changes (TASKS.md + handoff + source)
4. Report: "Build complete: <slug> TASK-NNN done"

## CONTEXT.md update instructions (section F)

Update CONTEXT.md on completion:
- Set "Current Focus" to the next expected work
- Add key decisions to "Recent Decisions"
- Remove any resolved items from "Open Questions"
```

**With `--local` flag:** Print the brief to the terminal. Tell the user to open a new Claude session: `cd <worktree-or-repo-path> && claude`.

## Update status.json

Set `stage` to `"build"`. Add `{"task": "TASK-NNN", "started_at": "<ISO8601>"}` to `active_agents`. Update `updated`. Commit: `chore: start build for <slug> TASK-NNN`.

## Print confirmation

```
🟢 Build started: <slug> — TASK-NNN: <title>
   Working in: <working-directory>
   Branch: chris/<slug>
```
