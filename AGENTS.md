---
name: Chris
slug: chris
repo: ~/Code/chris
stack: [Markdown, Claude CLI skills, Git]
stage: build
install_cmd: null
default_branch: main
---

## Purpose

Chris is a personal workflow manager that turns ideas into shipped work through the `/wf-*` pipeline. Supports 6 project types: code, research, investigation, writing, communication, and program.

## Current Focus

Forge backport improvements (in review): 6 project types with two-track pipeline, vault backing, type-specific plan templates, agent specs, install script, and optional research stages for code projects.

## Conventions

- Skills live in `skills/`; each is a markdown instruction file (`SKILL.md`).
- Agent specs live in `agents/`; each defines role, inputs, outputs, tools, and constraints.
- Prefer `AGENTS.md` for repo context and `CLAUDE.md` for Claude global context.
- Shared skill logic goes in `skills/_shared/`; reference with `@`-pattern, don't inline.
- Vault backing is optional; configured via `~/.chris/config.yml`.

## Key Files

- `README.md` — public-facing setup and workflow overview
- `CLAUDE.md` — Claude-specific global context
- `skills/chris-guide/SKILL.md` — complete workflow reference
- `skills/_shared/` — reusable preflight, brief, handoff, and path resolution fragments
- `agents/` — reusable agent behaviour specs (research-analyst, investigator, writer, communicator)
- `templates/` — document templates (PRD, PLAN-*, REVIEW, status.schema, handoff)
- `scripts/install.sh` — setup script (symlinks, vault, config)

## Open Questions

-
