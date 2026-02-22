# Tasks: {{ Project Name }}

**Project:** {{ slug }}
**Branch:** chris/{{ slug }}
**Repos:** {{ repo-names }}
**Status:** Ready to build

---

## Phase 1 — {{ Phase Name }}

- [ ] TASK-001: Short task title
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
