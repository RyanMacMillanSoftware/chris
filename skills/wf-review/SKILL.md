---
description: "Review work against spec and tasks. On pass: push branch and open draft PR."
---

# /wf-review

Review the current state of the project branch against the spec and task acceptance criteria. On pass, push and open a draft PR. On fail, report what needs fixing.

`$ARGUMENTS` — optional: `<project-slug>` or `<project-slug> --no-critic`

**Flags:**
- `--no-critic` — Skip the critic sub-agent pre-review entirely.

## Detect the current project

Same detection logic as other wf-* skills. Require stage `"build"` or `"tasks"`.

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

## Consume handoff files

Read all files matching `~/Code/chris/projects/<slug>/handoffs/*.json`.

For each handoff file found:
- Collect any `open_questions` entries.
- Note the `confidence` level.
- Note the `test_status`.
- Pass all handoff contents to the critic brief (see next section).

## Assemble critic brief

Assemble the critic brief following `skills/_shared/brief.md` (AGENTS.md excerpt, CONTEXT.md excerpt, completed task blocks, standards via `/inject-standards`). Pass all handoff contents from the previous step as the prior handoff section.

## Critic agent pre-review

Skip this section entirely if `--no-critic` flag is set.

Spawn a synchronous critic sub-agent (using the Task tool, in-session) with:
- The full diff gathered above
- Task acceptance criteria from TASKS.md (all completed tasks)
- All handoff JSON contents from `~/Code/chris/projects/<slug>/handoffs/*.json`
- Injected AgentOS standards (see above)

Sub-agent instruction: "Review this diff. For each completed task: does the diff satisfy the acceptance criteria? Note any standards violations. Produce a structured verdict."

Display the critic output labeled "Agent Pre-Review" **above** the human review report, using this exact format:
```
## Agent Pre-Review

- [x] TASK-001 — ✅ Auth module matches acceptance criteria.
- [x] TASK-002 — ✅ Tests pass. ⚠️ Missing test for expired token (open question in handoff).
- [ ] TASK-003 — ❌ No changelog update found in diff.

Open questions from handoffs:
- TASK-002: Should token refresh be automatic? (confidence: medium)

**Verdict:** PASS WITH NOTES
```

The critic verdict is advisory — it does not block the review from proceeding.

## Review against spec and tasks

Read `~/Code/chris/projects/<slug>/SPEC.md` and `TASKS.md` in full.

Evaluate the diff against each criterion:

**Per task (from TASKS.md):**
- Is the task checkbox marked `[x]`?
- Does the diff show changes that satisfy the acceptance criteria?
- Cite specific evidence from the diff for each task (file names and line ranges if possible).
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

### Tasks
- [x] TASK-001: title — ✅ Complete
  Evidence: src/auth/jwt.ts (lines 45–89), tests/auth/jwt.test.ts (12 test cases)
- [x] TASK-002: title — ✅ Complete
  Evidence: src/models/user.ts (lines 12–34)
- [ ] TASK-003: title — ❌ Not done / acceptance criteria not met
  ⚠️ Unverified — no specific evidence found in diff

Note: distinguish file-exists parity (file is present in the diff) from test-passes parity
(tests are present and verifiably correct) in report language.

### Handoff Notes
Tasks with open questions or lower confidence that deserve closer scrutiny:
- TASK-002 (confidence: medium): Should token refresh be automatic?
- TASK-004 (confidence: low): Performance under load not yet verified.

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

## On PASS

Push each repo's branch:
```bash
git -C <worktree-or-repo-path> push origin chris/<slug>
```

Get `default_branch` from `~/Code/<repo>/AGENTS.md` front matter (default: `main`).

Open a draft PR using the gh CLI:
```bash
gh pr create \
  --repo <github-org>/<repo> \
  --head chris/<slug> \
  --base <default_branch> \
  --title "<slug>: <one-line summary from PRD overview>" \
  --body "<generated PR body>" \
  --draft
```

**Generated PR body** should include:
- Link to `~/Code/chris/projects/<slug>/PRD.md` relative path
- Summary of what was built (from PRD overview + goals)
- List of completed tasks
- Any known issues or deferred items from the review

Record the PR URL in `status.json` as `pr_url`.
Update `stage` to `"review"`.
Commit:
```bash
cd ~/Code/chris/projects
git add <slug>/status.json
git commit -m "chore: review passed for <slug>, PR opened"
```

Print:
```
✅ Review passed.
   Draft PR opened: <pr_url>

Promote to ready when satisfied:
  gh pr ready <pr_number>

After merge, run /wf-done to clean up and generate release artifacts.
```

## On FAIL

Do not push. Do not open a PR.
Print:
```
❌ Review failed. Issues to resolve:

[List of specific failures from the report]

Run /wf-build to continue working on the project.
```
