#!/usr/bin/env bash
set -euo pipefail

# Chris Workflow Manager — Install Script
# Sets up symlinks, vault directories, git tracking, and config.

# Auto-detect Chris repo location from this script's path
CHRIS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CHRIS_CONFIG_DIR="$HOME/.chris"
CLAUDE_COMMANDS_DIR="$HOME/.claude/commands"
CLAUDE_AGENTS_DIR="$HOME/.claude/agents"

echo "🔧 Chris Installer"
echo "==================="
echo ""

# 1. Verify Chris repo exists
if [ ! -f "$CHRIS_DIR/README.md" ] || [ ! -d "$CHRIS_DIR/skills" ]; then
  echo "❌ Chris repo not found at $CHRIS_DIR"
  echo "   Run this script from within the chris repo."
  exit 1
fi
echo "✅ Chris repo: $CHRIS_DIR"

# 2. Create ~/.chris/ if missing
mkdir -p "$CHRIS_CONFIG_DIR"
echo "✅ Config directory: $CHRIS_CONFIG_DIR"

# 3. Prompt for vault path
echo ""
read -rp "Obsidian vault path? (leave blank to skip): " vault_path
if [ -n "$vault_path" ]; then
  # Expand ~ if present
  vault_path="${vault_path/#\~/$HOME}"
  echo "vault_path: $vault_path" > "$CHRIS_CONFIG_DIR/config.yml"
  echo "✅ Vault path set: $vault_path"

  # 3a. Create vault Projects directory
  mkdir -p "$vault_path/Projects"
  echo "   Created: $vault_path/Projects/"

  # 3b. Create .stignore to exclude .git from Syncthing
  if [ ! -f "$vault_path/.stignore" ] || ! grep -q "Projects/.git" "$vault_path/.stignore" 2>/dev/null; then
    echo "Projects/.git" >> "$vault_path/.stignore"
    echo "   Created: .stignore (excludes Projects/.git from Syncthing)"
  fi

  # 3c. Initialize git repo in vault Projects if not already a repo
  if [ ! -d "$vault_path/Projects/.git" ]; then
    echo ""
    read -rp "Git repo URL for projects? (leave blank to init local-only): " projects_repo_url
    cd "$vault_path/Projects"
    git init
    git branch -m main 2>/dev/null || true
    if [ -n "$projects_repo_url" ]; then
      git remote add origin "$projects_repo_url"
      echo "   Fetching from remote..."
      if git fetch origin 2>/dev/null; then
        git reset origin/main 2>/dev/null || true
        git branch --set-upstream-to=origin/main main 2>/dev/null || true
      fi
    fi
    # Commit any existing files
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
      git add -A
      git commit -m "chore: init projects"
    fi
    cd "$CHRIS_DIR"
    echo "✅ Git repo initialized in $vault_path/Projects/"
  else
    echo "   Git repo already exists in $vault_path/Projects/"
  fi

  # 3d. Symlink projects/ to vault
  if [ -L "$CHRIS_DIR/projects" ]; then
    echo "   Symlink already exists: projects/ → $(readlink "$CHRIS_DIR/projects")"
  elif [ -d "$CHRIS_DIR/projects" ]; then
    # Move any local-only projects to vault before replacing
    for project_dir in "$CHRIS_DIR/projects"/*/; do
      slug=$(basename "$project_dir")
      if [ "$slug" = "*" ]; then break; fi
      if [ ! -L "$project_dir" ] && [ ! -d "$vault_path/Projects/$slug" ]; then
        mv "$project_dir" "$vault_path/Projects/$slug"
        echo "   Migrated: $slug → vault"
      fi
    done
    rm -rf "$CHRIS_DIR/projects"
    ln -s "$vault_path/Projects" "$CHRIS_DIR/projects"
    echo "✅ projects/ → $vault_path/Projects/ (symlink)"
  else
    ln -s "$vault_path/Projects" "$CHRIS_DIR/projects"
    echo "✅ projects/ → $vault_path/Projects/ (symlink)"
  fi

  # 3e. Clean up chris-projects remote from framework repo if present
  if git -C "$CHRIS_DIR" remote get-url chris-projects &>/dev/null; then
    git -C "$CHRIS_DIR" remote remove chris-projects
    echo "   Removed stale 'chris-projects' remote from framework repo"
  fi

else
  # No vault — use local projects directory
  if [ ! -f "$CHRIS_CONFIG_DIR/config.yml" ]; then
    touch "$CHRIS_CONFIG_DIR/config.yml"
  fi
  mkdir -p "$CHRIS_DIR/projects"
  echo "⏭️  Vault path skipped"
  echo "✅ Projects directory: $CHRIS_DIR/projects/"
fi

# 4. Prompt for AgentOS path
echo ""
read -rp "AgentOS path? (leave blank to skip): " agent_os_path
if [ -n "$agent_os_path" ]; then
  agent_os_path="${agent_os_path/#\~/$HOME}"
  if grep -q "agent_os_path:" "$CHRIS_CONFIG_DIR/config.yml" 2>/dev/null; then
    sed -i '' "s|agent_os_path:.*|agent_os_path: $agent_os_path|" "$CHRIS_CONFIG_DIR/config.yml"
  else
    echo "agent_os_path: $agent_os_path" >> "$CHRIS_CONFIG_DIR/config.yml"
  fi
  echo "✅ AgentOS path set: $agent_os_path"
else
  echo "⏭️  AgentOS path skipped"
fi

# 5. Symlink skills to ~/.claude/commands/
mkdir -p "$CLAUDE_COMMANDS_DIR"
skill_count=0
for skill_dir in "$CHRIS_DIR"/skills/wf-*/; do
  skill_name=$(basename "$skill_dir")
  if [ -f "$skill_dir/SKILL.md" ]; then
    ln -sf "$skill_dir/SKILL.md" "$CLAUDE_COMMANDS_DIR/$skill_name.md"
    skill_count=$((skill_count + 1))
  fi
