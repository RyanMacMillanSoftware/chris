---
description: "Spawn an agent to work on the next task. Manages git and loads context."
---

# /wf-build

Spawn an agent to work on the next incomplete task in a project. Set up worktrees if needed. Load all relevant context. Manage git.

`$ARGUMENTS` — optional: `<project-slug>` or `<project-slug> --local`

## Determine the target project

**Case 1: `$ARGUMENTS` provides a slug**
Use that slug. Read `~/Code/chris/projects/<slug>/status.json`.

**Case 2: Running from inside a repo directory**
The cwd is `~/Code/<repo>/` or a subdirectory. Scan all `~/Code/chris/projects/*/status.json` for entries where `repos` contains `<repo>` and `stage` is `"tasks"` or `"build"`. 
- If exactly one match → use it
- If multiple matches → ask: "Multiple projects reference this repo: [list]. Which one?"

**Case 3: No cwd match and no argument**
List all projects with stage `"tasks"` or `"build"` and ask: "Which project do you want to build?"

Require the project to have stage `"tasks"` or `"build"`. If stage is earlier, print:
```
❌ Project '<slug>' is at stage '<stage>'. Complete /wf-tasks first.
```

## Find the next task

Read `~/Code/chris/projects/<slug>/TASKS.md`. Find the first unchecked task `- [ ] TASK-NNN`.

If all tasks are checked, print:
```
✅ All tasks complete for '<slug>'. Run /wf-review to review and open a PR.
```
Then stop.

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

Collect and read:
- `~/Code/chris/projects/<slug>/PRD.md`
- `~/Code/chris/projects/<slug>/SPEC.md`
- `~/Code/chris/projects/<slug>/TASKS.md`
- `~/Code/<repo>/AGENTS.md` for each involved repo

Identify the specific task to work on (first unchecked TASK-NNN).

Identify the working directory: worktree path if set up, else `~/Code/<repo>/`.

## Spawn the agent

**Default (no `--local` flag):**

Spawn a subagent with this brief:
```
You are working on project '<slug>', task <TASK-NNN>: <title>.

Working directory: <worktree-or-repo-path>
Branch: chris/<slug>

[Full content of PRD.md]
[Full content of SPEC.md]
[Relevant section of TASKS.md]
[Content of each repo's AGENTS.md]

Your task:
<task description and acceptance criteria>

Git instructions:
- You are on branch chris/<slug>. Do not switch branches.
- Commit your work at logical checkpoints using conventional commits (feat:, fix:, chore:, etc.)
- Do not push — /wf-review handles pushing
- When done with the task, update the checkbox in TASKS.md to [x]

When completely finished, report completion back to the parent session:
Build complete: <slug> TASK-NNN done
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
