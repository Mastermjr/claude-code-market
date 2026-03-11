#!/usr/bin/env bash
# Validates marketplace structure and plugin-dev skill completeness
set -euo pipefail

ERRORS=0
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Check marketplace.json exists and is valid JSON
echo "Checking marketplace.json..."
python3 -m json.tool "$REPO_ROOT/.claude-plugin/marketplace.json" > /dev/null || { echo "FAIL: invalid JSON"; ERRORS=$((ERRORS+1)); }

# Check plugin.json exists and is valid JSON
echo "Checking plugin.json..."
python3 -m json.tool "$REPO_ROOT/.claude-plugin/plugin.json" > /dev/null || { echo "FAIL: invalid JSON"; ERRORS=$((ERRORS+1)); }

# Check marketplace.json has plugins with GitHub sources
echo "Checking plugin sources..."
python3 -c "
import json, sys
m = json.load(open('$REPO_ROOT/.claude-plugin/marketplace.json'))
for p in m['plugins']:
    s = p.get('source', {})
    if isinstance(s, dict) and s.get('source') == 'github' and 'repo' in s:
        print(f'  OK: {p[\"name\"]} -> {s[\"repo\"]}')
    else:
        print(f'  FAIL: {p[\"name\"]} has no GitHub source')
        sys.exit(1)
" || ERRORS=$((ERRORS+1))

# Check SKILL.md exists
echo "Checking plugin-dev skill..."
[ -f "$REPO_ROOT/skills/plugin-dev/SKILL.md" ] || { echo "FAIL: SKILL.md missing"; ERRORS=$((ERRORS+1)); }

# Check SKILL.md has frontmatter
head -1 "$REPO_ROOT/skills/plugin-dev/SKILL.md" | grep -q "^---" || { echo "FAIL: SKILL.md missing frontmatter"; ERRORS=$((ERRORS+1)); }

# Check no stale plugins/ directory
[ ! -d "$REPO_ROOT/plugins" ] || { echo "FAIL: stale plugins/ directory exists"; ERRORS=$((ERRORS+1)); }

# Check no stale sync workflow
[ ! -f "$REPO_ROOT/.github/workflows/sync-atuin-history.yml" ] || { echo "FAIL: stale sync workflow exists"; ERRORS=$((ERRORS+1)); }

echo ""
if [ $ERRORS -eq 0 ]; then
  echo "ALL CHECKS PASSED"
else
  echo "FAILED: $ERRORS error(s)"
  exit 1
fi
