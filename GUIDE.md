# Chris — How to Use It

Chris is your coding project workflow manager. It gives every project the same consistent structure — from initial idea through to shipped code — and makes it easy to manage multiple projects running concurrently from Claude CLI.

---

## The Core Idea

Every project has a **workflow**, **context files**, and a **home**.

- **Workflow**: A sequence of stages — PRD → Spec → Tasks → Build → Review → Done. Each stage produces a document that feeds the next.
- **Context files**: Two files live in each repo. `AGENTS.md` holds stable context (purpose, conventions, key files) and rarely changes. `CONTEXT.md` is the evolving layer (current focus, recent decisions, open questions) — updated by each build agent on task completion.
- **Home**: Actual code lives at `~/Code/<project-name>`. Chris's registry at `~/Code/chris/projects/<slug>/` tracks status and holds docs for projects without a repo yet.

---

## Workflow Stages

```
/wf-new → /wf-prd → /wf-spec → /wf-tasks → /wf-build → /wf-review → /wf-done
```

| Command | What it does | Produces |
|---------|-------------|---------|
| `/wf-new [name]` | Scaffolds project directory + Chris registry entry | `~/Code/<name>/`, `AGENTS.md` |
| `/wf-prd` | Guides you through writing a Product Requirements Document | `PRD.md` |
| `/wf-spec` | Writes a technical spec from the PRD | `SPEC.md` |
| `/wf-tasks` | Breaks the spec into ordered, testable tasks | `TASKS.md` |
| `/wf-build` | Spawns an agent loaded with your project context | Running agent |
| `/wf-review` | Reviews the current diff against spec + tasks | Review report |
| `/wf-done` | Closes a merged project and writes release artifacts | `release/` docs |
| `/wf-status` | Shows all projects and their current stage | Status list |
| `/wf-research [topic]` | Runs research at any stage and saves findings | `research/*.md` |

You don't have to go in order — skip stages that don't apply, or start from any point.

---

## Starting a New Project

```
# From any Claude CLI session:
/wf-new my-project-name

# Then work through stages in the same session or separate ones:
/wf-prd
/wf-spec
/wf-tasks
/wf-build
```

Chris creates `~/Code/my-project-name/` with an `AGENTS.md` file. This is the agent briefing doc — keep it up to date as the project evolves.

Child projects spawned by Chris create their own `.claude/` runtime cache. Make sure the repo's `.gitignore` lists `.claude/` (create the file if one does not exist) before committing so those session files never land in git.

---

## The AGENTS.md + CONTEXT.md Files

Every repo has two context files that agents load at session start.

**`AGENTS.md`** holds stable context that changes only when architecture changes:

```yaml
---
name: My Project
slug: my-project
repo: ~/Code/my-project
stack: [TypeScript, Bun]
stage: tasks
---

## Purpose
What this project does and why it exists.

## Conventions
Key patterns, naming, architecture decisions to follow.

## Key Files
- src/index.ts — entry point
- src/api/ — API layer
```

**`CONTEXT.md`** is the evolving layer — updated by each build agent when it finishes a task:

```markdown
## Current Focus
What the agent should be working on right now.

## Recent Decisions
Key decisions made in recent tasks — keeps the next agent from re-litigating closed decisions.

## Open Questions
Things that still need decisions.
```

Keep both files current. Stale context is worse than no context.

---

## Running Builds

**From your terminal (inside the project):**
```bash
cd ~/Code/my-project
# Open Claude CLI and run:
/wf-build              # spawns an agent session for the next task
/wf-build --local      # prints a task brief for a local Claude session
/wf-build --no-arch    # skip the architect pass for this run
/wf-build --sequential # disable parallel execution, run one task at a time
```

Before spawning a builder, `/wf-build` runs a **stage preflight** (checks branch, stage, and required docs) and an **architect pass** — a synchronous sub-agent that produces a one-screen implementation plan for your approval. Approve, revise, or skip before the builder runs.

If multiple tasks are tagged `[P]` and their dependencies are met, Chris offers to spawn them as concurrent sub-agents.

Each builder writes a `handoffs/TASK-NNN.json` on completion — capturing files changed, decisions made, confidence level, and open questions for the next agent.

---

## Managing Multiple Projects

Check what's going on across everything:
```
/wf-status
```

This shows all tracked projects and their current workflow stage.

---

## The Meta-Projects

Chris manages its own development through the same workflow:

- `projects/chris/` — the design and build of Chris itself
- `projects/workflow-improvements/` — a running log of things to improve in the workflow

When something feels clunky or you find a better pattern, note it in workflow-improvements. It's deliberately low-friction — just notes until there's enough to worth a proper task.

---

## What Chris is NOT

- Not a task manager or Kanban board
- Not replacing git, GitHub, or any existing tools
- Not a compiled app — everything is markdown + Claude CLI skills
- Not multi-user — this is personal tooling built for one person's style

---

## AgentOS Integration

Chris integrates with [AgentOS](https://github.com/buildermethods/agent-os) to inject indexed project standards into every agent brief automatically.

- Run `/wf-init` to configure the path to your AgentOS clone
- `/wf-new` can install AgentOS into a new repo (`agent-os/standards/`)
- `/wf-spec` can write tech stack decisions to `agent-os/product/tech-stack.md`
- `/wf-build` and `/wf-review` automatically load relevant standards into agent briefs

AgentOS is opt-in — Chris degrades gracefully if it's not configured.

---

## Tips

- **Keep AGENTS.md current.** Stale context is worse than no context.
- **Update CONTEXT.md per task.** Builders do this automatically; check it if something feels off.
- **Don't skip the PRD.** Even a rough one catches assumptions before they become bugs.
- **Use `[P]` tags in TASKS.md.** Independent tasks tagged `[P]` can run in parallel — big throughput win.
- **`/wf-review` before merging.** Runs a critic agent pre-review + the human report. Takes 2 minutes, catches drift from the original spec.
- **Run multiple builds in parallel.** Chris is designed for concurrent projects — use it.
