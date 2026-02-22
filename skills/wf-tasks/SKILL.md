---
description: "Break the spec into ordered tasks. Identify repos. Set up git branches."
---

# /wf-tasks

Break the project spec into ordered, testable tasks. Identify which repos each task touches. Confirm with the user. Set up branches.

`$ARGUMENTS` — optional project slug

## Detect the current project

Same detection logic as other wf-* skills. Require stage `"spec"` — if not, print:
```
❌ Project '<slug>' is at stage '<stage>', not spec. Run /wf-spec first.
```
(Warn but don't block if stage is already `"tasks"` — allow re-running to update tasks.)

Read `~/Code/chris/projects/<slug>/SPEC.md` in full.

## Write the tasks

Break the spec into atomic, ordered tasks. Each task should be completable in a single focused agent session.

Format — use this exact structure for every task:

```markdown
- [ ] TASK-NNN: Short descriptive title
  **Repos:** repo-name (or comma-separated list)
  **Deps:** TASK-NNN, TASK-NNN (or "none")

  Description: what needs to be done. Specific enough that an agent can execute this without asking clarifying questions.

  **Accepts:** A specific, verifiable condition that proves the task is complete.
```

Guidelines:
- Number tasks with zero-padded three digits: TASK-001, TASK-002, etc.
- Order them so dependencies are satisfied before dependents
- Each task touches as few repos as possible
- Group related tasks under `## Phase N — Name` headings
- Keep descriptions concrete — file paths, command names, exact formats

As you write tasks, note which repos each one touches.

## Confirm repos with the user

After drafting all tasks, compile the full list of repos involved (deduplicated).

Show the user: "This project will touch the following repos: [list]. Is that correct? Anything to add or remove?"

Wait for confirmation. Adjust task repo assignments if needed.

## Set up branches

For each confirmed repo:

1. Check if `~/Code/<repo>/` exists. If not:
   ```
   ⚠️  Repo '~/Code/<repo>/' not found.
   Either create it with /wf-new or add the path manually.
   ```
   Ask the user how to proceed before continuing.

2. Check if branch `chris/<slug>` already exists:
   ```bash
   git -C ~/Code/<repo> branch --list "chris/<slug>"
   ```
   If it doesn't exist, create it:
   ```bash
   git -C ~/Code/<repo> checkout -b chris/<slug>
   git -C ~/Code/<repo> checkout -
   ```
   Print: `✅ Created branch chris/<slug> in <repo>`

3. Check if any other active project also has a `chris/*` branch on this repo:
   ```bash
   git -C ~/Code/<repo> branch --list "chris/*"
   ```
   If multiple chris branches exist, note: "⚠️ Multiple projects touching <repo> — worktrees will be used during /wf-build."

## Save and commit

Write `~/Code/chris/projects/<slug>/TASKS.md` using the format above.

Update `status.json`:
- `stage`: `"tasks"`
- `repos`: the confirmed repo list
- `branch`: `"chris/<slug>"`
- `updated`: current timestamp

Commit:
```bash
cd ~/Code/chris/projects
git add <slug>/TASKS.md <slug>/status.json
git commit -m "docs: add tasks for <slug>"
```

## Print confirmation

```
✅ Tasks saved to ~/Code/chris/projects/<slug>/TASKS.md
   Repos: <repo-list>
   Branch chris/<slug> ready in each repo.

Next step: /wf-build
  Spawn an agent to work on the first task.
```
