#!/usr/bin/env bash
set -euo pipefail

payload=$(cat)

file_path=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')

if [[ -z "$file_path" ]]; then
  exit 0
fi

if [[ "$file_path" != *TASKS.md ]]; then
  exit 0
fi

if [[ ! -f "$file_path" ]]; then
  exit 0
fi

if grep -q -- '- \[ \]' "$file_path"; then
  exit 0
fi

printf '✅ All tasks marked complete. Run /wf-review when ready.\n'
exit 0
