---
description: "Spawn a writing agent to draft content for a writing-type project task."
---

# /wf-write

Spawn a writing agent to produce a markdown draft for the current task in a writing-type project. No git, no worktrees, no branch setup. Output goes directly to the project store.

Invoked by `wf-build` when `project_type == "writing"`.

## Load context

Read the following files for the target project (`<slug>`):

- `~/Code/chris/projects/<slug>/PRD.md` — project goals and overview
- `~/Code/chris/projects/<slug>/SPEC.md` — writing outline and structure (the agent follows this)
- `~/Code/chris/projects/<slug>/TASKS.md` — current task block (title, description, deliverable)
- `~/Code/chris/projects/<slug>/status.json` — slug, stage, active agents

Identify the current task: first unchecked `- [ ] TASK-NNN` in TASKS.md.

## Assemble agent brief

Construct the following brief for the writing agent:

```
You are working on project '<slug>', task <TASK-NNN>: <title>.
Working directory: ~/Code/chris/projects/<slug>/

## Project context

<PRD overview paragraph — one short paragraph summarizing the project goal>

## Task

<Full task block from TASKS.md, including description and deliverable>

## Writing instructions

- Write in markdown only. Do not produce any code, scripts, or technical implementation.
- Follow the outline in SPEC.md exactly. Cover every section and heading listed there.
- Output a single markdown file named after the task title (lowercase, hyphenated, .md extension).
  Example: for "TASK-003: Introduction Section" → `introduction-section.md`
- Save the file to: ~/Code/chris/projects/<slug>/
- Do not create subdirectories. Do not write to any other location.
- Match the tone and audience described in the PRD.

## Acceptance criterion

draft covers all outline points and has been author-reviewed

There is no test-pass criterion for writing tasks.

## Handoff instructions (section E)

When done with this task:
1. Mark the task [x] in ~/Code/chris/projects/<slug>/TASKS.md — change `- [ ] <TASK-NNN>` to `- [x] <TASK-NNN>`
2. Generate handoff file at ~/Code/chris/projects/<slug>/handoffs/<TASK-NNN>.json with the following fields:
   - task: "<TASK-NNN>"
   - title: "<task title>"
   - completed_at: "<ISO8601 timestamp>"
   - output_file: "<filename>.md"
   - confidence: "high" | "medium" | "low"
   - open_questions: [] or list of strings
   - notes: brief summary of what was written
3. Report: "Build complete: <slug> <TASK-NNN> done"
```

## Acceptance criterion

The acceptance criterion for all writing tasks is:

> draft covers all outline points and has been author-reviewed

There is no test-pass criterion. Do not include any test or CI gate in the brief.

## Obsidian integration (passthrough)

Include these instructions in the writer agent brief:

"Every draft file you write must start with YAML frontmatter (project, type: draft, tags, aliases, created, updated). After the title heading, include: `> **Hub:** [[{slug}/{slug}-index|{project_name}]]`. After writing a draft, append a wikilink to the project's `{slug}-index.md` Drafts section: `- [[{slug}/drafts/{filename}|{title}]]`"

## Spawn agent

Spawn a subagent (Task tool) with the assembled brief above.

Working directory for the subagent: `~/Code/chris/projects/<slug>/`

Do not set up a git worktree. Do not check out a branch. Do not run any git commands.

## Update status.json

Set `stage` to `"build"`. Add `{"task": "<TASK-NNN>", "started_at": "<ISO8601>"}` to `active_agents`. Update `updated`.

## Print confirmation

```
Writing agent started: <slug> — <TASK-NNN>: <title>
Output: ~/Code/chris/projects/<slug>/
```
