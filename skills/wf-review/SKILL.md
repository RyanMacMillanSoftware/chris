---
description: "Review work against spec and tasks. On pass: push branch and open draft PR."
---

# /wf-review

Review the current state of the project branch against the spec and task acceptance criteria. On pass, push and open a draft PR. On fail, report what needs fixing.

`$ARGUMENTS` — optional: `<project-slug>` or `<project-slug> --no-critic`

**Flags:**
- `--no-critic` — Skip the critic sub-agent pre-review entirely.

## Detect the current project

Same detection logic as other wf-* skills.

Read `project_type` from `status.json`. Default to `"code"` if absent.

For `code` projects: require stage `"build"` or `"tasks"`.
For non-code projects: require stage `"build"` or `"plan"`.

## Gather the diff

For each repo in the project, get the full diff since branching from main.

If a worktree exists for this project+repo (check `status.json` worktrees map):
```bash
git -C ~/Code/.chris-worktrees/<slug>/<repo>/ diff $(git -C ~/Code/.chris-worktrees/<slug>/<repo>/ merge-base main chris/<slug>) chris/<slug>
```

Otherwise:
```bash
git -C ~/Code/<repo>/ diff $(git -C ~/Code/<repo>/ merge-base main chris/<slug>) chris/<slug>
```

## Consume bead context (code projects)

For code projects, read bead state instead of handoff files.

Read `convoy_id` and `bead_mapping` from `status.json`.

For each bead in `bead_mapping`:
```bash
bd show <bead_id>
```

From each bead's output, extract:
- **Notes** — contains decisions, open questions, and confidence from polecats (replaces handoff JSON)
- **Acceptance criteria** — the verifiable completion criteria
- **Status** — open, in_progress, or closed

Pass all bead context to the critic brief.

## Consume handoff files (non-code projects)

For non-code projects, read all files matching `~/Code/chris/projects/<slug>/handoffs/*.json`.

For each handoff file found:
- Collect any `open_questions` entries.
- Note the `confidence` level.
- Note the `test_status`.
- Pass all handoff contents to the critic brief.

## Assemble critic brief

For code projects: Assemble using `skills/_shared/brief.md` with bead context from above. Include AGENTS.md excerpt, CONTEXT.md excerpt, bead acceptance criteria, and bead notes.

For non-code projects: Assemble using `skills/_shared/brief.md` with handoff contents as the prior handoff section.

## Build eval gate

Before proceeding, verify that the build is complete.

### Code projects

**Check — Convoy completion:** Run:
```bash
gt convoy status <convoy_id>
```

If any beads are still open or in-progress, list them and print:
```
❌ Build eval failed — convoy not complete.
   Open beads: <bead-list>
   In progress: <bead-list>
```
Stop.

If all beads are closed, continue.

### Research / Investigation projects

**Check:** All planned questions (research) or investigation steps have output files in `<project_dir>/research/`. Compare against PLAN.md's Research Questions or Investigation Steps.

**On fail:** List missing outputs and print `❌ Build eval failed`. Stop.

### Writing projects

**Check:** All planned sections from PLAN.md's Outline have draft files in `<project_dir>/drafts/`.

**On fail:** List missing sections and print `❌ Build eval failed`. Stop.

### Communication projects

**Check:** At least one draft file exists in `<project_dir>/drafts/`.

**On fail:** Print `❌ Build eval failed — no draft found in drafts/`. Stop.

### Program projects

**Check:** All `children[]` slugs from `status.json` are at stage `"done"`.

**On fail:** List children not yet done and print `❌ Build eval failed — not all children complete`. Stop.

## Critic agent pre-review

Skip this section entirely if `--no-critic` flag is set.

Spawn a synchronous critic sub-agent (using the Task tool, in-session) with:
- The full diff gathered above
- Bead acceptance criteria (code projects) or task acceptance criteria from TASKS.md (non-code)
- Bead notes (code projects) or handoff JSON contents (non-code)
- Injected AgentOS standards (if available)

Sub-agent instruction: "Review this diff. For each completed bead/task: does the diff satisfy the acceptance criteria? Note any standards violations. Produce a structured verdict."

Display the critic output labeled "Agent Pre-Review" **above** the human review report, using this exact format:
```
## Agent Pre-Review

- [x] <bead-id> TASK-001 — ✅ Auth module matches acceptance criteria.
- [x] <bead-id> TASK-002 — ✅ Tests pass. ⚠️ Missing test for expired token (open question in notes).
- [ ] <bead-id> TASK-003 — ❌ No changelog update found in diff.

Open questions from bead notes:
- TASK-002 (<bead-id>): Should token refresh be automatic? (confidence: medium)

**Verdict:** PASS WITH NOTES
```

