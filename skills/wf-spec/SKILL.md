---
description: "Generate a technical specification from the project PRD."
---

# /wf-spec

Generate a technical spec from the project's PRD. Read the PRD carefully, then draft a spec covering architecture, data models, component breakdown, and tech decisions. Present it to the user before saving.

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

## Write guards

Before proceeding to any file write operation:

- **Single match, no slug argument:** If `$ARGUMENTS` was not provided and exactly one project was detected from cwd, confirm with the user before proceeding:
  ```
  Writing spec for '<slug>'. Confirm? (y/n)
  ```
  If the user answers `n`, abort and stop.

- **Slug mismatch:** If a slug was provided in `$ARGUMENTS` but it does not match the cwd-detected project, hard block and stop:
  ```
  ❌ Slug mismatch: argument is '<arg-slug>' but cwd matches '<detected-slug>'. Check your working directory.
  ```

## Run shape-spec

Before drafting, check if `~/Code/<repo>/agent-os/specs/` contains a recent spec folder matching `<slug>` (look for any `*-<slug>/` folder). If a recent one exists, load its contents and skip to "Draft the spec".

If no recent shape exists, run the `/shape-spec` flow in plan mode:
1. **Gather visuals** — ask if there are any mockups, screenshots, or diagrams to include
2. **Reference implementations** — ask for any existing code or similar products to reference
3. **Product context** — load PRD.md goals, constraints, and user stories
4. **Surface standards** — call `/inject-standards` with PRD keywords to surface relevant project standards

Present the shape summary (scope, key decisions, relevant standards, references) and ask: "Does this shape look right before I write the spec?"

Once confirmed, save shape artifacts to `~/Code/<repo>/agent-os/specs/YYYY-MM-DD-HHMM-<slug>/` and use the shape outputs as inputs to the draft below.

## Draft the spec

Read `~/Code/chris/projects/<slug>/PRD.md` in full.
Load `~/Code/chris/templates/SPEC.md` as structural guide.
Incorporate any shape-spec outputs (scope decisions, standards, references) from the previous step.

Write a draft spec covering:

1. **Architecture Overview** — What is the system? How is it structured? What are the main components? Is there a binary, a service, a set of scripts? No binary if it can be avoided.
2. **Directory Structure** — Full file tree of what will be created/modified
3. **Data Models** — Key schemas, data formats, file structures
4. **Component / Module Breakdown** — One section per major component with: purpose, inputs, outputs, behaviour
5. **API Surface** — Public interfaces, function signatures, or endpoints if applicable
6. **Tech Decisions** — Stack choices, key trade-offs, anything that diverged from the PRD's constraints
7. **Open Questions** — Anything unresolved that needs a decision before building

Be specific. Avoid hand-waving. If a component needs an exact file path or JSON schema, define it.

## Review with the user

Show the user the draft spec and ask: "Does this look right? Anything to add, remove, or change?"

Iterate on sections until confirmed. Don't save without explicit approval.

## Save and commit

Write to `~/Code/chris/projects/<slug>/SPEC.md`.

Update `status.json`: set `stage` to `"spec"`, update `updated` timestamp.

Commit:
```bash
git -C ~/Code/chris/projects add <slug>/SPEC.md <slug>/status.json && git -C ~/Code/chris/projects commit -m "docs: add spec for <slug>"
```

## Write AgentOS product docs (optional)

After SPEC.md is saved and committed:

1. Determine the first repo in `status.json.repos` (call it `<repo>`).
2. Check if `~/Code/<repo>/agent-os/product/` exists.
3. If it exists, ask: "Write tech stack decisions from this spec to `agent-os/product/tech-stack.md`? (y/n)"
4. If y:
   - Read `~/Code/<repo>/agent-os/standards/global/tech-stack.md` (if present) to understand the expected format. Match that style.
   - Extract runtime, framework, database, and key libraries from the spec's Tech Decisions table.
   - Write `~/Code/<repo>/agent-os/product/tech-stack.md` in that style.
   - Commit the new file alongside SPEC.md (or as a follow-up commit if SPEC.md was already committed):
     ```bash
     cd ~/Code/<repo>
     git add agent-os/product/tech-stack.md
     git commit -m "docs: add AgentOS product tech-stack from spec for <slug>"
     ```
5. If n or if `product/` does not exist: skip silently.

## Print confirmation

```
✅ Spec saved to ~/Code/chris/projects/<slug>/SPEC.md

Next step: /wf-tasks
  Break the spec into ordered, testable tasks.
```
