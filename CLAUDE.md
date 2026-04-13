# Chris — Workflow Manager

Chris orchestrates projects through a fixed pipeline from idea to completion. Projects follow one of two tracks:

- **Code projects:** `new → [prd-research] → prd → [spec-research] → spec → tasks → build → review → done` (7+ stages, research stages optional)
- **Non-code projects:** `new → plan → build → review → done` (5 stages)

Use `/wf-status` to see your projects and their stages, `/wf-new` to register a project, and `/wf-build` plus `/wf-review`/`/wf-done` for the hands-on work and wrap-up. Code projects use `/wf-prd → /wf-spec → /wf-tasks` for planning; non-code projects use `/wf-plan`.

Whenever you need the full command set, document expectations, folder layout, gating rules, or formats, run `/chris-guide` (or open `skills/chris-guide/SKILL.md`).

Need repo context or local conventions? Keep the repo-level `AGENTS.md` up to date; it follows the template in `templates/AGENTS.md` and is the first thing every agent loads. Agent behaviour specs live in `agents/` — these define how subagents (research-analyst, investigator, writer, communicator) behave when spawned by skills.

**Setup:** Run `scripts/install.sh` to symlink skills and agents, configure vault backing, and set up paths.

# Bash Commands

Avoid newlines inside a single Bash tool call — use `&&` or `;` to chain commands on one line. Newlines in Bash calls trigger a permissions prompt.

# Domain Rules

## Code Projects

- Follow conventional commits (`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`).
- Every new feature or bug fix must have a corresponding test; tests must pass before the stage advances to review.
- Stack preferences: use the language and framework already present in the repo; do not introduce new runtime dependencies without explicit user approval.
- Branch naming: `<project-slug>/<short-description>`; never commit directly to `main`.
- Keep `AGENTS.md` up to date in any repo you touch.

## Research Projects

- Prefer primary sources, peer-reviewed publications, and official documentation over secondary summaries.
- Save all research output to the project's `research/` directory.
- Cite every source as a markdown link including the page title and the date accessed, e.g. `[Title](https://example.com) — accessed 2026-03-09`.

## Investigation Projects

- Follow the Orient → Query → Correlate → Document methodology.
- Every claim must be backed by query results or data evidence.
- Save findings to the project's `research/` directory.
- Time-bound all queries with explicit lookback windows.

## Writing Projects

- Save all draft output to the project's `drafts/` directory.
- All deliverables must be in markdown format.
- The stage does not advance from build to review until the author has read the draft and explicitly approved it.

## Communication Projects

- **NEVER send messages without explicit user approval** — draft only.
- Save drafts to the project's `drafts/` directory.
- Include channel-appropriate "Sent via Claude Code" signature.
- Two explicit approvals required before any external send action.

## Program Projects

- A program coordinates multiple child projects toward a shared outcome.
- Children are tracked via the `children[]` array in `status.json`.
- The program is complete when all children reach stage `"done"`.

<!-- rtk-instructions v2 -->
# RTK (Rust Token Killer) - Token-Optimized Commands

## Golden Rule

**Always prefix commands with `rtk`**. If RTK has a dedicated filter, it uses it. If not, it passes through unchanged. This means RTK is always safe to use.

**Important**: Even in command chains with `&&`, use `rtk`:
```bash
# ❌ Wrong
git add . && git commit -m "msg" && git push

# ✅ Correct
rtk git add . && rtk git commit -m "msg" && rtk git push
```

## RTK Commands by Workflow

### Build & Compile (80-90% savings)
```bash
rtk cargo build         # Cargo build output
rtk cargo check         # Cargo check output
rtk cargo clippy        # Clippy warnings grouped by file (80%)
rtk tsc                 # TypeScript errors grouped by file/code (83%)
rtk lint                # ESLint/Biome violations grouped (84%)
rtk prettier --check    # Files needing format only (70%)
rtk next build          # Next.js build with route metrics (87%)
```

### Test (90-99% savings)
```bash
rtk cargo test          # Cargo test failures only (90%)
rtk vitest run          # Vitest failures only (99.5%)
rtk playwright test     # Playwright failures only (94%)
rtk test <cmd>          # Generic test wrapper - failures only
```

### Git (59-80% savings)
```bash
rtk git status          # Compact status
rtk git log             # Compact log (works with all git flags)
rtk git diff            # Compact diff (80%)
rtk git show            # Compact show (80%)
rtk git add             # Ultra-compact confirmations (59%)
rtk git commit          # Ultra-compact confirmations (59%)
rtk git push            # Ultra-compact confirmations
rtk git pull            # Ultra-compact confirmations
rtk git branch          # Compact branch list
rtk git fetch           # Compact fetch
rtk git stash           # Compact stash
rtk git worktree        # Compact worktree
```

Note: Git passthrough works for ALL subcommands, even those not explicitly listed.

### GitHub (26-87% savings)
```bash
rtk gh pr view <num>    # Compact PR view (87%)
rtk gh pr checks        # Compact PR checks (79%)
rtk gh run list         # Compact workflow runs (82%)
rtk gh issue list       # Compact issue list (80%)
rtk gh api              # Compact API responses (26%)
```

### JavaScript/TypeScript Tooling (70-90% savings)
```bash
rtk pnpm list           # Compact dependency tree (70%)
rtk pnpm outdated       # Compact outdated packages (80%)
rtk pnpm install        # Compact install output (90%)
rtk npm run <script>    # Compact npm script output
rtk npx <cmd>           # Compact npx command output
rtk prisma              # Prisma without ASCII art (88%)
```

### Files & Search (60-75% savings)
```bash
rtk ls <path>           # Tree format, compact (65%)
rtk read <file>         # Code reading with filtering (60%)
rtk grep <pattern>      # Search grouped by file (75%)
rtk find <pattern>      # Find grouped by directory (70%)
```

### Analysis & Debug (70-90% savings)
```bash
rtk err <cmd>           # Filter errors only from any command
rtk log <file>          # Deduplicated logs with counts
rtk json <file>         # JSON structure without values
rtk deps                # Dependency overview
rtk env                 # Environment variables compact
rtk summary <cmd>       # Smart summary of command output
rtk diff                # Ultra-compact diffs
```

### Infrastructure (85% savings)
```bash
rtk docker ps           # Compact container list
rtk docker images       # Compact image list
rtk docker logs <c>     # Deduplicated logs
rtk kubectl get         # Compact resource list
rtk kubectl logs        # Deduplicated pod logs
```

### Network (65-70% savings)
```bash
rtk curl <url>          # Compact HTTP responses (70%)
rtk wget <url>          # Compact download output (65%)
```

### Meta Commands
```bash
rtk gain                # View token savings statistics
rtk gain --history      # View command history with savings
rtk discover            # Analyze Claude Code sessions for missed RTK usage
rtk proxy <cmd>         # Run command without filtering (for debugging)
rtk init                # Add RTK instructions to CLAUDE.md
rtk init --global       # Add RTK to ~/.claude/CLAUDE.md
```

## Token Savings Overview

| Category | Commands | Typical Savings |
|----------|----------|-----------------|
| Tests | vitest, playwright, cargo test | 90-99% |
| Build | next, tsc, lint, prettier | 70-87% |
| Git | status, log, diff, add, commit | 59-80% |
| GitHub | gh pr, gh run, gh issue | 26-87% |
| Package Managers | pnpm, npm, npx | 70-90% |
| Files | ls, read, grep, find | 60-75% |
| Infrastructure | docker, kubectl | 85% |
| Network | curl, wget | 65-70% |

Overall average: **60-90% token reduction** on common development operations.
<!-- /rtk-instructions -->