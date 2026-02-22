---
description: "Write a Product Requirements Document for the current project."
---

# /wf-prd

Interactively write a PRD for the current project. Work through each section with Ryan, asking questions and drafting content. Don't write a wall of text and dump it — collaborate section by section.

`$ARGUMENTS` — optional project slug (if not in a project directory)

## Detect the current project

1. If `$ARGUMENTS` is provided, use that slug. Check `~/Code/chris/projects/<slug>/` exists.
2. Else if cwd is `~/Code/<repo>/` or a subdirectory, scan all `~/Code/chris/projects/*/status.json` for entries where `repos` contains this repo name. If exactly one match, use it. If multiple, ask which one.
3. Else list all projects with stage `"new"` or `"prd"` and ask which one to work on.

If no matching project is found, suggest running `/wf-new` first.

## Write the PRD

Load `~/Code/chris/templates/PRD.md` as the structural guide.

Work through each section **one at a time**. For each section:
- Ask targeted questions to understand what Ryan wants to express
- Draft the section content based on his answers
- Show the draft and ask for confirmation or edits before moving on
- Don't proceed to the next section until the current one is confirmed

Sections to cover:
1. **Overview** — What is this? Why does it exist? One paragraph.
2. **Problem** — What pain is being solved?
3. **Users** — Who uses this? What's their context?
4. **Goals** — Measurable outcomes (ask Ryan to make them specific)
5. **Non-Goals** — Explicitly out of scope (very valuable — push Ryan to define these)
6. **Success Metrics** — How will you know it worked?
7. **Constraints** — Tech, timeline, dependencies
8. **Key Concepts** — Define any domain-specific terms or entities that will recur
9. **Open Questions** — Things that need answering before or during spec

## Save and commit

Once all sections are confirmed, write the PRD to `~/Code/chris/projects/<slug>/PRD.md`.

Update `~/Code/chris/projects/<slug>/status.json`: set `stage` to `"prd"` and `updated` to current timestamp.

Commit:
```bash
cd ~/Code/chris/projects
git add <slug>/PRD.md <slug>/status.json
git commit -m "docs: add PRD for <slug>"
```

## Print confirmation

```
✅ PRD saved to ~/Code/chris/projects/<slug>/PRD.md

Next step: /wf-spec
  Generate the technical specification from this PRD.
```
