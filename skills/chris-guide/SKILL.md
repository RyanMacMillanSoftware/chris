---
description: "Print a comprehensive reference for the Chris workflow system."
---

# /chris-guide

Print a comprehensive reference for the Chris workflow system. Use this to brief yourself
or a subagent on the full system. No arguments needed.

---

## What Chris Is

Chris is a personal coding workflow manager for one developer. It takes software ideas from
first thought to shipped code through a fixed, repeatable pipeline — managing git, spawning
agents, and coordinating work across multiple repos and concurrent projects.

```
/wf-new → /wf-prd → /wf-spec → /wf-tasks → /wf-build → /wf-review → /wf-done
```

Everything is markdown + Claude CLI skills. No compiled app. Not multi-user.

---

## Workflow Stages

| Stage | Command | What it does | Output document |
|-------|---------|-------------|-----------------|
| `new` | `/wf-new [name]` | Create project registry entry | `status.json` |
| `prd` | `/wf-prd` | Write PRD interactively, section by section | `PRD.md` |
| `spec` | `/wf-spec` | Generate technical spec from PRD | `SPEC.md` |
| `tasks` | `/wf-tasks` | Break spec into ordered tasks; set up branches | `TASKS.md` |
| `build` | `/wf-build` | Spawn agent on next unchecked task | Running agent |
| `review` | `/wf-review` | Review diff vs spec + tasks; push + draft PR | Review report |
| `done` | `/wf-done` | Release artifacts + git cleanup + archive | `release/` |

Supporting skills (any stage):
- `/wf-status [all]` — list all projects; shows conflicts, active agents, PR URLs
- `/wf-research [topic]` — run research and save to `~/Code/chris/projects/<slug>/research/`

You don't have to go in order. Skip stages that don't apply. Re-run any stage to update it.

---

## Directory Layout

```
~/Code/
├── .chris-worktrees/              ← isolated checkouts for concurrent projects
│   └── <slug>/
│       └── <repo>/                ← worktree for this project+repo
│
├── chris/                         ← this repo (public)
│   ├── AGENTS.md
│   ├── skills/                    ← /wf-* skill sources
│   ├── templates/                 ← blank doc templates
│   └── projects/                  ← private project data (separate git repo)
│       └── <slug>/
│           ├── status.json
│           ├── PRD.md
│           ├── SPEC.md
│           ├── TASKS.md
│           ├── research/
│           └── release/
│
└── <repo-name>/                   ← code repos (siblings of chris/)
    └── AGENTS.md
```

---

## status.json Schema

Every project has `~/Code/chris/projects/<slug>/status.json`:

```json
{
  "project": "Human readable name",
  "slug": "kebab-case-identifier",
  "stage": "new|prd|spec|tasks|build|review|done",
  "repos": ["repo-name-1", "repo-name-2"],
  "branch": "chris/<slug>",
  "worktrees": {
    "<repo>": "~/Code/.chris-worktrees/<slug>/<repo>/"
  },
  "active_agents": [
    {"task": "TASK-001", "started_at": "<ISO8601>"}
  ],
  "conflicts": [
    {
      "repo": "<repo>",
      "competing_project": "<other-slug>",
      "files": ["src/auth/session.ts"],
      "detected_at": "<ISO8601>",
      "resolved": false
    }
  ],
  "pr_url": "https://github.com/org/repo/pull/42",
  "created": "<ISO8601>",
  "updated": "<ISO8601>",
  "closed_at": "<ISO8601>"
}
```

---

## AGENTS.md — Repo Brief Format

Every code repo has `AGENTS.md` at its root. Agents load this at session start.

```yaml
---
name: My API
slug: my-api
repo: ~/Code/my-api
stack: [TypeScript, Bun]
stage: build
install_cmd: bun install
default_branch: main
---

## Purpose
What this repo does and why it exists.

## Current Focus
What's being worked on right now (keep this current).

## Conventions
Key patterns, naming, architecture decisions to follow.

## Key Files
- src/index.ts — entry point
- src/api/ — API layer

## Open Questions
Things that still need decisions.
```

`/wf-new` creates this file. For existing repos: copy from `~/Code/chris/templates/AGENTS.md`.
Stale AGENTS.md is worse than no AGENTS.md — keep it updated as the project evolves.

---

## TASKS.md Format

