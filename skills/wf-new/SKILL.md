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

**2. Ask for project type**

Ask: "Project type? [code / research / investigation / writing / communication / program] (default: code)"

Valid types: `code`, `research`, `investigation`, `writing`, `communication`, `program`. If the user presses Enter without typing or enters an invalid value, default to `"code"`. Store the result as `<project_type>`.

**3. Check for conflicts**

If `~/Code/chris/projects/<slug>/` already exists, print:

```
❌ Project '<slug>' already exists at ~/Code/chris/projects/<slug>/
Run /wf-status to see its current stage.
```
Then stop.

**4. Create project metadata directory**

Create `~/Code/chris/projects/<slug>/` and write `status.json`:

```json
{
  "project": "<name>",
  "slug": "<slug>",
  "stage": "new",
  "project_type": "<project_type>",
  "repos": [],
  "branch": "chris/<slug>",
  "worktrees": {},
  "active_agents": [],
  "conflicts": [],
  "pr_url": null,
  "tags": [],
  "children": [],
  "created": "<current ISO8601 timestamp>",
  "updated": "<current ISO8601 timestamp>"
}
```

**4b. Vault path handling**

Read `~/.chris/config.yml` and extract `vault_path` (may not exist or be empty).

If `vault_path` is set and the directory exists:
1. Create the project directory at `<vault_path>/Projects/<slug>/` instead of `~/Code/chris/projects/<slug>/`.
2. Create a symlink: `~/Code/chris/projects/<slug>/` → `<vault_path>/Projects/<slug>/`.
3. Write `status.json` to `<vault_path>/Projects/<slug>/status.json` (the symlink ensures backwards compatibility).

If `vault_path` is not set or directory doesn't exist, use `~/Code/chris/projects/<slug>/` directly (the default behavior in step 4).

**4c. Create hub note**

Create `<project_dir>/<slug>-index.md` using `~/Code/chris/templates/hub-index.md` as the template. Fill in:
- `project`: from `status.json.project`
- `slug`: from `status.json.slug`
- `current-stage`: `"new"`
- `project-type`: from `status.json.project_type`
- `YYYY-MM-DD`: current date

Populate the Artifacts table based on `project_type`:
- **Code projects** (`code`):
  ```
  | Document | Status |
  |----------|--------|
  | [[<slug>/PRD]] | — |
  | [[<slug>/SPEC]] | — |
  | [[<slug>/TASKS]] | — |
  | [[<slug>/REVIEW]] | — |
  ```
- **Non-code projects** (`research`, `investigation`, `writing`, `communication`, `program`):
  ```
  | Document | Status |
  |----------|--------|
  | [[<slug>/PLAN]] | — |
  | [[<slug>/REVIEW]] | — |
  ```

Set the hub description placeholder to the project description (if available) or leave as `{{ One-line description from PRD overview or plan goal. }}`.

**5. Ask about a new repo**

Ask: "Does this project need a new repo to be created? (y/n)"

**If yes:**

Ask: "What should the repo be named?" (suggest `<slug>` as default)

Then scaffold the new repo:
```bash
mkdir -p ~/Code/<repo-name> && git -C ~/Code/<repo-name> init && git -C ~/Code/<repo-name> checkout -b main && git -C ~/Code/<repo-name> commit --allow-empty -m "chore: init"
```

Copy `~/Code/chris/templates/AGENTS.md` to `~/Code/<repo-name>/AGENTS.md` and pre-fill:
- `name:` → the repo display name
- `slug:` → the repo slug
- `repo:` → `~/Code/<repo-name>`

Set up ignore rules:
```bash
touch ~/Code/<repo-name>/.gitignore
grep -qxF ".claude/" ~/Code/<repo-name>/.gitignore || echo ".claude/" >> ~/Code/<repo-name>/.gitignore
```

Tell the user: "I've created `~/Code/<repo-name>/`. Please fill in the AGENTS.md with your stack, install command, and any initial notes. I'll wait."

Wait for confirmation before continuing.

**If no:**

Print: "Repos will be identified during /wf-tasks when you break the spec into tasks."

**5b. Program auto-stubs (program type only)**

If `<project_type>` is `"program"`:

Ask: "List child project names and types (e.g., `auth-api:code, user-research:research`):"

For each child entry:
1. Slugify the name.
2. Create `<project_dir>/<child-slug>/status.json` with:
   ```json
   {
     "project": "<child-name>",
     "slug": "<child-slug>",
     "stage": "new",
     "project_type": "<child-type>",
     "repos": [],
     "branch": "chris/<child-slug>",
     "worktrees": {},
     "active_agents": [],
     "conflicts": [],
     "pr_url": null,
     "tags": [],
     "children": [],
     "created": "<current ISO8601>",
     "updated": "<current ISO8601>"
   }
   ```
3. Add the child slug to the parent's `children[]` array in `status.json`.

Print: `Created N child project stubs.`

**6. AgentOS install (optional)**

Ask: "Set up AgentOS standards in this repo? (y/n)"

- **If y:**
  1. Read `agent_os_path` from `~/.chris/config.yml`. If the file does not exist or the key is not set, print:
     ```
     ⚠️  AgentOS path not configured. Run /wf-init to set it up, or clone
         AgentOS and run the install script manually:
         git clone https://github.com/buildermethods/agent-os ~/your/path/agent-os
         bash ~/your/path/agent-os/scripts/project-install.sh
     ```
     Then skip the AgentOS install step.
  2. If the path is configured and the directory exists on disk, run from the repo directory:
     ```bash
     bash <agent-os-path>/scripts/project-install.sh
     ```
  3. Print:
     ```
     ✅ AgentOS installed in ~/Code/<repo>/agent-os/
        Run /discover-standards inside <repo> to extract standards from your codebase.
        Edit agent-os/standards/global/tech-stack.md to document your stack.
     ```
- **If n:** Skip silently.

**7. Taskfile.yml generation (optional)**

Ask: "Generate a Taskfile.yml for this repo? (y/n)"

- **If y:** Write `Taskfile.yml` to the repo root with the content below (substitute the project slug for `<project-slug>`). Commit it alongside AGENTS.md.
  ```yaml
  # Generated by Chris /wf-new. Edit freely.
  version: '3'

  vars:
    SLUG: <project-slug>

  tasks:
    prd:
      desc: Write the PRD
      cmds: [claude "/wf-prd {{.SLUG}}"]
    spec:
      desc: Generate the technical spec
      cmds: [claude "/wf-spec {{.SLUG}}"]
    tasks:
      desc: Break the spec into tasks
      cmds: [claude "/wf-tasks {{.SLUG}}"]
    build:
      desc: Spawn a build agent for the next task
      cmds: [claude "/wf-build {{.SLUG}}"]
    review:
      desc: Review work and open draft PR on pass
      cmds: [claude "/wf-review {{.SLUG}}"]
    status:
      desc: Show project status
      cmds: [claude --print "/wf-status {{.SLUG}}"]
  ```
- **If n:** Skip silently.

**8. Commit to projects repo**

```bash
git -C ~/Code/chris/projects add <slug>/ && git -C ~/Code/chris/projects commit -m "docs: init project <slug>"
```

**9. Print confirmation**

For `code` projects:
```
✅ Project '<slug>' created.

Next step: /wf-prd-research (optional) or /wf-prd
  Run /wf-prd-research to investigate the market before writing the PRD, or skip straight to /wf-prd.
```

For all other project types (`research`, `investigation`, `writing`, `communication`, `program`):
```
✅ Project '<slug>' created.

Next step: /wf-plan
  Write the Plan document for this project.
```
