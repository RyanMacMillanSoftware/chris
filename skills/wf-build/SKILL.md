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

Read `project_type` from `status.json`. Default to `"code"` if the field is absent.

**Branch gate — writing projects:** If `project_type == "writing"`, delegate immediately to the wf-write skill. Follow all instructions in `skills/wf-write/SKILL.md` starting from "Load context." Do not proceed past this point.

**Branch gate — investigation projects:** If `project_type == "investigation"`, delegate immediately to the wf-investigate skill. Follow all instructions in `skills/wf-investigate/SKILL.md` starting from "Read the plan." Do not proceed past this point.

**Branch gate — communication projects:** If `project_type == "communication"`, delegate immediately to the wf-communicate skill. Follow all instructions in `skills/wf-communicate/SKILL.md` starting from "Read the plan." Do not proceed past this point.

**Branch gate — program projects:** If `project_type == "program"`, skip to the [Program path] section below. Do not proceed with the standard task flow.

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

**Skip this section entirely if `project_type` is `"writing"` or `"research"`.**

If a competing branch exists on the repo, use a worktree at `~/Code/.chris-worktrees/<slug>/<repo>/` (create with `git worktree add` if absent; run `install_cmd` from AGENTS.md front matter if set; update `status.json` worktrees map). Otherwise check out `chris/<slug>` directly in `~/Code/<repo>/`.

## Assemble agent context

**Skip this section if `project_type` is `"writing"` (already handled by the branch gate above) or `"research"` (jump to [Research path] below).**

Read PRD.md, SPEC.md, TASKS.md, and each involved repo's AGENTS.md. Assemble the brief following `skills/_shared/brief.md` (AGENTS.md excerpt, CONTEXT.md excerpt, task block, standards via `/inject-standards`, prior handoff — all with section budgets). Working directory is the worktree path if set up, else `~/Code/<repo>/`.

## Architect pass (per task)

**Skip this section if `project_type` is `"writing"` or `"research"`.**

Skip if `--no-arch` is set. For parallel tasks run passes sequentially, confirm all, then spawn builders.

Spawn a synchronous architect sub-agent (Task tool, in-session) with the task description + acceptance criteria + SPEC.md Architecture section + any injected standards. Instruction: "Produce a short implementation plan — no file writes. Which files, what changes, what approach. Max one screen."

Display the plan. Prompt `Proceed? [y / n to revise / s to skip]`:
- **y** → append plan to brief as `## Architect Plan`, spawn builder
- **n** → ask what to change, re-run with feedback, loop until y or s
- **s** → skip plan, spawn builder immediately

## Obsidian integration (passthrough)

Include these instructions in the agent brief:

"Every markdown file you write must start with YAML frontmatter (project, type, tags, aliases, created, updated). After the title heading, include: `> **Hub:** [[{slug}/{slug}-index|{project_name}]]`. After writing a file, append a wikilink entry to the project's `{slug}-index.md` under the appropriate section (Research or Drafts)."

## Spawn the agent

### project_type == "code"

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

### project_type == "writing"

This path is handled by the branch gate in "Stage preflight". If execution reaches this point for a writing project, delegate now: follow all instructions in `skills/wf-write/SKILL.md` starting from "Load context." Do not continue past this subsection.

### project_type == "research"

**Default (no `--local` flag):**

Spawn a subagent with the following brief:

```
You are working on project '<slug>', task <TASK-NNN>: <title>.
Working directory: ~/Code/chris/projects/<slug>/research/

## Project context

<PRD overview paragraph — one short paragraph summarizing the project goal>

## Task

<Full task block from TASKS.md, including the Question: and Deliverable: fields>

## Research instructions

- Research the question stated in the task using primary sources, peer-reviewed publications,
  and official documentation. Prefer these over secondary summaries.
- Synthesize your findings into a clear, well-structured markdown document.
- Cite every source as a markdown link including the page title and the date accessed:
  [Title](https://example.com) — accessed <YYYY-MM-DD>
- Output a single markdown file named after the task title (lowercase, hyphenated, .md extension).
  Example: for "TASK-004: LLM Benchmarks 2025" → `llm-benchmarks-2025.md`
- Save the file to: ~/Code/chris/projects/<slug>/research/
- Do not create subdirectories under research/. Do not write to any other location.
- Do not write any code, scripts, or technical implementation. Research and prose only.
- Do not set up git worktrees, branches, or make git commits.

## Acceptance criterion

Deliverable file exists in ~/Code/chris/projects/<slug>/research/ and covers all points in
the task's Deliverable field, with all sources cited.

There is no test-pass criterion for research tasks.

## Handoff instructions (section E)

When done with this task:
1. Mark the task [x] in ~/Code/chris/projects/<slug>/TASKS.md
2. Generate handoff file at ~/Code/chris/projects/<slug>/handoffs/<TASK-NNN>.json with fields:
   - task: "<TASK-NNN>"
   - title: "<task title>"
   - completed_at: "<ISO8601 timestamp>"
   - output_file: "<filename>.md"
   - confidence: "high" | "medium" | "low"
   - open_questions: [] or list of strings
   - notes: brief summary of research findings and sources used
3. Report: "Build complete: <slug> <TASK-NNN> done"
```

**With `--local` flag:** Print the brief to the terminal. Tell the user to open a new Claude session: `cd ~/Code/chris/projects/<slug>/research/ && claude`.

## Update status.json

Set `stage` to `"build"`. Add `{"task": "TASK-NNN", "started_at": "<ISO8601>"}` to `active_agents`. Update `updated`. Commit: `chore: start build for <slug> TASK-NNN`.

**Note for `"writing"` projects:** status.json update is handled inside `wf-write`; skip this step.

**Note for `"research"` projects:** run the update directly here.

## Print confirmation

For `"code"` projects:
```
🟢 Build started: <slug> — TASK-NNN: <title>
   Working in: <working-directory>
   Branch: chris/<slug>
```

For `"writing"` projects: print confirmation is handled by `wf-write`.

For `"research"` projects:
```
🟢 Build started: <slug> — TASK-NNN: <title>
   Working in: ~/Code/chris/projects/<slug>/research/
```

---

## Research path

_Entered when `project_type == "research"` after "Find the next task" and "Parallel detection". Skip "Check for conflicts", "Set up worktrees", "Assemble agent context", and "Architect pass". Proceed directly to [Spawn the agent — project_type == "research"] above, then "Update status.json" and "Print confirmation"._

---

## Program path

_Entered when `project_type == "program"` from the branch gate in "Stage preflight"._

1. Read `children[]` from `status.json`.
2. For each child slug, read its `status.json` to get the current stage.
3. Print a status table:
   ```
   📋 Program: <slug>

   | Child | Type | Stage |
   |-------|------|-------|
   | <child-slug> | <type> | <stage> |
   ```
4. Identify the child that should advance next. Priority:
   - Children at `build` stage (need `/wf-build`)
   - Children at `plan` or `tasks` stage (need next pipeline step)
   - Children at `new` stage (need `/wf-plan` or `/wf-prd`)
   - Skip children at `review` or `done`
5. Suggest the next command:
   - If a child needs planning: `Next: /wf-plan <child-slug>` (or `/wf-prd` for code)
   - If a child needs building: `Next: /wf-build <child-slug>`
   - If all children are `done`: `✅ All children complete. Run /wf-review <slug>.`
