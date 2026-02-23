---
name: Chris
slug: chris
repo: ~/Code/chris
stack: [Claude CLI skills, Markdown, Git]
stage: tasks
install_cmd: null
default_branch: main
---

## What Chris Is

Chris is a coding project workflow manager — a personal tool built for you to take software ideas from inception through to shipped code in a consistent, repeatable way. It manages:

- **Workflow stages**: Research → PRD → Spec → Tasks → Build → Review
- **Git operations**: branching, worktrees, commits, and draft PRs — all on the user's behalf
- **Multiple concurrent projects**: using git worktrees to prevent projects from clashing on shared repos
- **Remote access**: integrating with OpenClaw so the user can manage projects from their phone via WhatsApp

Chris is self-hosting — it uses its own workflow to manage its own development. This repo IS the Chris tool. When you are working in this repo, you are either building Chris itself or updating its skills, templates, or project metadata.

---

## Repo Structure

```
~/Code/chris/
├── .chris/
│   └── CONTEXT.md          ← this file (repo context for agents)
├── projects/               ← project metadata for all projects managed by Chris
│   ├── chris/              ← meta-project: building Chris itself
│   │   ├── CONTEXT.md
│   │   ├── PRD.md
│   │   ├── SPEC.md         ← (not yet written)
│   │   └── TASKS.md        ← (not yet written)
│   └── workflow-improvements/
│       └── CONTEXT.md      ← ongoing log of friction points and improvements
├── skills/                 ← Claude CLI skill source files (/wf-* commands)
├── templates/              ← doc templates (PRD, SPEC, TASKS, CONTEXT)
├── README.md               ← quick reference
└── GUIDE.md                ← full user guide
```

---

## Terminology (use precisely)

**PROJECT**: A unit of work — a set of desired outcomes grouped by a PRD. Not 1:1 with a repo. A project can span multiple repos. Orchestrates the full workflow chain. Metadata lives in `~/Code/chris/projects/<slug>/`.

**REPO**: A source code repository at `~/Code/<repo-name>/`. Contains `.chris/CONTEXT.md` for agent context. A repo can be involved in multiple concurrent projects.

**PROJECT METADATA**: The docs that define and track a project — `PRD.md`, `SPEC.md`, `TASKS.md`, `status.json`, `research/`. Stored in `~/Code/chris/projects/<slug>/`, not in any single repo.

**REPO CONTEXT**: The `.chris/CONTEXT.md` file in a repo. Describes the repo's permanent shape — stack, conventions, key files. Not project-specific. This is what you are reading right now.

---

## Workflow Skills

Skills live in `~/Code/chris/skills/` and are installed globally to `~/.claude/skills/` so they work in any Claude session.

| Skill | Purpose |
|-------|---------|
| `/wf-new [name]` | Create a new project. Optionally scaffold a new repo. |
| `/wf-prd` | Write a Product Requirements Document interactively. |
| `/wf-spec` | Generate a technical spec from the PRD. |
| `/wf-tasks` | Break the spec into ordered tasks; identify which repos are involved; lock in git strategy. |
| `/wf-build` | Spawn an agent (OpenClaw subagent by default, `--local` for in-terminal). Loads this CONTEXT.md + project metadata. Manages git. |
| `/wf-review` | Review current diff against spec + tasks. On pass: push branch, open draft PR. |
| `/wf-status` | Show all projects and stages. WhatsApp-formatted plain list. |
| `/wf-research [topic]` | Research a topic at any workflow stage. Saves to `projects/<slug>/research/`. |

---

## Git Conventions

When working in this repo, follow these conventions:

- **Branch naming**: `chris/<project-slug>` (e.g., `chris/api-refactor`, `chris/chris`)
- **Commit style**: Conventional commits — `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`
- **No project slug in commit messages** — conventional type is sufficient
- **Worktrees**: if multiple projects are editing this repo simultaneously, they use separate worktrees at `~/Code/.chris-worktrees/<project-slug>/chris/`
- **PRs**: draft PRs opened automatically by `/wf-review` when it passes; the user promotes to ready

**Examples of good commit messages in this repo:**
```
docs: update PRD with git branching decisions
feat: add /wf-research skill
chore: install wf-tasks skill globally
fix: correct worktree path in wf-build skill
```

---

## Working on Chris (Meta Notes)

When an agent is tasked with working on Chris itself, be aware:

1. **This is meta work** — you are building the tool that manages tool-building. Be especially careful with skill files, as they will run in other people's Claude sessions.
2. **Skills are markdown prompts** — they live in `~/Code/chris/skills/<skill-name>/SKILL.md`. They instruct Claude how to behave when a `/wf-*` command is invoked.
3. **Templates are guides, not rigid forms** — `~/Code/chris/templates/` holds example docs for PRD, SPEC, TASKS, CONTEXT. Update them when you find better patterns.
4. **The meta-project is real work** — `projects/chris/` is an active project with its own PRD, SPEC, and TASKS. Don't confuse "working in the chris repo" with "working on the chris project". You might be doing both, or just one.
5. **Workflow-improvements is low-friction** — `projects/workflow-improvements/` is a notes file, not a formal project. Add friction points there as plain text notes; they'll be processed later.

---

## Current State

- PRD written: `projects/chris/PRD.md`
- SPEC written: `projects/chris/SPEC.md`
- TASKS written: `projects/chris/TASKS.md`
- Skills folder is empty — no `/wf-*` skills built yet
- Templates folder is empty — no templates built yet
- `~/Code/chris/` is not yet a git repo (to be initialised)

---

## Key Design Decisions (from PRD)

- One branch per project (`chris/<slug>`), not one per task
- Worktrees at `~/Code/.chris-worktrees/<project-slug>/<repo>/`, persisted between sessions
- Repo association determined during `/wf-tasks`, not at project creation
- `~/Code/chris/` = public git repo (skills, templates, guide); `~/Code/chris/projects/` = separate private git repo (all personal project data — PRDs, specs, tasks, research). Split is a nice-to-have, not day-one.
- No bun/TypeScript compiled layer — everything is markdown + shell
- `/wf-review` pass → push branch → open draft PR on GitHub (target branch configurable via `default_branch` in CONTEXT.md, defaults to `main`)
- `/wf-status` formatted as plain list (WhatsApp-compatible, no markdown tables)
- Worktrees auto-run `install_cmd` from CONTEXT.md front matter on creation (e.g., `bun install`)
- Conflict resolution: notify the user immediately, do NOT pause work; flag risk throughout project and at merge time

---

## Related Docs

- Full PRD: `~/Code/chris/projects/chris/PRD.md`
- User guide: `~/Code/chris/GUIDE.md`
- Quick reference: `~/Code/chris/README.md`
