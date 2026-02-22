---
description: "Create a new Chris project. Optionally scaffold a new repo."
---

# /wf-new

Create a new project in the Chris registry. A project is a unit of work — it may span multiple repos.

`$ARGUMENTS` — optional project name

## Steps

**1. Get the project name**

If `$ARGUMENTS` is provided, use it as the project name. Otherwise ask: "What's the project name?"

Slugify the name: lowercase, replace spaces and special characters with hyphens, strip anything non-alphanumeric except hyphens. Examples: "API Refactor" → `api-refactor`, "My App v2!" → `my-app-v2`.

**2. Check for conflicts**

If `~/Code/chris/projects/<slug>/` already exists, print:
```
❌ Project '<slug>' already exists at ~/Code/chris/projects/<slug>/
Run /wf-status to see its current stage.
```
Then stop.

**3. Create project metadata directory**

Create `~/Code/chris/projects/<slug>/` and write `status.json`:

```json
{
  "project": "<name>",
  "slug": "<slug>",
  "stage": "new",
  "repos": [],
  "branch": "chris/<slug>",
  "worktrees": {},
  "active_agents": [],
  "conflicts": [],
  "pr_url": null,
  "created": "<current ISO8601 timestamp>",
  "updated": "<current ISO8601 timestamp>"
}
```

**4. Ask about a new repo**

Ask: "Does this project need a new repo to be created? (y/n)"

**If yes:**

Ask: "What should the repo be named?" (suggest `<slug>` as default)

Then scaffold the new repo:
```bash
mkdir -p ~/Code/<repo-name>
cd ~/Code/<repo-name>
git init
git checkout -b main
git commit --allow-empty -m "chore: init"
```

Copy `~/Code/chris/templates/AGENTS.md` to `~/Code/<repo-name>/AGENTS.md` and pre-fill:
- `name:` → the repo display name
- `slug:` → the repo slug
- `repo:` → `~/Code/<repo-name>`

Tell the user: "I've created `~/Code/<repo-name>/`. Please fill in the AGENTS.md with your stack, install command, and any initial notes. I'll wait."

Wait for confirmation before continuing.

**If no:**

Print: "Repos will be identified during /wf-tasks when you break the spec into tasks."

**5. Commit to projects repo**

```bash
cd ~/Code/chris/projects
git add <slug>/
git commit -m "docs: init project <slug>"
```

**6. Print confirmation**

```
✅ Project '<slug>' created.

Next step: /wf-prd
  Write the Product Requirements Document for this project.
```
