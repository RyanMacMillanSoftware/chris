---
description: "Break the spec into beads. Create convoy. Generate TASKS.md view."
---

# /wf-tasks

Break the project spec into ordered, testable beads in Gastown. Wire dependencies. Create a convoy. Generate a read-only TASKS.md for Obsidian review.

`$ARGUMENTS` — optional: `<project-slug>` or `<project-slug> --refresh`

**Flags:**
- `--refresh` — Regenerate TASKS.md from current bead state (for when beads have been updated via `bd update`).

## Detect the current project

Same detection logic as other wf-* skills. Require stage `"spec"` — if not, print:
```
❌ Project '<slug>' is at stage '<stage>', not spec. Run /wf-spec first.
```
If stage is already `"tasks"` and `--refresh` is not set, offer: "Project already has tasks. Run with `--refresh` to regenerate TASKS.md from current bead state, or proceed to overwrite? (refresh/overwrite/cancel)"

Read `~/Code/chris/projects/<slug>/SPEC.md` in full.
Read `~/Code/chris/projects/<slug>/PRD.md` in full.
Read `project_type` from `~/Code/chris/projects/<slug>/status.json`; default to `"code"` if the field is absent.

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

## --refresh mode

If `--refresh` is set and stage is `"tasks"`:

1. Read `bead_mapping` from `status.json`.
2. For each TASK-NNN in the mapping, run `bd show <bead_id>` to get current state.
3. Regenerate TASKS.md from current bead state using the generated format (see "Generate TASKS.md" section below).
4. Write TASKS.md, commit, and print: `✅ TASKS.md regenerated from bead state.`
5. Stop. Do not re-create beads.

## Non-code project path

If `project_type` is not `"code"` (`research`, `investigation`, `writing`, `communication`, `program`):

Use the legacy task generation flow — break the spec/plan into tasks written directly to TASKS.md without beads. Use the task template variant matching the project type:

**`"writing"`** — `Deliverable:` replaces `Accepts:`:
```markdown
- [ ] TASK-NNN: Short descriptive title
  **Repos:** repo-name
  **Deps:** TASK-NNN or "none"

  Description.

  **Deliverable:** A specific, reviewable output.
```

**`"research"`** — `Question:` + `Deliverable:`:
```markdown
- [ ] TASK-NNN: Short descriptive title
  **Repos:** repo-name
  **Deps:** TASK-NNN or "none"

  Description.

  **Question:** The specific question this task must answer.
  **Deliverable:** A specific, verifiable output.
```

Follow the same lint, repo confirmation, branch setup, Obsidian integration, and save/commit flow as the code path (but skip bead creation, rig mapping, convoy creation, and `--refresh` mode). Then stop.

## Map repos to rigs

For each repo mentioned in the spec, ask the user to confirm the Gastown rig name and prefix:

```
Repos detected from spec: <repo-list>
Map each repo to a Gastown rig:

  <repo-name> → rig: <rig_name>, prefix: <prefix>

Confirm? (y/n)
```

Store this mapping for use during bead creation.

## Decompose spec into beads

Read SPEC.md and break it into phases, components, and work items. For each work item, apply quality structure:

### Quality structure rules

1. **Test-first:** If a work item has testable behaviour, create two beads:
   - A `test-stub` bead: writes failing tests. Acceptance: "Tests exist and fail."
   - An `impl` bead: implements the code. Depends on the test-stub. Acceptance: "All tests from [test-stub bead] pass."

2. **Scaffolding:** Infrastructure tasks (repo setup, Docker Compose, observability setup) get a single `scaffold` bead. No test-stub pair needed.

3. **Observability:** If the spec mentions observability requirements for a component, include them in the bead description: "Add structured logging and OTel spans for [component]."

4. **Implementation hints:** For beads where the implementation approach is non-obvious, add hints to the `--design-file` content alongside the spec excerpt.

5. **One bead = one commit:** Each bead should produce exactly one atomic commit.

### Bead creation

For each bead, run:

```bash
bd create "<title>" \
  --prefix <rig-prefix> \
  --description "<full description with steps>" \
  --acceptance "<specific, verifiable criteria>" \
  --design-file <temp-file-with-spec-excerpt-and-hints> \
  --spec-id "<slug>/SPEC" \
  --context "PRD: ~/Code/chris/projects/<slug>/PRD.md | SPEC: ~/Code/chris/projects/<slug>/SPEC.md" \
  --metadata '{"chris_task":"TASK-NNN","chris_project":"<slug>","phase":"N","type":"<scaffold|test-stub|impl|gate>"}' \
  -p <priority>
```

