---
description: "Write a Plan document for a non-code project using type-specific templates."
---

# /wf-plan

Interactively write a PLAN.md for a non-code project. Work through each section with the user, asking questions and drafting content. Collaborate section by section — don't dump a wall of text.

`$ARGUMENTS` — optional project slug

## Detect the current project

1. If `$ARGUMENTS` is provided, use that slug. Check the project directory exists (resolved per `skills/_shared/paths.md`).
2. Else if cwd is `~/Code/<repo>/` or a subdirectory, scan all project `status.json` files for entries where `repos` contains this repo name. If exactly one match, use it. If multiple, ask which one.
3. Else list all projects with stage `"new"` or `"plan"` and ask which one to work on.

If no matching project is found, suggest running `/wf-new` first.

## Stage gate

Verify `status.json.stage` is `"new"` or `"plan"`.

- If stage is `"new"`, proceed normally.
- If stage is `"plan"`, warn: `⚠️ PLAN.md already exists for '<slug>'. Re-running will overwrite it. Continue? (y/n)`. Abort on `n`.
- Any other stage: `❌ Stage is '<stage>'. This project has already advanced past planning.` Stop.

## Type gate

Read `project_type` from `status.json`.

If `project_type == "code"`:
```
❌ Code projects use /wf-prd → /wf-spec → /wf-tasks, not /wf-plan.
```
Stop.

## Write guards

Before proceeding to any file write:

- **Single match, no slug argument:** If `$ARGUMENTS` was not provided and exactly one project was detected from cwd, confirm:
  ```
  Writing PLAN for '<slug>' (<project_type>). Confirm? (y/n)
  ```
  Abort on `n`.

- **Slug mismatch:** If a slug was provided but does not match the cwd-detected project, hard block:
  ```
  ❌ Slug mismatch: argument is '<arg-slug>' but cwd matches '<detected-slug>'.
  ```

## Write the PLAN

Load `~/Code/chris/templates/PLAN-<project_type>.md`. If the type-specific template doesn't exist, fall back to `~/Code/chris/templates/PLAN.md`.

Work through each section **one at a time**. For each section:
- Ask targeted questions to understand what the user wants to express
- Draft the section content based on their answers
- Show the draft and ask for confirmation or edits before moving on
- Don't proceed to the next section until the current one is confirmed

### Sections by type

**research:** Goal, Scope, Research Questions, Methodology, Source Categories, Expected Outputs, Steps, Open Questions

**investigation:** Goal, Scope, Hypothesis, Data Sources, Investigation Steps, Metrics/Queries, Steps, Open Questions

**writing:** Goal, Scope, Audience, Format, Outline, Steps, Review Criteria, Open Questions

**communication:** Goal, Scope, Audience, Channel, Key Messages, Tone, Steps, Open Questions

**program:** Goal, Scope, Phases (child table), Timeline, Roll-up Criteria, Steps, Open Questions

## Obsidian integration

When writing PLAN.md, include YAML frontmatter from `templates/PLAN.md`. Fill in:
- `project`: from `status.json.project`
- `slug`: from `status.json.slug`
- `YYYY-MM-DD`: current date

After the `# Plan: <Project Name>` heading, include the navigation blockquote:
```
> **Hub:** [[<slug>/index|<Project Name>]]
```

After writing PLAN.md, update the project's `index.md`:
1. In the Artifacts table, change the PLAN row status from `—` to `✅`
2. Update the hub's `updated` frontmatter field to the current date
3. Update the hub's `stage/` tag to `stage/plan`

## Save and update

Once all sections are confirmed, write the PLAN to the project directory (resolved per `skills/_shared/paths.md`): `<project_dir>/PLAN.md`.

Update `<project_dir>/status.json`: set `stage` to `"plan"` and `updated` to current timestamp.

## Print confirmation

```
✅ PLAN saved to <project_dir>/PLAN.md

Next step: /wf-build <slug>
  Start working on the plan.
```