The critic verdict is advisory — it does not block the review from proceeding.

## Review against spec and beads

Read `~/Code/chris/projects/<slug>/SPEC.md` in full.

Evaluate the diff against each criterion:

**Per bead (code projects) / per task (non-code):**
- Is the bead closed / task checkbox marked?
- Does the diff show changes that satisfy the acceptance criteria?
- Cite specific evidence from the diff (file names and line ranges if possible).
- Are there any obvious gaps?

**Against the spec:**
- Does the implementation match the architecture described?
- Are data models correct?
- Any unexpected changes not covered by the spec or tasks?
- Any regressions (deletions or modifications to unrelated code)?

**Conflicts:**
If `status.json` has any unresolved conflicts, flag each one in the review report.

## Produce the review report

Format the report as:

```
## Review: <slug>

**Overall:** PASS / FAIL

### Agent Pre-Review
<critic agent output, if not skipped>

### Beads / Tasks
- [x] <bead-id> TASK-001: title — ✅ Complete
  Evidence: src/auth/jwt.ts (lines 45–89), tests/auth/jwt.test.ts (12 test cases)
- [x] <bead-id> TASK-002: title — ✅ Complete
  Evidence: src/models/user.ts (lines 12–34)
- [ ] <bead-id> TASK-003: title — ❌ Not done / acceptance criteria not met

### Bead Notes Summary
Tasks with open questions or lower confidence:
- TASK-002 (<bead-id>, confidence: medium): Should token refresh be automatic?
- TASK-004 (<bead-id>, confidence: low): Performance under load not yet verified.

### Spec Compliance
✅ Architecture matches spec
⚠️ Data model for X differs from spec: [detail]
❌ Component Y not implemented

### Conflicts
⚠️ api ↔ mobile-onboarding: src/auth/session.ts (unresolved — check after merge)

### Notes
[Any observations, deferred items, or recommendations]
```

Show the user the report and ask: "Does this review look accurate? Anything to adjust before proceeding?"

## Obsidian integration

When writing REVIEW.md, include YAML frontmatter from `templates/REVIEW.md`. Fill in values from `status.json` and the current date.

After the title heading, include:
```
> **Hub:** [[<slug>/<slug>-index|<Project Name>]] | **PRD:** [[<slug>/PRD]] | **Tasks:** [[<slug>/TASKS]]
```
For non-code projects, use: `> **Hub:** [[<slug>/<slug>-index|<Project Name>]] | **Plan:** [[<slug>/PLAN]] | **Tasks:** [[<slug>/TASKS]]`

After writing the file, update the project's `<slug>-index.md`:
1. In the Artifacts table, change the REVIEW row status from `—` to `✅`
2. Update the hub's `updated` frontmatter field
3. Update the hub's `stage/` tag to `stage/review`

## Review template

Load `~/Code/chris/templates/REVIEW.md` and fill in the template with the review findings. Write the completed review to `<project_dir>/REVIEW.md`.

## On PASS — code projects

Push each repo's branch:
```bash
git -C <worktree-or-repo-path> push origin chris/<slug>
```

Get `default_branch` from `~/Code/<repo>/AGENTS.md` front matter (default: `main`).

Open a draft PR using the gh CLI (single command, no line breaks):
```bash
gh pr create --repo <github-org>/<repo> --head chris/<slug> --base <default_branch> --title "<slug>: <one-line summary from PRD overview>" --body "<generated PR body>" --draft
```

**Generated PR body** should include:
- Link to `~/Code/chris/projects/<slug>/PRD.md` relative path
- Summary of what was built (from PRD overview + goals)
- List of completed beads/tasks
- Any known issues or deferred items from the review

Record the PR URL in `status.json` as `pr_url`.
Update `stage` to `"review"`.
Commit:
```bash
git -C ~/Code/chris/projects add <slug>/status.json && git -C ~/Code/chris/projects commit -m "chore: review passed for <slug>, PR opened"
```

Print:
```
✅ Review passed.
   Draft PR opened: <pr_url>

Promote to ready when satisfied:
  gh pr ready <pr_number>

After merge, run /wf-done to clean up and generate release artifacts.
```

## On PASS — non-code projects

Non-code projects do not create PRs or push branches. Instead:

1. Write `REVIEW.md` to the project directory.
2. Update `status.json`: set `stage` to `"review"`.
3. Print:
   ```
   ✅ Review complete for '<slug>'.
      REVIEW.md written to <project_dir>/REVIEW.md

   Next step: /wf-done <slug>
   ```

## On FAIL

Do not push. Do not open a PR.
Print:
```
❌ Review failed. Issues to resolve:

[List of specific failures from the report]

Run /wf-build to continue working on the project.
```
