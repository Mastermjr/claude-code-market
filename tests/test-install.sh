#!/usr/bin/env bash
# Integration test: uses the real Claude Code CLI to add the marketplace,
# install every plugin, and verify they load — in an isolated HOME directory.
#
# Requires: claude CLI in PATH, network access (GitHub clones)
#
# @decision DEC-TEST-001
# @title Integration test uses real claude CLI against isolated HOME
# @status accepted
# @rationale Static validation missed the V2 source-format bug because it never
#   ran the actual plugin loader. This test runs `claude plugin marketplace add`,
#   `claude plugin install`, and `claude plugin list` against a throwaway HOME,
#   catching any format or resolution errors that Claude Code itself would hit.
#
# Usage: bash tests/test-install.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_HOME="$REPO_ROOT/tmp/test-home-$$"
ERRORS=0

cleanup() {
  rm -rf "$TEST_HOME" 2>/dev/null || true
}
trap cleanup EXIT

# Ensure claude is available
if ! command -v claude &>/dev/null; then
  echo "SKIP: claude CLI not found in PATH"
  exit 0
fi

# Force HTTPS for GitHub (SSH may not be configured in CI/test envs)
mkdir -p "$TEST_HOME"
HOME="$TEST_HOME" git config --global url."https://github.com/".insteadOf "git@github.com:"

echo "=== Integration Test: Real Plugin Install ==="
echo "  HOME=$TEST_HOME"
echo ""

# --- Step 1: Add marketplace ---
echo "[1/4] Adding marketplace..."
OUTPUT=$(CLAUDECODE= HOME="$TEST_HOME" claude plugin marketplace add "$REPO_ROOT" 2>&1) || {
  echo "  FAIL: marketplace add failed"
  echo "  $OUTPUT"
  ERRORS=$((ERRORS+1))
}
if echo "$OUTPUT" | grep -q "Successfully added"; then
  echo "  OK: marketplace registered"
else
  echo "  FAIL: unexpected output: $OUTPUT"
  ERRORS=$((ERRORS+1))
fi

# --- Step 2: Read plugin list from marketplace.json ---
echo "[2/4] Reading plugin list..."
MARKETPLACE_JSON="$REPO_ROOT/.claude-plugin/marketplace.json"
PLUGIN_NAMES=$(python3 -c "
import json
m = json.load(open('$MARKETPLACE_JSON'))
for p in m['plugins']:
    print(p['name'])
")
PLUGIN_COUNT=$(echo "$PLUGIN_NAMES" | wc -l)
echo "  Found $PLUGIN_COUNT plugin(s): $(echo $PLUGIN_NAMES | tr '\n' ' ')"

# --- Step 3: Install each plugin ---
echo "[3/4] Installing plugins..."
while IFS= read -r PLUGIN_NAME; do
  OUTPUT=$(CLAUDECODE= HOME="$TEST_HOME" claude plugin install "${PLUGIN_NAME}@claude-code-market" 2>&1) || true
  if echo "$OUTPUT" | grep -q "Successfully installed"; then
    echo "  OK: $PLUGIN_NAME installed"
  else
    echo "  FAIL: $PLUGIN_NAME — $OUTPUT"
    ERRORS=$((ERRORS+1))
  fi
done <<< "$PLUGIN_NAMES"

# --- Step 4: Verify installed plugins ---
echo "[4/4] Verifying installed plugins..."
INSTALLED=$(CLAUDECODE= HOME="$TEST_HOME" claude plugin list 2>&1)
echo "$INSTALLED" | grep -v "^$"

# Check each plugin appears in the list
while IFS= read -r PLUGIN_NAME; do
  if echo "$INSTALLED" | grep -q "$PLUGIN_NAME"; then
    echo "  OK: $PLUGIN_NAME found in plugin list"
  else
    echo "  FAIL: $PLUGIN_NAME missing from plugin list"
    ERRORS=$((ERRORS+1))
  fi
done <<< "$PLUGIN_NAMES"

echo ""
if [ $ERRORS -eq 0 ]; then
  echo "ALL INSTALL TESTS PASSED"
else
  echo "FAILED: $ERRORS error(s)"
  exit 1
fi
