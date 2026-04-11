# Preflight

Run these checks before proceeding. Stop on any failure.

1. **Read project type:** Read `project_type` from `status.json`. Default to `"code"` if absent.

2. **Stage check:**

   For `code` projects: Verify `status.json.stage` is `"tasks"` or `"build"`. If not:
   ```
   ❌ Stage is '<stage>'. Run /wf-tasks first.
   ```
   Stop.

   For non-code projects (`research`, `investigation`, `writing`, `communication`, `program`): Verify `status.json.stage` is `"plan"` or `"build"`. If not:
   ```
   ❌ Stage is '<stage>'. Run /wf-plan first.
   ```
   Stop.

3. **Required files and convoy check:**

   For `code` projects: Verify these files exist in the project folder:
   - `<project_dir>/PRD.md`
   - `<project_dir>/SPEC.md`

   AND verify `status.json.convoy_id` is non-null. If convoy_id is null:
   ```
   ❌ No convoy found. Run /wf-tasks to create beads and a convoy.
   ```
   Stop.

   For non-code projects: Verify this file exists:
   - `<project_dir>/PLAN.md`

   List any missing files and stop if any are absent.

3b. **bd version check (code projects only):**

   Run `bd version` and parse the version string. Compare against `status.json.tested_bd_version`.

   If different:
   ```
   ⚠️ bd version changed (<tested_version> → <current_version>). Beads may behave differently.
   ```
   Warn only — do not block.

3c. **Gastown check (code projects only):**

   Check if the Gastown daemon is running: `gt status` or check for PID file at `~/gt/daemon/daemon.pid`.

   If not running:
   ```
   ⚠️ Gastown is not running. Start with `gt up` before dispatching.
   ```
   Warn only — do not block.

4. **Branch check (code projects only):** Verify the current git branch in each repo equals `status.json.branch`. If there is a mismatch:
   ```
   ❌ Wrong branch. Run: git checkout <expected-branch>
   ```
   Stop.

   Non-code projects skip this check (they don't use git branches).
