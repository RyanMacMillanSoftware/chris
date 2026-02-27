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
