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

## Write guards

Before proceeding to any file write operation:

- **Single match, no slug argument:** If `$ARGUMENTS` was not provided and exactly one project was detected from cwd, confirm with the user before proceeding:
  ```
  Writing tasks for '<slug>'. Confirm? (y/n)
  ```
  If the user answers `n`, abort and stop.

- **Slug mismatch:** If a slug was provided in `$ARGUMENTS` but it does not match the cwd-detected project, hard block and stop:
  ```
  ❌ Slug mismatch: argument is '<arg-slug>' but cwd matches '<detected-slug>'. Check your working directory.
  ```

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

**Parallel tagging `[P]`:**
- Tag a task `[P]` inline on its title line if it is safe to run concurrently with other `[P]`-tagged tasks whose deps are also met.
- A task is safe to parallelize when it does not write to files that overlap with sibling `[P]` tasks in the same ready batch, and its outputs are not consumed by those sibling tasks.
- Example: `- [ ] TASK-005: Update readme [P]`
- Add the header note `> Tasks marked \`[P]\` can run in parallel if their deps are met.` to the generated TASKS.md, immediately after the title/status block and before the first Phase heading.

As you write tasks, note which repos each one touches.

## Lint the tasks

After generating all tasks and before asking the user to confirm repos, run these validation checks:

1. **No duplicate task IDs** — every TASK-NNN appears exactly once.
2. **Valid dep references** — all `Deps:` values are either `"none"` or reference a TASK-NNN that exists in the same file.
3. **No self-references** — no task lists itself as a dep.
4. **No circular dependencies** — perform a basic cycle check (e.g. A→B→A).

Print results inline:
- If all checks pass: `✅ Lint passed`
- If any check fails: list each error as `❌ <description>` (e.g. `❌ TASK-003 lists dep TASK-007 which does not exist`)

If any errors are found, **block the save** and ask the user to correct them before continuing.

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
git -C ~/Code/chris/projects add <slug>/TASKS.md <slug>/status.json && git -C ~/Code/chris/projects commit -m "docs: add tasks for <slug>"
```

## Print confirmation

```
✅ Tasks saved to ~/Code/chris/projects/<slug>/TASKS.md
   Repos: <repo-list>
   Branch chris/<slug> ready in each repo.

Next step: /wf-build
  Spawn an agent to work on the first task.
```
