---
description: "Generate a technical specification from the project PRD."
---

# /wf-spec

Generate a technical spec from the project's PRD. Read the PRD carefully, then draft a spec covering architecture, data models, component breakdown, and tech decisions. Present it to Ryan before saving.

`$ARGUMENTS` — optional project slug

## Detect the current project

Same logic as `/wf-prd`:
1. Use `$ARGUMENTS` slug if provided
2. Detect from cwd by matching repos in `status.json` files
3. Otherwise list projects with stage `"prd"` and ask

If the project has no `PRD.md`, print:
```
❌ No PRD found for '<slug>'. Run /wf-prd first.
```

## Draft the spec

Read `~/Code/chris/projects/<slug>/PRD.md` in full.
Load `~/Code/chris/templates/SPEC.md` as structural guide.

Write a draft spec covering:

1. **Architecture Overview** — What is the system? How is it structured? What are the main components? Is there a binary, a service, a set of scripts? No binary if it can be avoided.
2. **Directory Structure** — Full file tree of what will be created/modified
3. **Data Models** — Key schemas, data formats, file structures
4. **Component / Module Breakdown** — One section per major component with: purpose, inputs, outputs, behaviour
5. **API Surface** — Public interfaces, function signatures, or endpoints if applicable
6. **Tech Decisions** — Stack choices, key trade-offs, anything that diverged from the PRD's constraints
7. **Open Questions** — Anything unresolved that needs a decision before building

Be specific. Avoid hand-waving. If a component needs an exact file path or JSON schema, define it.

## Review with Ryan

Show Ryan the draft spec and ask: "Does this look right? Anything to add, remove, or change?"

Iterate on sections until confirmed. Don't save without explicit approval.

## Save and commit

Write to `~/Code/chris/projects/<slug>/SPEC.md`.

Update `status.json`: set `stage` to `"spec"`, update `updated` timestamp.

Commit:
```bash
cd ~/Code/chris/projects
git add <slug>/SPEC.md <slug>/status.json
git commit -m "docs: add spec for <slug>"
```

## Print confirmation

```
✅ Spec saved to ~/Code/chris/projects/<slug>/SPEC.md

Next step: /wf-tasks
  Break the spec into ordered, testable tasks.
```
