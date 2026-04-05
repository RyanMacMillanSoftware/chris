---
description: "Show all Chris projects and their current stage."
---

# /wf-status

Show all active Chris projects and their current stage. Output is formatted as a plain list — no markdown tables — so it renders correctly in plain-text surfaces.

`$ARGUMENTS` — optional: `all` to include done projects (default hides them), `--dashboard` to write Obsidian dashboard


## Resolve projects directory

Use the path resolution logic from `skills/_shared/paths.md`:

1. Read `~/.chris/config.yml`. If `vault_path` is set and `<vault_path>/Projects/` exists:
   → Projects dir = `<vault_path>/Projects/`
2. Otherwise:
   → Projects dir = `~/Code/chris/projects/`

## Read all projects

Scan `<projects_dir>/*/status.json`. Read each file.

## Dashboard mode

If `$ARGUMENTS` contains `--dashboard`:

1. Read `vault_path` from `~/.chris/config.yml`. If not set:
   ```
   ❌ Vault path not configured. Run scripts/install.sh to set it up.
   ```
   Stop.

2. Scan all projects (same as table mode).

3. Write `<vault_path>/dashboard.md` in Obsidian wiki-link format:
   ```markdown
   # Chris Dashboard

   *Last updated: YYYY-MM-DD HH:MM*

   ## Active Projects

   | Project | Type | Stage | Updated |
   |---------|------|-------|---------|
   | [[Projects/<slug>/PLAN\|<name>]] | <type> | <stage> | <YYYY-MM-DD> |

   ## Completed

   | Project | Type | Completed |
   |---------|------|-----------|
   | [[Projects/<slug>/PLAN\|<name>]] | <type> | <YYYY-MM-DD> |
   ```

   Use `[[Projects/<slug>/PLAN\|<name>]]` for non-code projects and `[[Projects/<slug>/PRD\|<name>]]` for code projects.

4. Print: `✅ Dashboard written to <vault_path>/dashboard.md`

5. Then continue to print the normal table mode output below.

## Dashboard mode

If `$ARGUMENTS` contains `--dashboard`:

1. Read `vault_path` from `~/.chris/config.yml`. If not set:
   ```
   ❌ Vault path not configured. Run scripts/install.sh to set it up.
   ```
   Stop.

2. Scan all projects (same as table mode).

3. Write `<vault_path>/dashboard.md` in Obsidian wiki-link format:
   ```markdown
   # Chris Dashboard

   *Last updated: YYYY-MM-DD HH:MM*

   ## Active Projects

   | Project | Type | Stage | Updated |
   |---------|------|-------|---------|
   | [[<slug>/index|<name>]] | <type> | <stage> | <YYYY-MM-DD> |

   ## Completed

   | Project | Type | Completed |
   |---------|------|-----------|
   | [[<slug>/index|<name>]] | <type> | <YYYY-MM-DD> |
   ```

   Use `[[<slug>/index|<name>]]` for all projects (link to hub note, not individual artifacts).

4. Print: `✅ Dashboard written to <vault_path>/dashboard.md`

5. Then continue to print the normal table mode output below.

## Obsidian integration

When generating the project status dashboard, link each project to its hub note:
`[[<slug>/index|<Project Name>]]`

Do not link to PRD or PLAN directly -- the hub note serves as the entry point.

## Sort projects

Order:
1. `build` (active agent running — highest priority)
2. `tasks`
3. `plan`
4. `spec`
5. `spec-research`
6. `prd`
7. `prd-research`
8. `new`
9. `review` (PR open, awaiting merge)
10. `done` (only shown if `$ARGUMENTS` contains `all`)

## Format the output

Use this exact format — plain text, emoji for stage, no tables:

```
📋 Chris Projects

🟢 <slug> — build (code)
   Repos: <repo1>, <repo2>
   ⚠️  Conflict: <repo> ↔ <competing-project>

🟡 <slug> — tasks (code)
   Repos: <repo>

🟡 <slug> — plan (research)
   Repos: (not applicable)

🔵 <slug> — prd (code)
   Repos: (not yet assigned)

🔵 <slug> — review (code)
   Repos: <repo>
   PR: <pr_url>

✅ <slug> — done (writing)
   (only shown with /wf-status all)
```

**Stage emoji:**
- 🔵 `new` — just created
- 🟡 `prd`, `spec`, `tasks`, `plan` — in planning
- 🟡 `prd-research`, `spec-research` — researching
- 🟢 `build` — actively building
- 🔵 `review` — under review
- ✅ `done` — closed

**Type display:** Show the project type in parentheses after the stage: `build (code)`, `plan (research)`, etc. Read `project_type` from each project's `status.json`.

**Conflict indicator:** Only show the `⚠️ Conflict` line if the project's `conflicts` array contains entries where `resolved` is `false`.

**Active agent indicator:** Show `(agent running)` in the build line if `active_agents` array is non-empty.

**PR URL:** Show the PR URL for projects in `review` stage if `pr_url` is set in status.json.

## Empty state

If no projects (or all are `done` and `all` flag not set):
```
No active projects. Run /wf-new to start one.
```

## Print the output

Just print it. No preamble. No markdown code blocks. Plain text.