Capture the returned bead ID for each creation.

Create parent beads for phases/features, child beads (using hierarchical IDs) for each atomic work unit.

### Phase gates

At the end of each phase, create a `gate` bead:
- Depends on all beads in that phase
- Acceptance: "All tests pass, integration verified"
- The first bead of the next phase depends on this gate

### Wire dependencies

For all dependency relationships:
```bash
bd dep add <child-bead-id> <parent-bead-id>
```

## Create convoy

After all beads are created and wired:

```bash
gt convoy create --title "chris/<slug>" <space-separated-bead-ids>
```

Capture the convoy ID.

## Generate TASKS.md

Render the created beads into a read-only markdown view using the template format:

```markdown
---
project: <project-name>
type: tasks
tags:
  - project/<slug>
  - type/tasks
  - stage/tasks
aliases:
  - <project-name> Task List
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
---

# Tasks: <project-name>

> **Hub:** [[<slug>/<slug>-index|<project-name>]] | **PRD:** [[<slug>/PRD]] | **Spec:** [[<slug>/SPEC]]

> ⚠️ **Generated file.** Beads are the source of truth. Edit via `bd update <id>` then run `/wf-tasks --refresh`.

## Phase N — <Phase Name>

### TASK-NNN: <title> `[<bead-id>]`
- **Rig:** <rig-name> (`<prefix>`)
- **Deps:** <dep-list-with-bead-ids> or none
- **Type:** <scaffold|test-stub|impl|gate>
- **Accepts:** <acceptance criteria>

<description>

---

### TASK-V0N: Phase N validation checkpoint `[<gate-bead-id>]`
- **Rig:** hq
- **Deps:** <all-phase-beads>
- **Type:** gate
- **Accepts:** All tests pass, integration verified.
```

Include bead IDs inline after each task title and in dep references.

## Present for review

Show the generated TASKS.md to the user. Ask: "Does this breakdown look right? Any tasks to add, remove, or modify?"

Wait for explicit approval before saving.

### Handle edits

If the user requests changes:
1. Run `bd update <bead_id> --description "..." --acceptance "..."` for content changes
2. Run `bd dep add <child> <parent>` or `bd dep rm <child> <parent>` for dependency changes
3. Create new beads if tasks need to be added; add them to the convoy: `gt convoy add <convoy_id> <new-bead-ids>`
4. Regenerate TASKS.md from current bead state
5. Present again for review
6. Repeat until approved

## Lint the beads

After generating all beads and before final save:

1. **No duplicate bead mappings** — every TASK-NNN maps to a unique bead ID.
2. **Valid dep references** — all dependencies reference existing beads.
3. **No self-references** — no bead depends on itself.
4. **No circular dependencies** — perform a basic cycle check.

Print results inline:
- If all checks pass: `✅ Lint passed`
- If any check fails: list each error as `❌ <description>`

If any errors are found, **block the save** and fix before continuing.

## Confirm repos

Compile the full list of repos involved (deduplicated from rig mapping).

Show the user: "This project will touch the following repos: [list]. Is that correct?"

Wait for confirmation.

## Set up branches

For each confirmed repo:

1. Check if `~/Code/<repo>/` exists. If not, warn and ask how to proceed.

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

3. Check for other chris/* branches on the repo. If multiple exist, note the potential for worktree use during build.

## Obsidian integration

When writing TASKS.md, include YAML frontmatter as shown in the generated format above.

After writing TASKS.md, update the project's `<slug>-index.md`:
1. In the Artifacts table, change the TASKS row status from `—` to `✅`
2. Update the hub's `updated` frontmatter field to the current date
3. Update the hub's `stage/` tag to `stage/tasks`

## Save and commit

Write `~/Code/chris/projects/<slug>/TASKS.md`.

Update `status.json`:
- `stage`: `"tasks"`
- `repos`: the confirmed repo list
- `branch`: `"chris/<slug>"`
- `convoy_id`: the convoy ID from creation
- `bead_mapping`: the full TASK-NNN → `{bead_id, rig, prefix}` mapping
- `tested_bd_version`: output of `bd version`
- `updated`: current timestamp

Commit:
```bash
git -C ~/Code/chris/projects add <slug>/TASKS.md <slug>/status.json && git -C ~/Code/chris/projects commit -m "docs: add tasks for <slug>"
```

## Print confirmation

```
✅ Tasks saved to ~/Code/chris/projects/<slug>/TASKS.md
   Repos: <repo-list>
   Convoy: <convoy_id> — <N> beads created
   Branch chris/<slug> ready in each repo.

Next step: /wf-build
  Dispatch beads to Gastown for execution.
```
