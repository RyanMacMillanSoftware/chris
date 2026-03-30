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

3. **Required files check:**

   For `code` projects: Verify all three of these files exist in the project folder (resolved per `_shared/paths.md`):
   - `<project_dir>/PRD.md`
   - `<project_dir>/SPEC.md`
   - `<project_dir>/TASKS.md`

   For non-code projects: Verify this file exists:
   - `<project_dir>/PLAN.md`

   List any missing files and stop if any are absent.

4. **Branch check (code projects only):** Verify the current git branch in each repo equals `status.json.branch`. If there is a mismatch:
   ```
   ❌ Wrong branch. Run: git checkout <expected-branch>
   ```
   Stop.

   Non-code projects skip this check (they don't use git branches).
