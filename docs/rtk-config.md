# RTK (Rust Token Killer) Configuration

RTK is a CLI proxy that compresses tool output before it reaches the LLM context window, reducing token consumption by 60-90% on common development operations.

## Installation Summary

### Global (applies to all Claude Code sessions)

Installed via `rtk init -g --auto-patch`. This added:

| Artifact | Path | Purpose |
|----------|------|---------|
| PreToolUse hook | `~/.claude/settings.json` | Rewrites Bash commands to use `rtk` |
| Hook script | `~/.claude/hooks/rtk-rewrite.sh` | Delegates rewrite logic to `rtk rewrite` |
| RTK.md | `~/.claude/RTK.md` | Meta-command reference (gain, discover) |
| CLAUDE.md ref | `~/.claude/CLAUDE.md` | `@RTK.md` include for global instructions |

### Per-Rig (project-level instructions)

Installed via `rtk init --auto-patch` in each rig's project directory:

| Rig | Directory | Result |
|-----|-----------|--------|
| chris | `/Users/ryan/gt/chris/` (via worktree) | CLAUDE.md updated, `.rtk/filters.toml` created |
| molly_android | `/Users/ryan/Code/molly-android` | CLAUDE.md updated, `.rtk/filters.toml` created |
| molly_api | `/Users/ryan/Code/molly-api` | CLAUDE.md updated, `.rtk/filters.toml` created |
| molly_astro | `/Users/ryan/Code/molly-astro` | CLAUDE.md updated, `.rtk/filters.toml` created |
| molly_ios | `/Users/ryan/Code/molly-ios` | CLAUDE.md updated, `.rtk/filters.toml` created |
| victory | `/Users/ryan/Code/victory` | CLAUDE.md created, `.rtk/filters.toml` created |

## How It Works

The PreToolUse hook in `~/.claude/settings.json` intercepts all Bash tool calls:

```
Agent calls: git status
  -> PreToolUse hook fires
  -> rtk-rewrite.sh reads the command
  -> rtk rewrite "git status" -> "rtk git status" (exit 3: ask)
  -> Hook returns updated command to Claude Code
  -> Agent sees compressed output (48% fewer tokens for git status)
```

Exit codes from `rtk rewrite`:
- `0`: Auto-allow (safe rewrite, no prompt)
- `1`: No RTK equivalent (pass through unchanged)
- `2`: Deny rule matched (pass through)
- `3`: Ask rule matched (rewrite but prompt user)

## Token Savings by Category

| Category | Commands | Typical Savings |
|----------|----------|-----------------|
| Tests | vitest, playwright, cargo test | 90-99% |
| Build | next, tsc, lint, prettier | 70-87% |
| Git | status, log, diff, add, commit | 59-80% |
| GitHub | gh pr, gh run, gh issue | 26-87% |
| Package Managers | pnpm, npm, npx | 70-90% |
| Files | ls, read, grep, find | 60-75% |
| Infrastructure | docker, kubectl | 85% |

## Monitoring

```bash
rtk gain              # Current session savings
rtk gain --history    # Command history with savings
rtk discover          # Find missed RTK opportunities in Claude Code history
rtk cc-economics      # Spending vs savings analysis
```

## Custom Filters

Per-project filters live in `.rtk/filters.toml`. Edit to add project-specific output compression rules. See the template in any rig's `.rtk/filters.toml`.
