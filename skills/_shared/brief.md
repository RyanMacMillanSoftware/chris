# Agent Brief Assembly

Assemble the agent brief using these section budgets. Keeping each section bounded prevents context bloat as projects grow.

## AGENTS.md excerpt — max 10 lines

Include: repo identity (name, purpose, stack) and key conventions. Skip Key Files and boilerplate.

## CONTEXT.md excerpt — max 5 lines

Include: current sprint state only (Current Focus and any active Open Questions). Skip "Recent Decisions" unless directly relevant to the task.

## Bead context — full

Run `bd show <bead_id>` and include the full output: title, description, design, acceptance criteria, and notes. If the bead has notes from a prior session, include them as prior context.

The design field contains the relevant spec excerpt for this bead. The acceptance field contains the verifiable completion criteria.

## Standards — max 3 files

Delegate to `/inject-standards` with keywords from the bead description and target rig. Use the output directly; do not re-implement the matching logic here.

If `/inject-standards` is unavailable or AgentOS is not configured, skip silently and print:
```
Tip: configure AgentOS path with /wf-init to enable standards injection.
```

## Prior bead notes — max 5 lines

If the bead has an immediate dependency (via `bd dep`), run `bd show <dep_bead_id>` and include only the notes field. This contains decisions, open questions, and confidence from the prior polecat session.

Omit all other fields from dependency beads.

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
