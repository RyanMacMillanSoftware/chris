# Chris — Workflow Manager

Chris orchestrates projects through a fixed pipeline from idea to completion. Projects follow one of two tracks:

- **Code projects:** `new → prd → spec → tasks → build → review → done` (7 stages)
- **Non-code projects:** `new → plan → build → review → done` (5 stages)

Use `/wf-status` to see your projects and their stages, `/wf-new` to register a project, and `/wf-build` plus `/wf-review`/`/wf-done` for the hands-on work and wrap-up. Code projects use `/wf-prd → /wf-spec → /wf-tasks` for planning; non-code projects use `/wf-plan`.

Whenever you need the full command set, document expectations, folder layout, gating rules, or formats, run `/chris-guide` (or open `skills/chris-guide/SKILL.md`).

Need repo context or local conventions? Keep the repo-level `AGENTS.md` up to date; it follows the template in `templates/AGENTS.md` and is the first thing every agent loads. Agent behaviour specs live in `agents/` — these define how subagents (research-analyst, investigator, writer, communicator) behave when spawned by skills.

**Setup:** Run `scripts/install.sh` to symlink skills and agents, configure vault backing, and set up paths.

# Bash Commands

Avoid newlines inside a single Bash tool call — use `&&` or `;` to chain commands on one line. Newlines in Bash calls trigger a permissions prompt.

# Domain Rules

## Code Projects

- Follow conventional commits (`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`).
- Every new feature or bug fix must have a corresponding test; tests must pass before the stage advances to review.
- Stack preferences: use the language and framework already present in the repo; do not introduce new runtime dependencies without explicit user approval.
- Branch naming: `<project-slug>/<short-description>`; never commit directly to `main`.
- Keep `AGENTS.md` up to date in any repo you touch.

## Research Projects

- Prefer primary sources, peer-reviewed publications, and official documentation over secondary summaries.
- Save all research output to the project's `research/` directory.
- Cite every source as a markdown link including the page title and the date accessed, e.g. `[Title](https://example.com) — accessed 2026-03-09`.

## Investigation Projects

- Follow the Orient → Query → Correlate → Document methodology.
- Every claim must be backed by query results or data evidence.
- Save findings to the project's `research/` directory.
- Time-bound all queries with explicit lookback windows.

## Writing Projects

- Save all draft output to the project's `drafts/` directory.
- All deliverables must be in markdown format.
- The stage does not advance from build to review until the author has read the draft and explicitly approved it.

## Communication Projects

- **NEVER send messages without explicit user approval** — draft only.
- Save drafts to the project's `drafts/` directory.
- Include channel-appropriate "Sent via Claude Code" signature.
- Two explicit approvals required before any external send action.

## Program Projects

- A program coordinates multiple child projects toward a shared outcome.
- Children are tracked via the `children[]` array in `status.json`.
- The program is complete when all children reach stage `"done"`.
