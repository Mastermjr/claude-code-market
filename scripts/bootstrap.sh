#!/usr/bin/env bash
# @decision DEC-BOOTSTRAP-001
# @title One-command bootstrap: claude-ctrl + marketplace + plugins
# @status accepted
# @rationale Combines claude-ctrl installation with marketplace registration and plugin
#   installation into a single curl-pipe-bash script. Users on a fresh system can run one
#   command to get the full Mastermjr Claude Code setup. The script is idempotent — it
#   skips steps that are already done (existing ~/.claude, already-registered marketplaces).
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Mastermjr/claude-code-market/main/scripts/bootstrap.sh | bash
#
# What it does:
#   1. Backs up existing ~/.claude if present
#   2. Clones claude-ctrl into ~/.claude
#   3. Creates settings.local.json with recommended defaults
#   4. Prints next steps (run claude, install marketplaces + plugins)

set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"
CLAUDE_CTRL_REPO="https://github.com/Mastermjr/claude-ctrl.git"

echo "=== Mastermjr's Claude Code Bootstrap ==="
echo ""

# --- Step 1: Back up existing ~/.claude ---
if [ -d "$CLAUDE_DIR" ]; then
  BACKUP="${CLAUDE_DIR}.backup.$(date +%Y%m%d%H%M%S)"
  echo "[1/3] Backing up existing ~/.claude → $BACKUP"
  mv "$CLAUDE_DIR" "$BACKUP"
else
  echo "[1/3] No existing ~/.claude found — fresh install"
fi

# --- Step 2: Clone claude-ctrl ---
echo "[2/3] Cloning claude-ctrl into ~/.claude..."
git clone --recurse-submodules "$CLAUDE_CTRL_REPO" "$CLAUDE_DIR"

# --- Step 3: Create settings.local.json ---
SETTINGS_FILE="${CLAUDE_DIR}/settings.local.json"
if [ ! -f "$SETTINGS_FILE" ]; then
  echo "[3/3] Creating settings.local.json with recommended defaults..."
  cat > "$SETTINGS_FILE" << 'SETTINGS'
{
  "model": "opus",
  "enableAllProjectMcpServers": true
}
SETTINGS
else
  echo "[3/3] settings.local.json already exists — skipping"
fi

echo ""
echo "=== claude-ctrl installed ==="
echo ""
echo "Next: start Claude Code and run these commands to complete setup:"
echo ""
echo "  /plugin marketplace add Mastermjr/claude-code-market"
echo "  /plugin marketplace add astral-sh/claude-code-plugins"
echo ""
echo "  /plugin install atuin-history@claude-code-market"
echo "  /plugin install frontend-design@claude-plugins-official"
echo "  /plugin install context7@claude-plugins-official"
echo "  /plugin install astral@astral-sh"
echo ""
echo "Or run the guided setup skill after adding the marketplace:"
echo ""
echo "  /claude-code-market:setup"
echo ""
echo "Prerequisites: Atuin v18+ (atuin.sh), Node.js (nodejs.org), uvx (docs.astral.sh/uv)"
echo ""
