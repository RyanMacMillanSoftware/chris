---
project: {{ Project Name }}
type: spec
tags:
  - project/{{ slug }}
  - type/spec
  - stage/spec
aliases:
  - {{ Project Name }} Technical Spec
created: {{ YYYY-MM-DD }}
updated: {{ YYYY-MM-DD }}
---

# SPEC: {{ Project Name }}

> **Hub:** [[{{ slug }}/index|{{ Project Name }}]] | **PRD:** [[{{ slug }}/PRD]] | **Tasks:** [[{{ slug }}/TASKS]]

## Architecture Overview

High-level description of how the system is structured. What are the main components? How do they interact?

---

## Directory Structure

```
~/Code/{{ slug }}/
├── src/
│   └── ...
└── ...
```

---

## Data Models

Define the key data structures, schemas, and formats.

### Example Model

```typescript
interface ExampleModel {
  id: string
  name: string
  createdAt: string
}
```

---

## Component / Module Breakdown

Describe each major component, module, or service. What does it do? What are its inputs and outputs?

### Component A

**Purpose:**
**Inputs:**
**Outputs:**
**Behaviour:**

---

## API Surface

*(If applicable)* Document the public interface — endpoints, function signatures, events.

---

## Tech Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Runtime  |        |           |
| Testing  |        |           |

---

## Open Questions

- [ ] Question needing resolution

## Decisions Made

- ✅ Confirmed decision
