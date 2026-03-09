#!/usr/bin/env bash
# post-bash-test-pass.sh
# PostToolUse hook: fires after every Bash tool call.
# If a test runner passed and all tasks are complete for the current build-stage
# project, advances the project stage to "review".

CHRIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Read stdin once into a variable so we can parse multiple fields.
stdin_payload="$(cat)"

# 1. Extract exit_code and command from the PostToolUse JSON payload.
exit_code="$(printf '%s' "$stdin_payload" | jq -r '.tool_response.exit_code // empty')"
command_run="$(printf '%s' "$stdin_payload" | jq -r '.tool_input.command // empty')"

# 2. Exit 0 if the tool call failed (non-zero exit code).
if [ -z "$exit_code" ] || [ "$exit_code" != "0" ]; then
    exit 0
fi

# 3. Exit 0 if the command does not match a known test runner.
matched=0
case "$command_run" in
    *"npm test"*)   matched=1 ;;
    *"pytest"*)     matched=1 ;;
    *"cargo test"*) matched=1 ;;
    *"go test"*)    matched=1 ;;
    *"bun test"*)   matched=1 ;;
    *"jest"*)       matched=1 ;;
    *"vitest"*)     matched=1 ;;
esac

if [ "$matched" -eq 0 ]; then
    exit 0
fi

# 4. Determine the current repo slug from $PWD basename.
repo_slug="$(basename "$PWD")"

# Scan projects/*/status.json for a project where stage=="build" and the repo
# slug appears in the repos array.
matched_project=""
for status_file in "$CHRIS_DIR"/projects/*/status.json; do
    [ -f "$status_file" ] || continue

    stage="$(jq -r '.stage // empty' "$status_file")"
    [ "$stage" = "build" ] || continue

    # Check whether repo_slug is in the repos array.
    in_repos="$(jq -r --arg slug "$repo_slug" '
        if (.repos // []) | map(. == $slug) | any then "yes" else "no" end
    ' "$status_file")"

    if [ "$in_repos" = "yes" ]; then
        matched_project="$status_file"
        break
    fi
done

# 5. Exit 0 if no matching build-stage project was found.
if [ -z "$matched_project" ]; then
    exit 0
fi

# 6. Locate the project's TASKS.md (sits alongside status.json).
project_dir="$(dirname "$matched_project")"
tasks_file="$project_dir/TASKS.md"

if [ ! -f "$tasks_file" ]; then
    exit 0
fi

# Count unchecked task lines.
# Use -e to ensure the pattern is not misinterpreted as a flag (BSD grep issue
# with backslash-space). grep exits 0 if matches found, 1 if none, 2 on error.
unchecked="$(grep -c -e '- \[ \]' "$tasks_file" 2>/dev/null || echo 0)"

# 7. Exit 0 if any unchecked tasks remain.
if [ "$unchecked" -gt 0 ]; then
    exit 0
fi

# 8. Update status.json: set stage="review" and updated to current ISO timestamp.
iso_now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
tmp_file="$(mktemp)"
jq --arg ts "$iso_now" '.stage = "review" | .updated = $ts' "$matched_project" > "$tmp_file" && mv "$tmp_file" "$matched_project"

# 9. Print success message.
printf '✅ Tests passed + all tasks complete → stage advanced to "review". Run /wf-review.\n'
