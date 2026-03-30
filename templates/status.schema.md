# status.json Schema

Every project has a `status.json` file in its project directory. This document defines all fields, types, and valid values.

## Top-Level Fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `project` | string | yes | — | Human-readable project name |
| `slug` | string | yes | — | Kebab-case identifier, unique across all projects |
| `stage` | enum | yes | `"new"` | Current lifecycle stage (see Stage enum) |
| `project_type` | enum | yes | `"code"` | Project type (see Project Type enum) |
| `repos` | string[] | yes | `[]` | Repository names this project touches |
| `branch` | string | yes | — | Git branch name, format: `chris/<slug>` |
| `worktrees` | object | yes | `{}` | Map of repo name → worktree absolute path |
| `active_agents` | object[] | yes | `[]` | Currently running agent sessions (see Active Agent) |
| `conflicts` | object[] | yes | `[]` | Detected file conflicts with other projects (see Conflict) |
| `pr_url` | string\|null | yes | `null` | GitHub PR URL, set by `/wf-review` |
| `tags` | string[] | yes | `[]` | Freeform labels for filtering in `/wf-status` |
| `children` | string[] | yes | `[]` | Child project slugs; used by `program` type only |
| `created` | string | yes | — | ISO-8601 timestamp of project creation |
| `updated` | string | yes | — | ISO-8601 timestamp of last status change |
| `closed_at` | string\|null | yes | `null` | ISO-8601 timestamp of project closure, set by `/wf-done` |

## Project Type Enum

| Value | Description |
|-------|-------------|
| `code` | Software implementation — uses PRD → SPEC → TASKS pipeline |
| `research` | Deep research with cited sources — uses PLAN pipeline |
| `investigation` | Data-driven diagnosis (debugging, root-cause analysis) — uses PLAN pipeline |
| `writing` | Long-form content drafting — uses PLAN pipeline |
| `communication` | Message drafting for Slack, email, Notion — uses PLAN pipeline |
| `program` | Compound project with child projects — uses PLAN pipeline |

## Stage Enum

| Value | Description |
|-------|-------------|
| `new` | Project registered, no planning done yet |
| `prd` | PRD written (code projects only) |
| `spec` | Technical spec written (code projects only) |
| `tasks` | Tasks broken out, branches created (code projects only) |
| `plan` | Plan written (non-code projects only) |
| `build` | Active work in progress |
| `review` | Work complete, under review |
| `done` | Project closed and archived |

## Stage Validity by Project Type

| Type | Valid Stages |
|------|-------------|
| `code` | new → prd → spec → tasks → build → review → done |
| `research` | new → plan → build → review → done |
| `investigation` | new → plan → build → review → done |
| `writing` | new → plan → build → review → done |
| `communication` | new → plan → build → review → done |
| `program` | new → plan → build → review → done |

## Sub-Object Schemas

### Active Agent

```json
{
  "task": "TASK-NNN",
  "started_at": "<ISO-8601>"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `task` | string | Task identifier from TASKS.md |
| `started_at` | string | ISO-8601 timestamp when the agent was spawned |

### Conflict

```json
{
  "repo": "repo-name",
  "competing_project": "other-slug",
  "files": ["src/auth/session.ts"],
  "detected_at": "<ISO-8601>",
  "resolved": false
}
```

| Field | Type | Description |
|-------|------|-------------|
| `repo` | string | Repository where the conflict exists |
| `competing_project` | string | Slug of the other project touching the same files |
| `files` | string[] | List of overlapping file paths |
| `detected_at` | string | ISO-8601 timestamp when detected |
| `resolved` | boolean | Whether the conflict has been manually resolved |

## Example

```json
{
  "project": "Forge Backport Improvements",
  "slug": "forge-backport-improvements",
  "stage": "build",
  "project_type": "code",
  "repos": ["chris"],
  "branch": "chris/forge-backport-improvements",
  "worktrees": {},
  "active_agents": [
    {"task": "TASK-001", "started_at": "2026-03-30T10:00:00Z"}
  ],
  "conflicts": [],
  "pr_url": null,
  "tags": ["infrastructure", "backport"],
  "children": [],
  "created": "2026-03-29T00:00:00Z",
  "updated": "2026-03-30T10:00:00Z",
  "closed_at": null
}
```
