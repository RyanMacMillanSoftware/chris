#!/usr/bin/env bash
set -euo pipefail

# Chris Workflow Manager — Install Script
# Sets up symlinks, vault directories, and config.

CHRIS_DIR="$HOME/Code/chris"
CHRIS_CONFIG_DIR="$HOME/.chris"
CLAUDE_COMMANDS_DIR="$HOME/.claude/commands"
CLAUDE_AGENTS_DIR="$HOME/.claude/agents"

echo "🔧 Chris Installer"
echo "==================="
echo ""

# 1. Verify Chris repo exists
if [ ! -d "$CHRIS_DIR" ]; then
  echo "❌ Chris repo not found at $CHRIS_DIR"
  echo "   Clone it first: git clone <repo-url> ~/Code/chris"
  exit 1
fi

# 2. Create ~/.chris/ if missing
mkdir -p "$CHRIS_CONFIG_DIR"
echo "✅ Config directory: $CHRIS_CONFIG_DIR"

# 3. Prompt for vault path
echo ""
read -rp "Obsidian vault path? (leave blank to skip): " vault_path
if [ -n "$vault_path" ]; then
  # Expand ~ if present
  vault_path="${vault_path/#\~/$HOME}"
  mkdir -p "$vault_path/Projects"
  echo "vault_path: $vault_path" > "$CHRIS_CONFIG_DIR/config.yml"
  echo "✅ Vault path set: $vault_path"
  echo "   Created: $vault_path/Projects/"
else
  # Start config file without vault_path (or preserve existing)
  if [ ! -f "$CHRIS_CONFIG_DIR/config.yml" ]; then
    touch "$CHRIS_CONFIG_DIR/config.yml"
  fi
  echo "⏭️  Vault path skipped"
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

# 5. Create projects directory
mkdir -p "$CHRIS_DIR/projects"
echo ""
echo "✅ Projects directory: $CHRIS_DIR/projects/"

# 6. Symlink skills to ~/.claude/commands/
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
echo "✅ Symlinked $skill_count skills to $CLAUDE_COMMANDS_DIR/"

# 7. Symlink agents to ~/.claude/agents/
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

# 8. Check gh auth
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

# 9. Summary
echo ""
echo "==================="
echo "✅ Chris installed!"
echo ""
echo "  Skills: $skill_count symlinked"
echo "  Agents: $agent_count symlinked"
if [ -n "$vault_path" ]; then
  echo "  Vault:  $vault_path"
fi
echo ""
echo "Next steps:"
echo "  cd ~/Code/chris && claude"
echo "  /wf-new   — create a new project"
echo "  /wf-status — see all projects"
