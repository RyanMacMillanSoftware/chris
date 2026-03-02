# Chris — Workflow Manager

Chris orchestrates projects through a fixed pipeline from idea to shipped code. Each project moves down the chain of stages (new → prd → spec → tasks → build → review → done) and relies on the `/wf-*` commands for document creation, branching, and git handoffs.

Use `/wf-status` to see your projects and their stages, `/wf-new` to register a project, and `/wf-build` plus `/wf-review`/`/wf-done` for the hands-on work and wrap-up. Whenever you need the full command set, document expectations, folder layout, gating rules, or formats for PRD/SPEC/TASKS/etc., run `/chris-guide` (or open `skills/chris-guide/SKILL.md`).

Need repo context or local conventions? Keep the repo-level `AGENTS.md` up to date; it follows the template in `templates/AGENTS.md` and is the first thing every agent loads. For everything else—workflow scripts, git conventions, project schemas—refer to the `chris-guide` skill.

# Bash Commands

Avoid newlines inside a single Bash tool call — use `&&` or `;` to chain commands on one line. Newlines in Bash calls trigger a permissions prompt.
