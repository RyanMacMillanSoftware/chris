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

> **Hub:** [[{{ slug }}/index|{{ Project Name }}]] | **PRD:** [[{{ slug }}/PRD]] | **Spec:** [[{{ slug }}/SPEC]]

> Tasks marked `[P]` can run in parallel if their deps are met.

---

## Phase 1 — {{ Phase Name }}

- [ ] TASK-001: Short task title [P]
  **Repos:** {{ repo-name }}
  **Deps:** none

  Description of what needs to be done. Be specific enough that an agent can execute this without asking questions.

  Steps:
  - Step one
  - Step two

  **Accepts:** Specific, verifiable condition that proves this task is complete.

---

- [ ] TASK-002: Short task title
  **Repos:** {{ repo-name }}
  **Deps:** TASK-001

  Description.

  **Accepts:** Verifiable condition.

---

## Phase 2 — {{ Phase Name }}

- [ ] TASK-003: Short task title
  **Repos:** {{ repo-name }}
  **Deps:** TASK-001, TASK-002

  Description.

  **Accepts:** Verifiable condition.

---

## Notes

- Any conventions, gotchas, or context for the agent working these tasks
