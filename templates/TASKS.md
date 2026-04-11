---
project: {{ Project Name }}
type: tasks
tags:
  - project/{{ slug }}
  - type/tasks
  - stage/tasks
aliases:
  - {{ Project Name }} Task List
created: {{ YYYY-MM-DD }}
updated: {{ YYYY-MM-DD }}
---

# Tasks: {{ Project Name }}

> **Hub:** [[{{ slug }}/{{ slug }}-index|{{ Project Name }}]] | **PRD:** [[{{ slug }}/PRD]] | **Spec:** [[{{ slug }}/SPEC]]

> ⚠️ **Generated file.** Beads are the source of truth. Edit via `bd update <id>` then run `/wf-tasks --refresh`.

---

## Phase 1 — {{ Phase Name }}

### TASK-001: Short task title `[{{ bead-id }}]`
- **Rig:** {{ rig-name }} (`{{ prefix }}`)
- **Deps:** none
- **Type:** scaffold
- **Accepts:** Specific, verifiable condition.

Description of what needs to be done.

---

### TASK-001.1: Test stubs `[{{ bead-id }}.1]`
- **Rig:** {{ rig-name }} (`{{ prefix }}`)
- **Deps:** TASK-001 `[{{ bead-id }}]`
- **Type:** test-stub
- **Accepts:** Tests exist and fail.

---

### TASK-001.2: Implementation `[{{ bead-id }}.2]`
- **Rig:** {{ rig-name }} (`{{ prefix }}`)
- **Deps:** TASK-001.1 `[{{ bead-id }}.1]`
- **Type:** impl
- **Accepts:** All tests from TASK-001.1 pass.

---

### TASK-V01: Phase 1 validation checkpoint `[{{ gate-bead-id }}]`
- **Rig:** hq
- **Deps:** TASK-001.2 `[{{ bead-id }}.2]`
- **Type:** gate
- **Accepts:** All tests pass, all services start, integration verified.

---

## Phase 2 — {{ Phase Name }}

### TASK-002: Short task title `[{{ bead-id }}]`
- **Rig:** {{ rig-name }} (`{{ prefix }}`)
- **Deps:** TASK-V01 `[{{ gate-bead-id }}]`
- **Type:** impl
- **Accepts:** Verifiable condition.

Description.

---

## Notes

- Beads are the source of truth. This file is regenerated from bead state.
- Edit beads via `bd update <id>`, then run `/wf-tasks --refresh` to regenerate.
- Parallelism is handled by the bead dependency graph — no `[P]` tags needed.
