---
description: "Research a topic for a project. Saves findings to the project folder."
---

# /wf-research

Research a topic and save the findings to a project. Can be run at any workflow stage — before starting the PRD, during spec, during build, anytime.

`$ARGUMENTS` — `[project-slug] <topic>` — first word is treated as a project slug if it matches a known project; the rest is the research topic.

## Parse arguments

1. Split `$ARGUMENTS` by spaces.
2. Check if the first word matches an existing project slug (`~/Code/chris/projects/<first-word>/` exists).
   - If yes → project slug is the first word, topic is the remainder.
   - If no → prompt: "Which project is this research for?" (list active projects). Topic is all of `$ARGUMENTS`.
3. If no `$ARGUMENTS` at all → ask for both project and topic.

## Conduct research

Research the topic thoroughly. Structure the investigation based on what's most useful for the question:

- For **feasibility / technical questions**: explore existing solutions, libraries, approaches. What have others done? What are the trade-offs?
- For **technology choices**: compare options across: maturity, ecosystem, fit for this project's stack and constraints
- For **market / product questions**: who else is doing this? What are the patterns? What's worked or failed?
- For **prior art**: find examples, open-source projects, articles, documentation

Use web search where relevant. Synthesise, don't just list links.

## Format the findings

Structure the research output as:

```markdown
# Research: <topic>

**Project:** <slug>
**Date:** <YYYY-MM-DD>
**Question:** What this research was trying to answer

## Summary

2–3 sentence answer to the core question.

## Key Findings

- Finding 1
- Finding 2
- Finding 3

## Options Considered

*(If this is a comparison/decision research)*

### Option A: <name>
**Pros:** ...
**Cons:** ...

### Option B: <name>
**Pros:** ...
**Cons:** ...

## Recommendation

Clear recommendation based on this project's context and constraints.

## Sources

- [Title](url)
- [Title](url)
```

Omit sections that aren't relevant (e.g. no "Options Considered" if it's not a comparison).

## Save the findings

Slugify the topic: lowercase, hyphens, strip special characters.

Save to: `~/Code/chris/projects/<slug>/research/<YYYY-MM-DD>-<topic-slug>.md`

Create the `research/` directory if it doesn't exist.

Commit:
```bash
git -C ~/Code/chris/projects add <slug>/research/ && git -C ~/Code/chris/projects commit -m "docs: add research on <topic-slug> for <slug>"
```

## Print confirmation

```
✅ Research saved to:
   ~/Code/chris/projects/<slug>/research/<date>-<topic-slug>.md
```

Do NOT update `status.json` stage. Research can happen at any stage.
