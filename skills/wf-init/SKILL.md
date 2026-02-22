---
description: "Bootstrap Chris on a new machine. Run once after cloning."
---

# /wf-init

Bootstrap Chris on this machine. Run this once after cloning the repo, or to repair a broken setup.

## Steps

**1. Check the tool repo exists**

Check if `~/Code/chris/` exists. If not, print:
```
❌ ~/Code/chris/ not found.
Clone it first: git clone https://github.com/<your-username>/chris ~/Code/chris
```
Then stop.

**2. Initialise the projects repo**

Check if `~/Code/chris/projects/` exists. If not, create it.
Check if `~/Code/chris/projects/.git/` exists. If not:
- `cd ~/Code/chris/projects && git init && git checkout -b main`
- Print: `✅ Initialised projects repo`

If it already exists, print: `✅ Projects repo already initialised`

**3. Create meta-projects if missing**

Check for `~/Code/chris/projects/chris/`. If missing:
- Create the directory
- Create `~/Code/chris/projects/chris/status.json` with content:
  ```json
  {
    "project": "chris",
    "slug": "chris",
    "stage": "new",
    "repos": ["chris"],
    "branch": "chris/chris",
    "worktrees": {},
    "active_agents": [],
    "conflicts": [],
    "pr_url": null,
    "created": "<current ISO8601 timestamp>",
    "updated": "<current ISO8601 timestamp>"
  }
  ```
- Print: `✅ Created meta-project: chris`

Check for `~/Code/chris/projects/workflow-improvements/`. If missing:
- Create the directory
- Copy `~/Code/chris/AGENTS.md` to `~/Code/chris/projects/workflow-improvements/AGENTS.md`
- Print: `✅ Created meta-project: workflow-improvements`

**4. Symlink skills into ~/.claude/commands/**

Run:
```bash
mkdir -p ~/.claude/commands
for skill in ~/Code/chris/skills/wf-*/SKILL.md; do
  name=$(basename $(dirname $skill))
  ln -sf "$skill" ~/.claude/commands/${name}.md
  echo "  ✅ /$(echo $name | tr '-' '-')"
done
```

If any symlink already exists and points to the right place, skip silently. If it points elsewhere, overwrite and note it.

**5. Verify gh CLI**

Run `gh auth status 2>&1`. If it fails or returns unauthenticated:
- Print: `⚠️  gh CLI not authenticated. Run: gh auth login`
- Continue (don't abort — not everything needs gh)

If authenticated, print: `✅ gh CLI authenticated`

**6. Print setup summary**

```
✅ Chris initialised successfully.

Skills installed:
  /wf-new    /wf-prd    /wf-spec   /wf-tasks
  /wf-build  /wf-review /wf-done   /wf-status
  /wf-research

⚠️  One manual step required — set up the private projects remote:

  cd ~/Code/chris/projects
  git add -A && git commit -m "docs: init" (if needed)
  gh repo create chris-projects --private --source=. --push

  Or manually:
  git remote add origin git@github.com:<username>/chris-projects.git
  git push -u origin main

See ~/Code/chris/README.md for full setup instructions.
```
