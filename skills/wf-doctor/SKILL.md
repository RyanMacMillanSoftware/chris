---
description: "Run a health check on all Chris projects. Optionally auto-fix issues with --fix."
---

# /wf-doctor

Scan all Chris projects for health issues: missing fields, broken links, stale stages, missing docs. Optionally auto-fix what can be repaired.

`$ARGUMENTS` — optional: `<project-slug>` to scan a single project, `--fix` to auto-repair fixable issues.

Parse `$ARGUMENTS`:
- If it contains `--fix`, set FIX_MODE=true
- Any non-flag word is the TARGET_SLUG (scan only that project)

## Phase 1: Scan

### Collect projects

If TARGET_SLUG is set:
```bash
ls ~/Code/chris/projects/$TARGET_SLUG/status.json
```
If not found, print `❌ Project not found: $TARGET_SLUG` and stop.

Otherwise, scan all projects:
```bash
ls ~/Code/chris/projects/*/status.json
```

For each `status.json`, read it and run all checks below. Collect results as a list of `{project, check, severity, message, fixable, fix_description}`.

### Check 1: schema-fields (error, fixable)

Compare fields in `status.json` against the canonical schema:

| Field | Default |
|-------|---------|
| `project` | *(no default — must exist)* |
| `slug` | *(no default — must exist)* |
| `stage` | `"new"` |
| `project_type` | `"code"` |
| `repos` | `[]` |
| `branch` | `"chris/<slug>"` |
| `worktrees` | `{}` |
| `active_agents` | `[]` |
| `conflicts` | `[]` |
| `pr_url` | `null` |
| `tags` | `[]` |
| `children` | `[]` |
| `convoy_id` | `null` |
| `bead_mapping` | `{}` |
| `tested_bd_version` | `null` |
| `created` | *(no default — must exist)* |
| `updated` | *(no default — must exist)* |
| `closed_at` | `null` |

For each field not present in the JSON, report:
- severity: error
- message: `Missing fields in status.json: <comma-separated list>`
- fixable: true
- fix_description: `Add missing fields with defaults`

**Fix logic:** For each missing field, add it with the default value from the table. Write the updated JSON back (pretty-printed, 2-space indent). Do NOT remove extra fields.

### Check 2: valid-stage (error, not fixable)

Validate that `stage` is a valid value for the project's `project_type`:

| Type | Valid Stages |
|------|-------------|
| `code` | new, prd, prd-research, spec, spec-research, tasks, build, review, done |
| `research` | new, plan, build, review, done |
| `investigation` | new, plan, build, review, done |
| `writing` | new, plan, build, review, done |
| `communication` | new, plan, build, review, done |
| `program` | new, plan, build, review, done |

If invalid:
- severity: error
- message: `Invalid stage '<stage>' for project type '<type>'`
- fixable: false

### Check 3: branch-format (warning, fixable)

Check that `branch` is not empty and matches `chris/<slug>`.

If empty string or missing:
- severity: warning
- message: `Empty branch field`
- fixable: true
- fix_description: `Set branch to 'chris/<slug>'`

**Skip this check** if the project's stage is `done` (done projects don't need active branches).

**Fix logic:** Set `branch` to `"chris/<slug>"` where slug comes from `status.json.slug`.

### Check 4: valid-project-type (error, not fixable)

Check that `project_type` is one of: `code`, `research`, `investigation`, `writing`, `communication`, `program`.

If invalid:
- severity: error
- message: `Invalid project_type: '<value>'`
- fixable: false

### Check 5: timestamps-present (warning, fixable)

Check that `created` and `updated` are non-empty strings.

If either is empty or missing:
- severity: warning
- message: `Missing timestamp: <field>`
- fixable: true
- fix_description: `Set to current date`

**Fix logic:** Set missing timestamp to today's date in ISO-8601 format (`YYYY-MM-DDT00:00:00Z`).

### Check 6: index-exists (error, fixable)

Check that `<slug>-index.md` exists in the project directory.

If missing:
- severity: error
- message: `Missing hub index file: <slug>-index.md`
- fixable: true
- fix_description: `Generate hub index from template`

**Fix logic:** Read `~/Code/chris/templates/hub-index.md`. Replace template placeholders:
- `{{ Project Name }}` → `status.json.project`
- `{{ slug }}` → `status.json.slug`
- `{{ current-stage }}` → `status.json.stage`
- `{{ project-type }}` → `status.json.project_type`
- `{{ YYYY-MM-DD }}` for created → `status.json.created` (date portion)
- `{{ YYYY-MM-DD }}` for updated → `status.json.updated` (date portion)

Write the filled template to `~/Code/chris/projects/<slug>/<slug>-index.md`.

### Check 7: index-frontmatter (warning, fixable)

If the index file exists, check it has YAML frontmatter with required fields:
- `project`, `type`, `tags` (must include `project/<slug>`), `created`, `updated`

If frontmatter is missing entirely or missing required fields:
- severity: warning
- message: `Index missing frontmatter field: <fields>`
- fixable: true
- fix_description: `Add missing frontmatter fields`

**Fix logic:** If no frontmatter block exists (no `---` delimiter at top), prepend the full frontmatter block using values from status.json. If frontmatter exists but fields are missing, add the missing fields. Set:
- `project` → `status.json.project`
- `type` → `"hub"`
- `tags` → `["project/<slug>", "type/hub", "stage/<stage>"]`
- `created` → `status.json.created` (date portion)
- `updated` → `status.json.updated` (date portion)

### Check 8: index-stage-tag (info, fixable)

If the index has frontmatter with a `tags` array, check that it includes a `stage/<current-stage>` tag matching `status.json.stage`.

