# SKILL.md Structure

Each skill lives in `skills/<name>/SKILL.md`.

## Front-matter

```yaml
---
description: "One sentence. Shown to the agent for skill selection — keep it tight."
argument-hint: "[optional-slug]"   # shown in autocomplete; omit if no args
---
```

- `description` is the primary field. Agents read it to decide which skill to invoke without loading the body.
- `argument-hint` documents `$ARGUMENTS` expectations. Use bracket notation: `[slug]`, `[slug] [--flag]`.
- Other fields (`model`, `allowed-tools`, `context`) are available but uncommon in this repo.

## Body

- First heading: `# /command-name` matching the folder name
- Second line: one-liner restatement of what it does
- Then: `$ARGUMENTS — optional/required: description`
