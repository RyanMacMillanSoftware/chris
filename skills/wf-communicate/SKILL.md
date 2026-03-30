---
description: "Draft a communication for a communication-type project. Never sends without approval."
---

# /wf-communicate

Build wrapper for communication-type projects. Reads the plan, spawns a communicator agent to draft the message, and presents the draft with an approval gate. **NEVER sends without explicit user approval.**

`$ARGUMENTS` — optional project slug

## Detect the current project

1. If `$ARGUMENTS` is provided, use that slug. Check the project directory exists (resolved per `skills/_shared/paths.md`).
2. Else scan all project `status.json` files for projects with `project_type == "communication"` and stage `"plan"` or `"build"`. If one match, use it. If multiple, ask.
3. If none found, suggest running `/wf-new` first.

## Validate type

Read `project_type` from `status.json`. If it is not `"communication"`:
```
❌ Project '<slug>' is type '<type>', not communication. Use /wf-build instead.
```
Stop.

## Read the plan

Read `PLAN.md` from the project directory. Extract:
- **Audience** — who the message is for
- **Channel** — delivery channel (slack / email / notion)
- **Key Messages** — the core points to convey, in priority order
- **Tone** — voice and style

## Spawn communicator agent

Spawn a subagent referencing `agents/communicator.md` with:

```
You are working on project '<slug>', communication draft.
Working directory: <project_dir>/drafts/

## Plan context
Audience: <audience from PLAN.md>
Channel: <channel from PLAN.md>
Key Messages:
<numbered list from PLAN.md>
Tone: <tone from PLAN.md>

## Instructions
- Draft the message following channel-specific formatting rules from agents/communicator.md
- Save draft to: <project_dir>/drafts/<channel>.md
- Write handoff to: <project_dir>/handoffs/
- Include "Sent via Claude Code" signature appropriate to the channel
- Do NOT send, post, or publish anything
- Do not set up git worktrees, branches, or make git commits
```

## Approval gate

After the agent completes, present the full draft to the user with AskUserQuestion:

**Options:**
1. **Approve & send** — User confirms the draft is ready. If MCP tools are available for the channel, offer to send (with one final confirmation). Otherwise, print the draft for manual sending.
2. **Revise** — User provides feedback. Re-run the communicator with the feedback appended.
3. **Save draft only** — Print the draft file location. Do not send.

**CRITICAL:** Never send a message without the user selecting "Approve & send" AND confirming the final send action. Two explicit approvals are required before any external action.

## Update status

Set `status.json.stage` to `"build"` if not already. Update `updated` timestamp.

## Print confirmation

```
🟢 Communication draft started: <slug>
   Channel: <channel>
   Audience: <audience summary>
   Draft location: <project_dir>/drafts/<channel>.md
```
