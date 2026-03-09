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

AI-native workflow upgrade: hooks for auto-stage-advancement, eval gates at spec/build transitions, project_type support (code/research/writing) across wf-new/wf-tasks/wf-build, wf-write skill for writing projects.

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
