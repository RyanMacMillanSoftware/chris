---
description: "Dispatch beads to Gastown for execution. Check convoy progress."
---

# /wf-build

Dispatch project beads to Gastown for execution via convoy stage and launch. On subsequent calls, check convoy progress.

`$ARGUMENTS` — optional: `<project-slug>`, `<project-slug> --local`, `<project-slug> --sequential`

**Flags:**
- `--local` — Print convoy status and bead details instead of dispatching.
- `--sequential` — Not applicable for bead-native builds (Gastown manages wave dispatch). Accepted but ignored for backwards compatibility.

## Determine the target project

If `$ARGUMENTS` provides a slug, use it. Otherwise scan `~/Code/chris/projects/*/status.json` for projects whose `repos` contains the cwd repo and `stage` is `"tasks"` or `"build"` — use the single match, or ask if multiple. If no cwd match either, list all `tasks`/`build` projects and ask.

## Stage preflight

Follow the procedure in `skills/_shared/preflight.md`. Stop on any failure before proceeding.

Read `project_type` from `status.json`. Default to `"code"` if the field is absent.

**Branch gate — writing projects:** If `project_type == "writing"`, delegate immediately to the wf-write skill. Follow all instructions in `skills/wf-write/SKILL.md` starting from "Load context." Do not proceed past this point.

**Branch gate — investigation projects:** If `project_type == "investigation"`, delegate immediately to the wf-investigate skill. Follow all instructions in `skills/wf-investigate/SKILL.md` starting from "Read the plan." Do not proceed past this point.

**Branch gate — communication projects:** If `project_type == "communication"`, delegate immediately to the wf-communicate skill. Follow all instructions in `skills/wf-communicate/SKILL.md` starting from "Read the plan." Do not proceed past this point.

**Branch gate — program projects:** If `project_type == "program"`, skip to the [Program path] section below. Do not proceed with the standard task flow.

## Check convoy state

Read `convoy_id` from `status.json`. Run:

```bash
gt convoy status <convoy_id>
```

Parse the convoy state:

- **Convoy is `staged` or `launched` with in-progress beads:**
  Print a status summary showing beads in-progress and beads queued.
  ```
  🟢 Gastown is working on '<slug>'.
     Convoy: <convoy_id>
     In progress: <bead-list>
     Queued: <N> beads remaining

  Gastown manages dispatch. Run /wf-status to check progress.
  Run /wf-review when all beads are complete.
  ```
  Stop. No further action needed.

- **Convoy is `new` (not yet staged):**
  Proceed to "Stage and launch convoy" below.

- **Some beads failed or stalled:**
  List each failed/blocked bead and prompt:
  ```
  ⚠️ Failed beads detected:
     <bead_id> TASK-NNN: <title> — <status/reason>

  For each failed bead:
    (r) Retry — re-sling the same bead to a fresh polecat
    (e) Edit and replace — close this bead and create a revised replacement
    (s) Skip — leave it and continue with other beads

  Choice for <bead_id>? (r/e/s)
  ```

  **On retry:** `gt sling <bead_id> <rig>` — dispatches a fresh polecat. The new polecat gets the bead's design field + any notes from the failed attempt.

  **On edit and replace:**
  1. Close the failed bead: `bd update <bead_id> --status closed --close-reason "approach failed, replacing"`
  2. Ask user what to change in the description/approach
  3. Create a new bead with revised description, wire it into the same dependency position (`bd dep add`/`bd dep rm`)
  4. Add to convoy: `gt convoy add <convoy_id> <new_bead_id>`
  5. Update `bead_mapping` in status.json

  **On skip:** Leave the bead as-is. Downstream beads will remain blocked.

- **All beads closed (convoy complete):**
  ```
  ✅ All beads complete for '<slug>'.
     Convoy: <convoy_id>

  Run /wf-review to review the work.
  ```
  Stop.

## --local flag

If `--local` is set:
1. Print convoy status (same as above)
2. Print details for each ready bead: `bd show <bead_id>` for all beads returned by `bd ready`
3. Print: "To dispatch manually: `gt sling <bead_id> <rig>`"
4. Stop. Do not stage or launch.

## Stage and launch convoy

### Stage

```bash
gt convoy stage <convoy_id>
```

This analyzes dependencies and computes execution waves. Print the wave plan:

```
📋 Wave plan for '<slug>':
   Wave 1: <bead-list> (<N> beads)
   Wave 2: <bead-list> (<N> beads)
   Wave 3: <bead-list> (<N> beads)
   ...
```

### Confirm launch

Show the wave plan to the user:
```
Ready to launch Wave 1? This will spawn polecats in Gastown. (y/n)
```

If no, print "Launch cancelled. Run `/wf-build` again when ready." and stop.

### Launch

```bash
gt convoy launch <convoy_id>
```

Gastown dispatches Wave 1 beads to their target rigs, spawning polecats. Subsequent waves are dispatched automatically as dependencies are resolved.

## Update status.json

Set `stage` to `"build"`. Clear `active_agents` (Gastown manages agents now). Update `updated` timestamp.

Commit:
```bash
git -C ~/Code/chris/projects add <slug>/status.json && git -C ~/Code/chris/projects commit -m "chore: start build for <slug>"
```

## Print confirmation

```
🟢 Build launched: <slug>
   Convoy: <convoy_id>
   Wave 1 dispatched: <bead-list>
   Remaining waves: <N>

Gastown manages execution from here.
Run /wf-build again to check progress, or /wf-status for overview.
Run /wf-review when all beads are complete.
```

---

## Research path

_Entered when `project_type == "research"` after preflight._

Research projects do not use beads. Follow the legacy flow:

1. Read TASKS.md. Find the first unchecked `- [ ] TASK-NNN`. If all checked, print `✅ All tasks complete for '<slug>'. Run /wf-review.` and stop.

2. Spawn a subagent with the research brief:
   ```
   You are working on project '<slug>', task <TASK-NNN>: <title>.
   Working directory: ~/Code/chris/projects/<slug>/research/

   ## Project context
   <PRD overview paragraph>

   ## Task
   <Full task block from TASKS.md, including Question: and Deliverable: fields>

   ## Research instructions
   - Research the question using primary sources, peer-reviewed publications, and official documentation.
   - Synthesize findings into a clear, well-structured markdown document.
   - Cite every source as a markdown link: [Title](url) — accessed <YYYY-MM-DD>
   - Save output to: ~/Code/chris/projects/<slug>/research/<task-title-slugified>.md
   - Do not write code. Research and prose only.
   - Do not set up git worktrees or branches.

   ## When done
   1. Mark the task [x] in TASKS.md
   2. Report: "Build complete: <slug> <TASK-NNN> done"
   ```

3. Update status.json: set stage to `"build"`, add to `active_agents`, update timestamp. Commit.

4. Print:
   ```
   🟢 Build started: <slug> — TASK-NNN: <title>
      Working in: ~/Code/chris/projects/<slug>/research/
   ```

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
