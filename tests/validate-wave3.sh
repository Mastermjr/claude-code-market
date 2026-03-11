#!/usr/bin/env bash
# Validates Wave 3 additions: setup skill, README recommended section, plugin.json update
set -euo pipefail

ERRORS=0
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# --- W3-1: Setup skill ---
echo "=== W3-1: Setup Skill ==="

echo "Checking skills/setup/SKILL.md exists..."
[ -f "$REPO_ROOT/skills/setup/SKILL.md" ] || { echo "FAIL: skills/setup/SKILL.md missing"; ERRORS=$((ERRORS+1)); }

echo "Checking SKILL.md has YAML frontmatter..."
head -1 "$REPO_ROOT/skills/setup/SKILL.md" | grep -q "^---" || { echo "FAIL: SKILL.md missing frontmatter"; ERRORS=$((ERRORS+1)); }

echo "Checking SKILL.md declares name: setup..."
grep -q "^name: setup" "$REPO_ROOT/skills/setup/SKILL.md" || { echo "FAIL: name: setup not found in frontmatter"; ERRORS=$((ERRORS+1)); }

echo "Checking SKILL.md declares context: fork..."
grep -q "^context: fork" "$REPO_ROOT/skills/setup/SKILL.md" || { echo "FAIL: context: fork not found in frontmatter"; ERRORS=$((ERRORS+1)); }

echo "Checking SKILL.md includes marketplace add commands..."
grep -q "marketplace add Mastermjr/claude-code-market" "$REPO_ROOT/skills/setup/SKILL.md" || { echo "FAIL: Mastermjr marketplace command missing"; ERRORS=$((ERRORS+1)); }
grep -q "marketplace add astral-sh/claude-code-plugins" "$REPO_ROOT/skills/setup/SKILL.md" || { echo "FAIL: astral-sh marketplace command missing"; ERRORS=$((ERRORS+1)); }

echo "Checking SKILL.md includes all recommended plugin install commands..."
grep -q "atuin-history@claude-code-market" "$REPO_ROOT/skills/setup/SKILL.md" || { echo "FAIL: atuin-history install command missing"; ERRORS=$((ERRORS+1)); }
grep -q "frontend-design@claude-plugins-official" "$REPO_ROOT/skills/setup/SKILL.md" || { echo "FAIL: frontend-design install command missing"; ERRORS=$((ERRORS+1)); }
grep -q "context7@claude-plugins-official" "$REPO_ROOT/skills/setup/SKILL.md" || { echo "FAIL: context7 install command missing"; ERRORS=$((ERRORS+1)); }
grep -q "astral@astral-sh" "$REPO_ROOT/skills/setup/SKILL.md" || { echo "FAIL: astral install command missing"; ERRORS=$((ERRORS+1)); }

echo "Checking SKILL.md includes recommended settings..."
grep -q '"model"' "$REPO_ROOT/skills/setup/SKILL.md" || { echo "FAIL: model setting missing"; ERRORS=$((ERRORS+1)); }
grep -q '"enableAllProjectMcpServers"' "$REPO_ROOT/skills/setup/SKILL.md" || { echo "FAIL: enableAllProjectMcpServers setting missing"; ERRORS=$((ERRORS+1)); }
grep -q '"opus"' "$REPO_ROOT/skills/setup/SKILL.md" || { echo "FAIL: opus model value missing"; ERRORS=$((ERRORS+1)); }

echo "Checking SKILL.md includes prerequisites..."
grep -q "Atuin" "$REPO_ROOT/skills/setup/SKILL.md" || { echo "FAIL: Atuin prerequisite missing"; ERRORS=$((ERRORS+1)); }
grep -q "Node.js" "$REPO_ROOT/skills/setup/SKILL.md" || { echo "FAIL: Node.js prerequisite missing"; ERRORS=$((ERRORS+1)); }
grep -q "uvx" "$REPO_ROOT/skills/setup/SKILL.md" || { echo "FAIL: uvx prerequisite missing"; ERRORS=$((ERRORS+1)); }

echo "Checking SKILL.md has @decision DEC-MARKET-009 annotation..."
grep -q "DEC-MARKET-009" "$REPO_ROOT/skills/setup/SKILL.md" || { echo "FAIL: @decision DEC-MARKET-009 missing"; ERRORS=$((ERRORS+1)); }

# --- W3-2: README ---
echo ""
echo "=== W3-2: README Recommended Setup Section ==="

echo "Checking README has Recommended Setup section..."
grep -q "## Recommended Setup" "$REPO_ROOT/README.md" || { echo "FAIL: 'Recommended Setup' section missing from README"; ERRORS=$((ERRORS+1)); }

echo "Checking README references setup skill..."
grep -q "claude-code-market:setup" "$REPO_ROOT/README.md" || { echo "FAIL: setup skill reference missing from README"; ERRORS=$((ERRORS+1)); }

echo "Checking README references astral-sh marketplace..."
grep -q "astral-sh/claude-code-plugins" "$REPO_ROOT/README.md" || { echo "FAIL: astral-sh marketplace reference missing from README"; ERRORS=$((ERRORS+1)); }

echo "Checking README Recommended Setup appears before How It Works..."
python3 -c "
content = open('$REPO_ROOT/README.md').read()
pos_setup = content.find('## Recommended Setup')
pos_how = content.find('## How It Works')
if pos_setup == -1:
    print('FAIL: Recommended Setup not found')
    exit(1)
if pos_how == -1:
    print('FAIL: How It Works not found')
    exit(1)
if pos_setup >= pos_how:
    print('FAIL: Recommended Setup must appear before How It Works')
    exit(1)
print('  OK: Recommended Setup appears before How It Works')
" || ERRORS=$((ERRORS+1))

# --- W3-3: plugin.json ---
echo ""
echo "=== W3-3: plugin.json Update ==="

echo "Checking plugin.json is valid JSON..."
python3 -m json.tool "$REPO_ROOT/.claude-plugin/plugin.json" > /dev/null || { echo "FAIL: invalid JSON"; ERRORS=$((ERRORS+1)); }

echo "Checking plugin.json includes skills/setup..."
python3 -c "
import json
p = json.load(open('$REPO_ROOT/.claude-plugin/plugin.json'))
skills = p.get('skills', [])
if 'skills/setup' not in skills:
    print('FAIL: skills/setup not in skills array')
    exit(1)
print(f'  OK: skills array = {skills}')
" || ERRORS=$((ERRORS+1))

echo "Checking plugin.json version is 2.1.0..."
python3 -c "
import json
p = json.load(open('$REPO_ROOT/.claude-plugin/plugin.json'))
v = p.get('version', '')
if v != '2.1.0':
    print(f'FAIL: version is {v!r}, expected 2.1.0')
    exit(1)
print(f'  OK: version = {v}')
" || ERRORS=$((ERRORS+1))

echo "Checking plugin.json still includes skills/plugin-dev..."
python3 -c "
import json
p = json.load(open('$REPO_ROOT/.claude-plugin/plugin.json'))
skills = p.get('skills', [])
if 'skills/plugin-dev' not in skills:
    print('FAIL: skills/plugin-dev missing from skills array')
    exit(1)
print('  OK: skills/plugin-dev still present')
" || ERRORS=$((ERRORS+1))

# --- Summary ---
echo ""
if [ $ERRORS -eq 0 ]; then
  echo "ALL WAVE 3 CHECKS PASSED"
else
  echo "FAILED: $ERRORS error(s)"
  exit 1
fi