```markdown
## Phase 1 — Foundation

- [ ] TASK-001: Short descriptive title
  **Repos:** repo-name
  **Deps:** none

  Description: what needs to be done. Specific enough that an agent can execute without
  asking clarifying questions. Include file paths, command names, exact formats.

  **Accepts:** A specific, verifiable condition proving this task is complete.

- [ ] TASK-002: Next task
  **Repos:** repo-name
  **Deps:** TASK-001

  Description here.

  **Accepts:** Acceptance condition.
```

Rules:
- Zero-padded three-digit numbers: TASK-001, TASK-002, etc.
- Ordered so dependencies are satisfied before dependents
- Each task should be completable in a single focused agent session
- Tasks touch as few repos as possible
- Mark complete with `[x]` when done

---

## Git Operations

Chris manages git throughout the workflow:

**Branch creation** (`/wf-tasks`):
```bash
git -C ~/Code/<repo> checkout -b chris/<slug>
```

**Worktree setup** (`/wf-build`, when two projects share a repo):
```bash
git -C ~/Code/<repo> worktree add ~/Code/.chris-worktrees/<slug>/<repo>/ chris/<slug>
```

**During build** (agent instructions):
- Commit at logical checkpoints using conventional commits
- Stay on `chris/<slug>` — do not switch branches
- Do not push — `/wf-review` handles pushing

**On review pass** (`/wf-review`):
```bash
git -C <path> push origin chris/<slug>
gh pr create --head chris/<slug> --base main --draft
```

**Cleanup** (`/wf-done`):
```bash
git -C ~/Code/<repo> worktree remove ~/Code/.chris-worktrees/<slug>/<repo>/ --force
git -C ~/Code/<repo> branch -d chris/<slug>
```

---

## Conflict Detection

`/wf-build` checks for conflicts before spawning an agent:

1. Find all other `chris/*` branches on the same repo
2. Get files modified by each competing branch since diverging from main
3. Get files modified by the current branch
4. If overlap → notify user + add to `status.json` conflicts array (resolved: false)

Chris notifies but does not block. Watch for merge conflicts at PR time.
`/wf-review` surfaces any unresolved conflicts in the review report.

---

## Project Detection (all wf-* skills)

1. `$ARGUMENTS` provides a slug → use it directly
2. cwd is `~/Code/<repo>/` or subdirectory → scan all `status.json` files for this repo in `repos` array
   - One match → use it
   - Multiple matches → ask: "Multiple projects reference this repo: [list]. Which one?"
3. No match → list projects eligible for the current stage, ask user to choose

---

## Stage-Gating

| Skill | Required stage | Error message |
|-------|---------------|---------------|
| `/wf-prd` | `new` or `prd` | "Run /wf-new first" |
| `/wf-spec` | `prd` | "Run /wf-prd first" |
| `/wf-tasks` | `spec` | "Run /wf-spec first" (warn but allow re-run if already `tasks`) |
| `/wf-build` | `tasks` or `build` | "Run /wf-tasks first" |
| `/wf-review` | `build` or `tasks` | "Run /wf-build first" |
| `/wf-done` | `review` or `build` | — |

---

## Integration Status

OpenClaw/WhatsApp integration is deprecated and no longer part of the active workflow.
Run Chris from Claude CLI using the `/wf-*` commands directly.

---

## Release Artifacts (generated by /wf-done)

Saved to `~/Code/chris/projects/<slug>/release/`:

- `PRESS-RELEASE.md` — human-readable announcement: headline, what was built, why it matters, key highlights
- `RELEASE-NOTES.md` — technical changelog: completed tasks, decisions, deferred items, known issues
- `UPDATE-LOG.md` — terse commit log grouped by repo

---

## Meta-Projects

Chris manages its own development through the same workflow:
- `projects/chris/` — design and build of Chris itself
- `projects/workflow-improvements/` — running log of things to improve (low friction: just notes)

---

## Common Gotchas

- **Stale AGENTS.md** — update it whenever the project focus changes; agents rely on it
- **Skipping /wf-prd** — even a rough PRD catches assumptions before they become bugs
- **Forgetting /wf-review** — takes 2 minutes; catches drift from the original spec
- **Running builds in the main checkout when a worktree exists** — check `status.json` worktrees first
- **Pushing before review** — let `/wf-review` handle pushing; it sets up the PR correctly
- **Not committing the projects repo** — most wf-* skills update project metadata there; don't skip it
