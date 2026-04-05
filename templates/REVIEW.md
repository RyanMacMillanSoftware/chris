---
project: {{ Project Name }}
type: review
tags:
  - project/{{ slug }}
  - type/review
  - stage/review
aliases:
  - {{ Project Name }} Review
created: {{ YYYY-MM-DD }}
updated: {{ YYYY-MM-DD }}
---

# Review: {{ Project Name }}

> **Hub:** [[{{ slug }}/index|{{ Project Name }}]] | **PRD:** [[{{ slug }}/PRD]] | **Tasks:** [[{{ slug }}/TASKS]]

## Plan vs. Actual

<!-- Compare planned goals/scope against what was actually delivered. -->

### What was planned

- {{ Summarize the goal from PRD.md (code) or PLAN.md (non-code) }}
- {{ List planned deliverables or steps }}

### What was delivered

- {{ Summarize what was actually produced }}
- {{ Note any deviations, additions, or omissions }}

### Delta

<!-- Call out material differences. If the plan was followed exactly, say so. -->

- {{ Describe any scope changes, timeline shifts, or deferred items }}

---

## Handoff Summary

<!-- List all handoff files from handoffs/. For each, note the agent, status, and key decisions. -->

| Handoff File | Agent | Status | Key Decisions |
|---|---|---|---|
| {{ TASK-NNN.json or timestamp-agent.json }} | {{ agent }} | {{ complete/partial/failed }} | {{ decisions }} |

### Key decisions across all handoffs

- {{ Decision 1 }}
- {{ Decision 2 }}

---

## Type-Specific Checks

<!-- Only the section matching this project's type applies. Delete the others. -->

### Code

- [ ] PR opened: {{ PR_LINK }}
- [ ] All tests pass (CI green)
- [ ] No new lint warnings or errors
- [ ] Branch follows convention: `chris/<slug>`
- [ ] No secrets or credentials committed
- [ ] AGENTS.md updated in target repo (if conventions changed)

### Research

- [ ] All research questions from PLAN.md addressed
- [ ] Every claim cites a source (markdown link with access date)
- [ ] Primary/peer-reviewed sources preferred over secondary summaries
- [ ] Findings saved to `research/` directory
- [ ] Methodology section in PLAN.md was followed
- [ ] Contradictory evidence acknowledged and addressed
- [ ] Summary/conclusion section present in each research output

### Investigation

- [ ] Hypothesis from PLAN.md tested with evidence
- [ ] Data sources queried per plan
- [ ] Evidence chain documented (query → data → conclusion)
- [ ] Time-bounded queries used (lookback window documented)
- [ ] Findings saved to `research/` directory
- [ ] Root cause or conclusion clearly stated
- [ ] Recommended next actions listed

### Writing

- [ ] All outline sections from PLAN.md completed
- [ ] Audience and format match PLAN.md spec
- [ ] Consistent voice and tone throughout
- [ ] Author has reviewed and approved the draft
- [ ] Drafts saved to `drafts/` directory
- [ ] No placeholder or TODO markers remain

### Communication

- [ ] Channel matches PLAN.md spec (Slack / email / Notion)
- [ ] Audience and tone match PLAN.md spec
- [ ] Key messages from PLAN.md included
- [ ] User has explicitly approved sending
- [ ] Drafts saved to `drafts/` directory
- [ ] No sensitive information exposed

### Program

- [ ] All child projects listed with current stage
- [ ] Child projects that reached "done":
  - {{ child-slug }} — done
- [ ] Child projects still in progress:
  - {{ child-slug }} — {{ stage }}
- [ ] Roll-up criteria from PLAN.md met
- [ ] No blocked children remain
- [ ] Timeline from PLAN.md compared to actual

---

## Open Issues

<!-- List anything unresolved: bugs, unanswered questions, deferred scope, follow-up work. -->

- [ ] {{ Open issue or follow-up item }}

---

## Verdict

<!-- The reviewer picks one: approve, revise, or reject.
     - approve: project advances to /wf-done
     - revise: project stays at review, specific changes requested
     - reject: project returns to build stage with clear reasons -->

**Verdict:** {{ approve / revise / reject }}

**Rationale:**

{{ 1-3 sentences explaining the verdict. If revise or reject, list specific items to address. }}
