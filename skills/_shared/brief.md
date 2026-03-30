# Agent Brief Assembly

Assemble the agent brief using these section budgets. Keeping each section bounded prevents context bloat as projects grow.

## AGENTS.md excerpt — max 10 lines

Include: repo identity (name, purpose, stack) and key conventions. Skip Key Files and boilerplate.

## CONTEXT.md excerpt — max 5 lines

Include: current sprint state only (Current Focus and any active Open Questions). Skip "Recent Decisions" unless directly relevant to the task.

## Task block — full

Include the complete task entry from TASKS.md: description, Repos, Deps, Accepts.

## Standards — max 3 files

Delegate to `/inject-standards` with keywords from the task description and task Repos field. Use the output directly; do not re-implement the matching logic here.

If `/inject-standards` is unavailable or AgentOS is not configured, skip silently and print:
```
Tip: configure AgentOS path with /wf-init to enable standards injection.
```

## Prior handoff — max 5 lines

If a handoff file exists for the immediately preceding dependency task, include only:
- `open_questions` entries
- `confidence` level

Omit `files_changed`, `decisions_made`, `agent_notes`, and `completed_at` from prior handoffs.

---

## Investigation brief assembly

For `investigation` projects, assemble the brief with these sections instead of the standard code brief:

1. **Project header** — project name, slug, type (`investigation`)
2. **PLAN.md excerpt** — Hypothesis, Data Sources, current investigation step description
3. **Prior step findings** — summary of completed step outputs from `research/*.md` (max 10 lines)
4. **Prior handoff** — `open_questions` and `confidence` from the most recent handoff (max 5 lines)

## Communication brief assembly

For `communication` projects, assemble the brief with these sections:

1. **Project header** — project name, slug, type (`communication`)
2. **PLAN.md excerpt** — Audience, Channel, Key Messages, Tone
3. **Prior draft** — if a draft already exists in `drafts/`, include its content for revision context (max 20 lines)
4. **Prior handoff** — `open_questions` and `confidence` from the most recent handoff (max 5 lines)
