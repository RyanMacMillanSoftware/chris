# Chris — How to Use It

Chris is your coding project workflow manager. It gives every project the same consistent structure — from initial idea through to shipped code — and makes it easy to manage multiple projects running concurrently, whether you're at your desk or on your phone.

---

## The Core Idea

Every project has a **workflow**, a **context file**, and a **home**.

- **Workflow**: A sequence of stages — PRD → Spec → Tasks → Build → Review. Each stage produces a document that feeds the next.
- **Context file** (`AGENTS.md`): A structured brief that lives in the project repo. Every agent session starts by reading this, so you never re-explain the project.
- **Home**: Actual code lives at `~/Code/<project-name>`. Chris's registry at `~/Code/chris/projects/<slug>/` tracks status and holds docs for projects without a repo yet.

---

## Workflow Stages

```
/wf-new → /wf-prd → /wf-spec → /wf-tasks → /wf-build → /wf-review
```

| Command | What it does | Produces |
|---------|-------------|---------|
| `/wf-new [name]` | Scaffolds project directory + Chris registry entry | `~/Code/<name>/`, `AGENTS.md` |
| `/wf-prd` | Guides you through writing a Product Requirements Document | `PRD.md` |
| `/wf-spec` | Writes a technical spec from the PRD | `SPEC.md` |
| `/wf-tasks` | Breaks the spec into ordered, testable tasks | `TASKS.md` |
| `/wf-build` | Spawns an agent loaded with your project context | Running agent |
| `/wf-review` | Reviews the current diff against spec + tasks | Review report |
| `/wf-status` | Shows all projects and their current stage | Status list |

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

---

## The AGENTS.md File

Every project has a `AGENTS.md`. It looks like this:

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

## Current Focus
What the agent should be working on right now.

## Conventions
Key patterns, naming, architecture decisions to follow.

## Key Files
- src/index.ts — entry point
- src/api/ — API layer

## Open Questions
Things that still need decisions.
```

Update this as things change. It's the first thing any agent (desktop or remote) loads when working on the project.

---

## Running Builds

**From your terminal (inside the project):**
```bash
cd ~/Code/my-project
# Open Claude CLI and run:
/wf-build           # spawns OpenClaw subagent, tracks remotely
/wf-build --local   # runs a Claude session right here in terminal
```

**From your phone (OpenClaw):**
> "Run a build on my-project"

Chris will find the project, load AGENTS.md, and spawn a background agent. You'll get notified when it's done or needs input.

---

## Managing Multiple Projects

Check what's going on across everything:
```
/wf-status
```

This shows all tracked projects and their current workflow stage. From OpenClaw, just ask "what's the status of my projects?" and you'll get the same view.

---

## Mobile / Remote Use

Chris integrates with OpenClaw so you can manage everything from WhatsApp on your phone:

- "Start a build on [project]" → spawns agent
- "What's the status?" → shows all projects
- "What tasks are left on [project]?" → reads TASKS.md
- "Kick off the review for [project]" → runs /wf-review

You don't need to be at your desk. Running builds, checking status, and reviewing output all work remotely.

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

## Tips

- **Keep AGENTS.md current.** Stale context is worse than no context.
- **Don't skip the PRD.** Even a rough one catches assumptions before they become bugs.
- **`/wf-review` before merging.** Takes 2 minutes, catches drift from the original spec.
- **Run multiple builds in parallel.** Chris is designed for concurrent projects — use it.
