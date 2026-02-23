#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skills_dir="${repo_root}/skills"
mirror_dir="${repo_root}/agents/skills"

if [[ ! -d "${skills_dir}" || ! -d "${mirror_dir}" ]]; then
  echo "ERROR: expected directories '${skills_dir}' and '${mirror_dir}'"
  exit 1
fi

tmp_skills="$(mktemp)"
tmp_mirror="$(mktemp)"
trap 'rm -f "${tmp_skills}" "${tmp_mirror}"' EXIT

find "${skills_dir}" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort > "${tmp_skills}"
find "${mirror_dir}" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort > "${tmp_mirror}"

missing_in_mirror="$(comm -23 "${tmp_skills}" "${tmp_mirror}" || true)"
extra_in_mirror="$(comm -13 "${tmp_skills}" "${tmp_mirror}" || true)"

if [[ -n "${missing_in_mirror}" ]]; then
  echo "ERROR: missing skill directories in agents/skills:"
  echo "${missing_in_mirror}" | sed 's/^/  - /'
  exit 1
fi

if [[ -n "${extra_in_mirror}" ]]; then
  echo "ERROR: extra skill directories in agents/skills not present in skills/:"
  echo "${extra_in_mirror}" | sed 's/^/  - /'
  exit 1
fi

echo "OK: skill directory sets match."

drift=0
intentional_drift_skills=("wf-build")
while IFS= read -r skill_name; do
  src_file="${skills_dir}/${skill_name}/SKILL.md"
  mirror_file="${mirror_dir}/${skill_name}/SKILL.md"

  if [[ ! -f "${src_file}" || ! -f "${mirror_file}" ]]; then
    echo "ERROR: missing SKILL.md for '${skill_name}'"
    exit 1
  fi

  if ! diff -q "${src_file}" "${mirror_file}" > /dev/null; then
    intentional=0
    for allowed_skill in "${intentional_drift_skills[@]}"; do
      if [[ "${skill_name}" == "${allowed_skill}" ]]; then
        intentional=1
        break
      fi
    done

    if [[ "${intentional}" -eq 1 ]]; then
      echo "OK: intentional provider-specific drift for '${skill_name}'"
    else
      echo "WARN: content drift detected for '${skill_name}'"
      drift=1
    fi
  fi
done < "${tmp_skills}"

if [[ "${drift}" -eq 0 ]]; then
  echo "OK: no content drift detected."
else
  echo "WARN: one or more mirrored skills drift from canonical content."
fi
