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

Chris is a personal workflow manager that turns ideas into shipped code through the `/wf-*` pipeline.

## Current Focus

Phase 4 simplification: `_shared/` skill fragments, wf-build/wf-review refactors, wf-spec shape-spec integration.

## Conventions

- Skills live in `skills/`; each is a markdown instruction file (`SKILL.md`).
- Prefer `AGENTS.md` for repo context and `CLAUDE.md` for Claude global context.
- Shared skill logic goes in `skills/_shared/`; reference with `@`-pattern, don't inline.

## Key Files

- `README.md` - public-facing setup and workflow overview
- `CLAUDE.md` - Claude-specific global context
- `skills/chris-guide/SKILL.md` - complete workflow reference
- `skills/_shared/` - reusable preflight, brief, and handoff instruction fragments

## Open Questions

- 
