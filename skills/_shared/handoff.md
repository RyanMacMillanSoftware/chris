# Handoff Generation

When a builder agent completes a task, generate `~/Code/chris/projects/<slug>/handoffs/TASK-NNN.json`.

## Git-scaffolded fields

Tooling fills these — do not ask the agent to recall them:

```bash
# files_changed: files modified since branching from main
git diff --name-only $(git merge-base main HEAD)

# completed_at: current UTC timestamp
date -u +"%Y-%m-%dT%H:%M:%SZ"

# task: the TASK-NNN ID from TASKS.md
```

## Agent-written fields

The agent fills only these fields:
- `decisions_made` — key decisions made during this task
- `open_questions` — unresolved issues to flag for the reviewer or next agent
- `confidence` — `"high"` | `"medium"` | `"low"` — self-assessment of acceptance criteria coverage
- `agent_notes` — any context the next agent or reviewer needs
- `test_status` — `"passed"` | `"failed"` | `"skipped"` | `"no-tests"`

## Full schema

```json
{
  "task": "<TASK-NNN>",
  "slug": "<project-slug>",
  "completed_at": "<UTC timestamp from tooling>",
  "files_changed": ["<from git diff --name-only>"],
  "decisions_made": ["<agent fills>"],
  "open_questions": ["<agent fills>"],
  "confidence": "<agent fills: high|medium|low>",
  "test_status": "<agent fills: passed|failed|skipped|no-tests>",
  "agent_notes": "<agent fills>"
}
```

Create the `handoffs/` directory if it does not exist. Commit the handoff file alongside TASKS.md and any source changes.
