# Preflight

Run these checks before proceeding. Stop on any failure.

1. **Stage check:** Verify `status.json.stage` is `"tasks"` or `"build"`. If not:
   ```
   ❌ Stage is '<stage>'. Run /wf-tasks first.
   ```
   Stop.

2. **Required files check:** Verify all three of these files exist in the project folder:
   - `~/Code/chris/projects/<slug>/PRD.md`
   - `~/Code/chris/projects/<slug>/SPEC.md`
   - `~/Code/chris/projects/<slug>/TASKS.md`

   List any missing files and stop if any are absent.

3. **Branch check:** Verify the current git branch in each repo equals `status.json.branch`. If there is a mismatch:
   ```
   ❌ Wrong branch. Run: git checkout <expected-branch>
   ```
   Stop.
