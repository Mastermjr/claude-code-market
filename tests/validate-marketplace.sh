#!/usr/bin/env bash
# Validates marketplace structure matches the Astral pattern:
# - marketplace.json uses relative path strings (not GitHub source objects)
# - plugins live under plugins/<name>/ with their own .claude-plugin/plugin.json
# - skills live under plugins/<name>/skills/<name>/SKILL.md
#
# @decision DEC-MARKET-010
# @title Validate-marketplace checks Astral pattern (relative paths, plugins/ subdir)
# @status accepted
# @rationale V3 restructure adopts the Astral monorepo pattern: plugins are bundled under
#   plugins/<name>/ with relative path sources in marketplace.json. The old validator
#   checked for GitHub source objects and a root skills/ dir — both are now incorrect.
#   This rewrite validates the new structure: relative path strings, per-plugin
#   .claude-plugin/plugin.json, no root plugin.json, no root skills/, executable hooks.
set -euo pipefail

ERRORS=0
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Check marketplace.json exists and is valid JSON
echo "Checking marketplace.json..."
python3 -m json.tool "$REPO_ROOT/.claude-plugin/marketplace.json" > /dev/null || { echo "FAIL: invalid JSON"; ERRORS=$((ERRORS+1)); }

# Check root plugin.json does NOT exist (marketplace itself is not a plugin)
echo "Checking root plugin.json is absent..."
if [ -f "$REPO_ROOT/.claude-plugin/plugin.json" ]; then
  echo "  FAIL: root .claude-plugin/plugin.json should not exist (marketplace is not a plugin)"
  ERRORS=$((ERRORS+1))
else
  echo "  OK: root plugin.json absent"
fi

# Check marketplace.json plugin sources are valid (relative path or GitHub source object)
echo "Checking plugin sources..."
python3 -c "
import json, sys
m = json.load(open('$REPO_ROOT/.claude-plugin/marketplace.json'))
for p in m['plugins']:
    s = p.get('source', '')
    if isinstance(s, str) and s.startswith('./'):
        print(f'  OK: {p[\"name\"]} -> {s} (bundled)')
    elif isinstance(s, dict) and s.get('source') == 'github' and 'repo' in s:
        print(f'  OK: {p[\"name\"]} -> github:{s[\"repo\"]} (external)')
    else:
        print(f'  FAIL: {p[\"name\"]} source must be relative path or {{\"source\": \"github\", \"repo\": \"...\"}} — got: {s!r}')
        sys.exit(1)
" || ERRORS=$((ERRORS+1))

# Check each plugin directory exists with required structure
echo "Checking plugin directories..."
python3 -c "
import json, os, sys
repo_root = '$REPO_ROOT'
m = json.load(open(os.path.join(repo_root, '.claude-plugin/marketplace.json')))
errors = 0
for p in m['plugins']:
    source = p['source']
    if not isinstance(source, str) or not source.startswith('./'):
        continue
    plugin_dir = os.path.normpath(os.path.join(repo_root, source))
    plugin_json = os.path.join(plugin_dir, '.claude-plugin/plugin.json')
    skills_dir = os.path.join(plugin_dir, 'skills')
    if not os.path.isdir(plugin_dir):
        print(f'  FAIL: plugin dir missing: {plugin_dir}')
        errors += 1
    elif not os.path.isfile(plugin_json):
        print(f'  FAIL: plugin.json missing: {plugin_json}')
        errors += 1
    else:
        try:
            pj = json.load(open(plugin_json))
            if 'skills' in pj:
                print(f'  WARN: {p[\"name\"]} plugin.json has \"skills\" array — should be omitted (auto-discovered)')
            if 'strict' in pj:
                print(f'  WARN: {p[\"name\"]} plugin.json has \"strict\" field — not used in Astral pattern')
            print(f'  OK: {p[\"name\"]} -> {source} (plugin.json valid)')
        except Exception as e:
            print(f'  FAIL: {p[\"name\"]} plugin.json invalid JSON: {e}')
            errors += 1
    if not os.path.isdir(skills_dir):
        print(f'  INFO: {p[\"name\"]} has no skills/ dir (ok for hook-only plugins)')
sys.exit(errors)
" || ERRORS=$((ERRORS+1))

# Check claude-code-market plugin has plugin-dev and setup skills
echo "Checking claude-code-market skills..."
[ -f "$REPO_ROOT/plugins/claude-code-market/skills/plugin-dev/SKILL.md" ] || { echo "  FAIL: plugin-dev SKILL.md missing"; ERRORS=$((ERRORS+1)); }
[ -f "$REPO_ROOT/plugins/claude-code-market/skills/setup/SKILL.md" ] || { echo "  FAIL: setup SKILL.md missing"; ERRORS=$((ERRORS+1)); }

# Check plugin-dev SKILL.md has frontmatter
head -1 "$REPO_ROOT/plugins/claude-code-market/skills/plugin-dev/SKILL.md" | grep -q "^---" || { echo "  FAIL: plugin-dev SKILL.md missing frontmatter"; ERRORS=$((ERRORS+1)); }

# Check external plugins have valid GitHub source entries
echo "Checking external plugin sources..."
python3 -c "
import json, sys
m = json.load(open('$REPO_ROOT/.claude-plugin/marketplace.json'))
for p in m['plugins']:
    s = p.get('source', '')
    if isinstance(s, dict) and s.get('source') == 'github':
        repo = s.get('repo', '')
        if '/' not in repo:
            print(f'  FAIL: {p[\"name\"]} github source missing owner/repo format: {repo}')
            sys.exit(1)
        print(f'  OK: {p[\"name\"]} -> github:{repo}')
"

# Check no root-level skills/ directory (old structure)
echo "Checking no stale root skills/ directory..."
[ ! -d "$REPO_ROOT/skills" ] || { echo "  FAIL: stale root skills/ directory exists"; ERRORS=$((ERRORS+1)); }

# Check no stale sync workflow
[ ! -f "$REPO_ROOT/.github/workflows/sync-atuin-history.yml" ] || { echo "  FAIL: stale sync workflow exists"; ERRORS=$((ERRORS+1)); }

# Validate all JSON files in the repo
echo "Validating all JSON files..."
JSON_ERRORS=0
while IFS= read -r -d '' f; do
  python3 -m json.tool "$f" > /dev/null 2>&1 || { echo "  FAIL: invalid JSON: $f"; JSON_ERRORS=$((JSON_ERRORS+1)); }
done < <(find "$REPO_ROOT" -name "*.json" -not -path "*/.git/*" -not -path "*/tmp/*" -print0)
ERRORS=$((ERRORS+JSON_ERRORS))

echo ""
if [ $ERRORS -eq 0 ]; then
  echo "ALL CHECKS PASSED"
else
  echo "FAILED: $ERRORS error(s)"
  exit 1
fi
