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

**Case 1: `$ARGUMENTS` provides a slug**
Use that slug. Read `~/Code/chris/projects/<slug>/status.json`.

**Case 2: Running from inside a repo directory**
The cwd is `~/Code/<repo>/` or a subdirectory. Scan all `~/Code/chris/projects/*/status.json` for entries where `repos` contains `<repo>` and `stage` is `"tasks"` or `"build"`.
- If exactly one match → use it
- If multiple matches → ask: "Multiple projects reference this repo: [list]. Which one?"

**Case 3: No cwd match and no argument**
List all projects with stage `"tasks"` or `"build"` and ask: "Which project do you want to build?"

## Stage preflight

Follow the procedure in `skills/_shared/preflight.md`. Stop on any failure before proceeding.

## Find the next task

Read `~/Code/chris/projects/<slug>/TASKS.md`. Find the first unchecked task `- [ ] TASK-NNN`.

If all tasks are checked, print:
```
✅ All tasks complete for '<slug>'. Run /wf-review to review and open a PR.
```
Then stop.

## Parallel detection

Read all unchecked tasks. Identify ready tasks: tasks whose `Deps:` are either `"none"` or reference only tasks already checked `[x]`.

From the ready tasks, collect those tagged `[P]` on their title line.

- **If `--sequential` flag is set:** Skip parallel detection entirely. Pick only the first ready task and proceed with single-task flow.
- **If 2 or more ready `[P]` tasks exist (and no `--sequential` flag):**
  - Show: `⚡ N parallelizable tasks ready: TASK-XXX, TASK-YYY. Spawn in parallel? (y/n)`
  - If yes: treat all ready `[P]` tasks as the current batch. Each gets its own full brief and subagent. Update `status.json.active_agents` with all task IDs.
  - If no: pick only the first ready task and proceed with single-task flow.
- **If 0 or 1 ready `[P]` tasks:** Proceed with single-task flow (existing behaviour).

## Check for conflicts

For each repo in the project's `repos` array:
1. Find all other projects with a `chris/*` branch on the same repo:
   ```bash
   git -C ~/Code/<repo> branch --list "chris/*" | grep -v "chris/<slug>"
   ```
2. For each competing branch, get the list of files it has modified since branching from main:
   ```bash
   git -C ~/Code/<repo> diff --name-only $(git -C ~/Code/<repo> merge-base main <competing-branch>) <competing-branch>
   ```
3. Get the files the current project's branch has modified:
   ```bash
   git -C ~/Code/<repo> diff --name-only $(git -C ~/Code/<repo> merge-base main chris/<slug>) chris/<slug> 2>/dev/null
   ```
4. If there is an overlap in modified files:
   - Notify: "⚠️ Conflict detected: <slug> and <competing-project> both modify these files in <repo>: [file list]. Continuing — watch for merge conflicts."
   - Add to `status.json` conflicts array:
     ```json
     {"repo": "<repo>", "competing_project": "<competing>", "files": [...], "detected_at": "<ISO8601>", "resolved": false}
     ```

## Set up worktrees

For each repo in the project:

1. Check if another active `chris/*` branch exists on the repo (from conflict check above).
2. If yes — use a worktree:
   - Worktree path: `~/Code/.chris-worktrees/<slug>/<repo>/`
   - If worktree doesn't exist:
     ```bash
     mkdir -p ~/Code/.chris-worktrees/<slug>
     git -C ~/Code/<repo> worktree add ~/Code/.chris-worktrees/<slug>/<repo>/ chris/<slug>
     ```
   - If `install_cmd` is set in `~/Code/<repo>/AGENTS.md` front matter, run it in the worktree:
     ```bash
     cd ~/Code/.chris-worktrees/<slug>/<repo>/ && <install_cmd>
     ```
   - Update `status.json` worktrees: `{"<repo>": "~/Code/.chris-worktrees/<slug>/<repo>/"}`
3. If no competing branch — work directly in `~/Code/<repo>/` on branch `chris/<slug>`:
   ```bash
   git -C ~/Code/<repo> checkout chris/<slug>
   ```

## Assemble agent context

Read PRD.md, SPEC.md, TASKS.md, and each involved repo's AGENTS.md in full.

Identify the specific task(s) to work on and the working directory (worktree path if set up, else `~/Code/<repo>/`).

Assemble the agent brief following `skills/_shared/brief.md` — this covers AGENTS.md and CONTEXT.md excerpts, the task block, standards injection via `/inject-standards`, and prior handoff, all with section budgets.

## Architect pass (per task)

Run this step for each selected task, after task selection and before worktree setup. Skip entirely if `--no-arch` flag is set.

For parallel tasks: run one architect pass per task sequentially, confirm all, then spawn all builders.

1. Spawn a synchronous architect sub-agent (using the Task tool, in-session) with:
   - The task description and acceptance criteria
   - The Architecture section from SPEC.md
   - Any injected AgentOS standards (see above)
   - Instruction: "Produce a short implementation plan — no file writes. Which files will you touch, what will you add/change, what is your approach. Max one screen."

2. Display the plan inline. Prompt:
   ```
   Proceed? [y / n to revise / s to skip]
   ```
   - **y** → Append the approved plan to the builder brief under "## Architect Plan", then proceed to spawn the builder.
   - **n** → Ask "What should change?" then re-run the architect sub-agent with the feedback appended. Loop until the user chooses y or s.
   - **s** → Skip to the builder immediately (omit the Architect Plan section from the brief).

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

**With `--local` flag:**

Print the agent brief above to the terminal and say:
```
Open a new Claude session in the working directory and run the task:
  cd <worktree-or-repo-path>
  claude
```

## Update status.json

Set `stage` to `"build"` (if not already).
Add to `active_agents`:
```json
{"task": "TASK-NNN", "started_at": "<ISO8601>"}
```
Update `updated` timestamp.

Commit status update:
```bash
cd ~/Code/chris/projects
git add <slug>/status.json
git commit -m "chore: start build for <slug> TASK-NNN"
```

## Print confirmation

```
🟢 Build started: <slug> — TASK-NNN: <title>
   Working in: <working-directory>
   Branch: chris/<slug>

Check back in this session for task completion.
Run /wf-status to check progress.
```
