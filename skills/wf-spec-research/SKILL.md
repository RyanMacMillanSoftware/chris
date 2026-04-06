---
description: "Research technical patterns, similar implementations, and architecture approaches before writing the spec."
---

# /wf-spec-research

Research technical design patterns, similar open-source implementations, library comparisons, and architecture approaches relevant to the project. Produces a `SPEC-RESEARCH.md` document that `/wf-spec` will automatically load as context when drafting the specification.

`$ARGUMENTS` — optional project slug

## Detect the current project

Same logic as `/wf-prd`:
1. If `$ARGUMENTS` is provided, use that slug. Check `~/Code/chris/projects/<slug>/` exists.
2. Else if cwd is `~/Code/<repo>/` or a subdirectory, scan all `~/Code/chris/projects/*/status.json` for entries where `repos` contains this repo name. If exactly one match, use it. If multiple, ask which one.
3. Else list all projects with stage `"prd"` or `"spec-research"` and ask which one to work on.

If no matching project is found, suggest running `/wf-new` first.

## Write guards

Before proceeding to any file write operation:

- **Single match, no slug argument:** If `$ARGUMENTS` was not provided and exactly one project was detected from cwd, confirm with the user before proceeding:
  ```
  Running spec research for '<slug>'. Confirm? (y/n)
  ```
  If the user answers `n`, abort and stop.

- **Slug mismatch:** If a slug was provided in `$ARGUMENTS` but it does not match the cwd-detected project, hard block and stop:
  ```
  ❌ Slug mismatch: argument is '<arg-slug>' but cwd matches '<detected-slug>'. Check your working directory.
  ```

## Stage gate

Read `~/Code/chris/projects/<slug>/status.json` and check the `stage` field.

**Allowed stages:** `prd`, `spec-research`

If the stage is not one of the allowed stages, print:
```
❌ Project '<slug>' is at stage '<current-stage>'. Run /wf-prd first.
```
Then stop.

## Read PRD

Read `~/Code/chris/projects/<slug>/PRD.md` in full.

Extract and understand:
- Project goals and non-goals
- Constraints (technical, timeline, dependencies)
- Key concepts and domain-specific terms
- Open questions that need technical investigation

If `PRD.md` does not exist, print:
```
❌ No PRD found for '<slug>'. Run /wf-prd first.
```
Then stop.

## Ask research focus

Ask the user:
```
What technical questions should the research focus on?
```

Suggest defaults based on the PRD content. Examples of good defaults:
- "Architecture patterns for [key concept from PRD]"
- "Libraries for [technology need identified in constraints]"
- "How similar tools handle [core problem from PRD]"
- "Trade-offs between [approach A] and [approach B] from open questions"

Let the user confirm the defaults, modify them, or provide their own focus areas. Proceed once the user has confirmed the research focus.

## Conduct research

Using the confirmed focus areas, conduct web research. Search for:

1. **Similar implementations** — Open-source repos that solve similar problems. Use GitHub search, blog references, and documentation to find relevant projects. Note their architecture, design decisions, and what can be learned.
2. **Technical blog posts and documentation** — Articles about relevant patterns, best practices, and architecture discussions in the problem space.
3. **Library/framework comparisons** — If the PRD identifies technology choices to make, compare options on maturity, ecosystem fit, and trade-offs.
4. **Architecture discussions** — Community discussions, RFCs, or design documents that address similar technical challenges.

Be thorough. Aim for at least 3-5 similar implementations and multiple pattern references. Cite every source.

## Draft research document

Load `~/Code/chris/templates/SPEC-RESEARCH.md` as the structural guide.

Fill in each section from the research findings:

1. **Problem Context** — Restate what we are building (from the PRD) and what technical questions the research aimed to answer.
2. **Similar Implementations** — One subsection per relevant repo/project found, with URL, approach, architecture, and relevant patterns.
3. **Technical Patterns** — Patterns and approaches found in docs, blogs, and repos that are relevant, with descriptions and trade-offs.
4. **Library / Tool Comparison** — Table comparing options if applicable, covering maturity, ecosystem fit, and trade-offs.
5. **Recommended Architecture** — Based on the research, recommend a technical approach with rationale.
6. **Key Takeaways for Spec** — Bulleted list of findings that should directly inform the spec: architecture decisions, patterns to follow, libraries to use, pitfalls to avoid.
7. **Sources** — Every source cited as a markdown link with access date, e.g. `[Title](https://example.com) -- accessed 2026-03-29`.

## Review with the user

Present the full draft to the user and ask:
```
Does this look right? Anything to add, remove, or change?
```

Iterate on sections until the user explicitly confirms the document is ready. Do not save without explicit approval.

## Obsidian integration

When writing SPEC-RESEARCH.md, include YAML frontmatter from `templates/SPEC-RESEARCH.md`. Fill in values from `status.json` and the current date.

After the title heading, include:
```
> **Hub:** [[<slug>/<slug>-index|<Project Name>]] | **Spec:** [[<slug>/SPEC]]
```

After writing the file, update the project's `<slug>-index.md`:
1. Append to the Research section: `- [[<slug>/SPEC-RESEARCH|Spec Research]]`
2. Update the hub's `updated` frontmatter field

## Save and update

Write the approved document to `~/Code/chris/projects/<slug>/SPEC-RESEARCH.md`.

Update `~/Code/chris/projects/<slug>/status.json`: set `stage` to `"spec-research"` and `updated` to the current ISO 8601 timestamp.

Commit:
```bash
git -C ~/Code/chris/projects add <slug>/SPEC-RESEARCH.md <slug>/status.json && git -C ~/Code/chris/projects commit -m "docs: add spec research for <slug>"
```

## Print confirmation

```
✅ Spec research saved to ~/Code/chris/projects/<slug>/SPEC-RESEARCH.md

Next step: /wf-spec
  Generate the technical specification, informed by this research.
```
