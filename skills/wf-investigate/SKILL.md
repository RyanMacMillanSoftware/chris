---
description: "Run the next investigation step for an investigation-type project."
---

# /wf-investigate

Build wrapper for investigation-type projects. Identifies the next unfinished investigation step, spawns an investigator agent, and tracks progress.

`$ARGUMENTS` — optional project slug

## Detect the current project

1. If `$ARGUMENTS` is provided, use that slug. Check the project directory exists (resolved per `skills/_shared/paths.md`).
2. Else scan all project `status.json` files for projects with `project_type == "investigation"` and stage `"plan"` or `"build"`. If one match, use it. If multiple, ask.
3. If none found, suggest running `/wf-new` first.

## Validate type

Read `project_type` from `status.json`. If it is not `"investigation"`:
```
❌ Project '<slug>' is type '<type>', not investigation. Use /wf-build instead.
```
Stop.

## Read the plan

Read `PLAN.md` from the project directory. Extract:
- **Hypothesis** — the working hypothesis to test
- **Data Sources** — where evidence will be gathered
- **Investigation Steps** — the ordered steps to follow

## Track progress

Scan `<project_dir>/research/` for completed step output files. Match filenames against the investigation step IDs (kebab-case of step descriptions).

- If all steps have output files → print:
  ```
  ✅ All investigation steps complete for '<slug>'. Run /wf-review <slug>.
  ```
  Stop.

- Otherwise, identify the next unfinished step.

## Spawn investigator agent

Spawn a subagent referencing `agents/investigator.md` with:

```
You are working on project '<slug>', investigation step: <step-id>.
Working directory: <project_dir>/research/

## Project context
<Hypothesis from PLAN.md>

## Data Sources
<Data sources list from PLAN.md>

## Current Step
<Full step description from PLAN.md>

## Prior steps
<List of completed steps with their key findings (from research/*.md summaries)>

## Instructions
- Follow the Orient → Query → Correlate → Document methodology
- Write findings to: <project_dir>/research/<step-id>.md
- Write handoff to: <project_dir>/handoffs/<step-id>.json
- Do not set up git worktrees, branches, or make git commits
- If this is the last step, also write research/summary.md
```

## Update status

Set `status.json.stage` to `"build"` if not already. Update `updated` timestamp. Add agent to `active_agents`.

## Print confirmation

```
🟢 Investigation started: <slug> — Step: <step-id>
   Working in: <project_dir>/research/
   Hypothesis: <hypothesis summary>
```