done
# Also symlink chris-guide
if [ -f "$CHRIS_DIR/skills/chris-guide/SKILL.md" ]; then
  ln -sf "$CHRIS_DIR/skills/chris-guide/SKILL.md" "$CLAUDE_COMMANDS_DIR/chris-guide.md"
  skill_count=$((skill_count + 1))
fi
echo ""
echo "✅ Symlinked $skill_count skills to $CLAUDE_COMMANDS_DIR/"

# 6. Symlink agents to ~/.claude/agents/
mkdir -p "$CLAUDE_AGENTS_DIR"
agent_count=0
for agent_file in "$CHRIS_DIR"/agents/*.md; do
  if [ -f "$agent_file" ]; then
    agent_name=$(basename "$agent_file")
    ln -sf "$agent_file" "$CLAUDE_AGENTS_DIR/$agent_name"
    agent_count=$((agent_count + 1))
  fi
done
echo "✅ Symlinked $agent_count agents to $CLAUDE_AGENTS_DIR/"

# 7. Check gh auth
echo ""
if command -v gh &>/dev/null; then
  if gh auth status &>/dev/null; then
    echo "✅ GitHub CLI authenticated"
  else
    echo "⚠️  GitHub CLI not authenticated. Run: gh auth login"
  fi
else
  echo "⚠️  GitHub CLI (gh) not found. Install it for PR management."
fi

# 8. Summary
echo ""
echo "==================="
echo "✅ Chris installed!"
echo ""
echo "  Skills: $skill_count symlinked"
echo "  Agents: $agent_count symlinked"
if [ -n "$vault_path" ]; then
  echo "  Vault:  $vault_path"
  echo "  Git:    $vault_path/Projects/ (chris-projects repo)"
fi
echo ""
echo "Next steps:"
echo "  cd $CHRIS_DIR && claude"
echo "  /wf-new   — create a new project"
echo "  /wf-status — see all projects"