If a `stage/*` tag exists but doesn't match:
- severity: info
- message: `Stage tag 'stage/<old>' doesn't match current stage '<new>'`
- fixable: true
- fix_description: `Update stage tag to 'stage/<new>'`

**Fix logic:** In the frontmatter `tags` array, replace any `stage/*` entry with `stage/<current-stage>`.

### Check 9: index-description (info, not fixable)

If the index has a description line (the line after the Stage/Type header), check it's not a template placeholder like `{{ ... }}`.

If it is a placeholder:
- severity: info
- message: `Hub description is a template placeholder`
- fixable: false

### Check 10: required-docs (warning, not fixable)

Check that required documents exist for the current stage and project type:

| Stage | Code Projects | Non-Code Projects |
|-------|---------------|-------------------|
| `new` | (none) | (none) |
| `prd` | PRD.md | -- |
| `prd-research` | (none) | -- |
| `spec` | PRD.md, SPEC.md | -- |
| `spec-research` | PRD.md | -- |
| `tasks` | PRD.md, SPEC.md, TASKS.md | -- |
| `plan` | -- | PLAN.md |
| `build` | PRD.md, SPEC.md, TASKS.md | PLAN.md |
| `review` | PRD.md, SPEC.md, TASKS.md | PLAN.md |
| `done` | PRD.md, SPEC.md, TASKS.md | PLAN.md |

For each missing required doc:
- severity: warning
- message: `Missing required document: <filename> (expected at stage '<stage>')`
- fixable: false

### Check 11: doc-frontmatter (warning, fixable)

For each existing `.md` file in the project directory (PRD.md, SPEC.md, TASKS.md, PLAN.md, REVIEW.md, and the index), check it has YAML frontmatter with: `project`, `type`, `tags` (including `project/<slug>`), `created`, `updated`.

Skip non-standard files (handoffs, session notes, research files other than PRD-RESEARCH.md and SPEC-RESEARCH.md).

Files to check: `<slug>-index.md`, `PRD.md`, `SPEC.md`, `TASKS.md`, `PLAN.md`, `REVIEW.md`, `PRD-RESEARCH.md`, `SPEC-RESEARCH.md`.

If frontmatter is missing or incomplete:
- severity: warning
- message: `<filename> missing frontmatter field: <fields>`
- fixable: true
- fix_description: `Add missing frontmatter fields`

**Fix logic:** Same as Check 7 but adapted per document:
- `type` → infer from filename: `PRD.md` → `"prd"`, `SPEC.md` → `"spec"`, `TASKS.md` → `"tasks"`, `PLAN.md` → `"plan"`, `REVIEW.md` → `"review"`, `PRD-RESEARCH.md` → `"prd-research"`, `SPEC-RESEARCH.md` → `"spec-research"`
- For `tags`, include `project/<slug>` and `type/<type>`
- For dates, use the file's existing frontmatter dates if present, otherwise use `status.json` dates

### Check 12: wiki-links (warning, not fixable)

Parse all `[[...]]` wiki-links from the index file. For each link:
- Strip display alias (text after `|`)
- Resolve path relative to `~/Code/chris/projects/`
- Check if the target file exists (add `.md` extension if needed)

For each broken link:
- severity: warning
- message: `Broken wiki-link in index: [[<link>]]`
- fixable: false

### Check 13: stale-project (warning, not fixable)

Compare `status.json.updated` to the current date. Apply staleness threshold:

| Stage | Threshold |
|-------|-----------|
| `new` | 14 days |
| `prd` | 14 days |
| `prd-research` | 14 days |
| `spec` | 14 days |
| `spec-research` | 14 days |
| `plan` | 14 days |
| `tasks` | 14 days |
| `build` | 30 days |
| `review` | 14 days |

Skip projects at stage `done`.

If days in current stage exceeds the threshold:
- severity: warning
- message: `In stage '<stage>' for <N> days (threshold: <T>)`
- fixable: false

## Phase 2: Report

Print the report header:
```
/wf-doctor — Project Health Report
```

For each project, sorted alphabetically:

If no issues:
```
✅ <slug> (<stage>) — 0 issues
```

If issues exist, show the project header with counts, then each issue indented:
```
⚠️  <slug> (<stage>) — N warnings
  ⚠️  [<check>] <message>
```

Or for errors:
```
❌ <slug> (<stage>) — N errors, M warnings
  ❌ [<check>] <message>
  ⚠️  [<check>] <message>
```

Info items use `ℹ️`:
```
  ℹ️  [<check>] <message>
```

After all projects, print summary:
```
Summary: <N> projects scanned — <E> errors, <W> warnings, <I> info
         Run /wf-doctor --fix to auto-repair <F> fixable issues.
```

If no issues at all:
```
Summary: <N> projects scanned — all clear! ✅
```

## Phase 3: Fix (only if --fix)

If FIX_MODE is false, stop here. Exit with code 1 if any errors, 0 otherwise.

If FIX_MODE is true:

Print:
```
/wf-doctor --fix — Applying fixes...
```

For each result where `fixable: true`, apply the fix logic described in the check definition. For each fix applied, print:
```
  ✅ [<check>] <slug>: <fix_description>
```

After all fixes are applied, commit all changes in the projects repo:
```bash
cd ~/Code/chris/projects && git add -A && git commit -m "chore: wf-doctor --fix auto-repairs"
```

Print summary:
```
Fixed <N> issues. <M> issues remain (not auto-fixable).
Committed changes to projects repo.
```

If no fixable issues were found:
```
No fixable issues found. Nothing to commit.
```
