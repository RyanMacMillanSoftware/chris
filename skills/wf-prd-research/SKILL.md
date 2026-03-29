---
description: "Conduct market and competitive research before writing a PRD."
---

# /wf-prd-research

Conduct structured market and competitive research for the current project before writing the PRD. Search the web for competing products, user discussions, and market context, then compile findings into a research document that will inform the PRD.

`$ARGUMENTS` — optional project slug (if not in a project directory)

## Detect the current project

1. If `$ARGUMENTS` is provided, use that slug. Check `~/Code/chris/projects/<slug>/` exists.
2. Else if cwd is `~/Code/<repo>/` or a subdirectory, scan all `~/Code/chris/projects/*/status.json` for entries where `repos` contains this repo name. If exactly one match, use it. If multiple, ask which one.
3. Else list all projects with stage `"new"` or `"prd-research"` and ask which one to work on.

If no matching project is found, suggest running `/wf-new` first.

## Write guards

Before proceeding to any file write operation:

- **Single match, no slug argument:** If `$ARGUMENTS` was not provided and exactly one project was detected from cwd, confirm with the user before proceeding:
  ```
  Running PRD research for '<slug>'. Confirm? (y/n)
  ```
  If the user answers `n`, abort and stop.

- **Slug mismatch:** If a slug was provided in `$ARGUMENTS` but it does not match the cwd-detected project, hard block and stop:
  ```
  ❌ Slug mismatch: argument is '<arg-slug>' but cwd matches '<detected-slug>'. Check your working directory.
  ```

## Stage gate

Read `~/Code/chris/projects/<slug>/status.json`.

The project must be at stage `"new"` or `"prd-research"` (re-run). If the stage is anything else, print:

```
❌ Project '<slug>' is at stage '<current-stage>'. Run /wf-new first.
```

Then stop.

## Read project context

Read `status.json` to understand the project name and any other context fields (repos, description, etc.). If `~/Code/chris/projects/<slug>/PRD-RESEARCH.md` already exists (re-run), read it so you can build on or replace previous research.

## Ask research focus

Ask the user what the PRD research should focus on. Provide a sensible default based on the project name:

```
What should the PRD research focus on?
(e.g., competing tools, user needs, market size)

Default: competing tools and user needs for '<project name>'
```

Wait for the user's response. If they accept the default (empty response or confirmation), use it. Otherwise use their stated focus areas.

## Conduct web research

Using the focus areas, conduct web research. Search for:

- **Competing or similar products/tools** — what exists today, how they approach the problem, their strengths and weaknesses
- **User discussions** — forums, GitHub issues, blog posts, Reddit threads about the problem space; what users like, dislike, and wish existed
- **Market context and trends** — how the space is evolving, emerging patterns, relevant industry shifts

Use WebSearch and WebFetch to gather real data. Cite every source with its title, URL, and access date.

## Draft research document

Load `~/Code/chris/templates/PRD-RESEARCH.md` as the structural guide.

Fill in each section with findings from the research:

1. **Problem Context** — restate the project idea and what we're trying to learn
2. **Market Landscape** — existing solutions with strengths/weaknesses, gaps and opportunities
3. **User Research** — patterns from real user feedback, pain points, feature requests
4. **Competitive Analysis** — summary table comparing solutions
5. **Key Takeaways for PRD** — actionable findings that should inform Goals, Non-Goals, Constraints, and Key Concepts
6. **Sources** — every source cited as `[Title](url) — accessed YYYY-MM-DD`

Replace all template placeholders with real content. Do not leave any `{{ }}` placeholders.

## Review with the user

Present the full draft to the user for review. Ask:

```
Review the research draft above. Any changes or additions?
```

Iterate until the user approves. Make requested edits and re-present the updated sections. Do not proceed until the user explicitly approves.

## Save and update

Once approved, write the research document to `~/Code/chris/projects/<slug>/PRD-RESEARCH.md`.

Update `~/Code/chris/projects/<slug>/status.json`: set `stage` to `"prd-research"` and `updated` to the current ISO 8601 timestamp.

Commit (if projects/ is a git repo):
```bash
git -C ~/Code/chris/projects add <slug>/PRD-RESEARCH.md <slug>/status.json && git -C ~/Code/chris/projects commit -m "docs: add PRD research for <slug>"
```
## Print confirmation

```
✅ PRD research saved to ~/Code/chris/projects/<slug>/PRD-RESEARCH.md

Next step: /wf-prd
  Write the Product Requirements Document, informed by this research.
```
