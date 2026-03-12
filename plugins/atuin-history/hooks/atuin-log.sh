#!/usr/bin/env bash
# PostToolUse:Bash hook — logs every Bash command Claude executes into Atuin's history database.
#
# Registered via hooks/hooks.json under hooks.PostToolUse with matcher "Bash".
# Receives a JSON payload on stdin describing the tool call that just completed.
#
# @decision DEC-HOOK-001
# @title Use atuin CLI history start/end pair (not direct SQLite)
# @status accepted
# @rationale The CLI is the stable public API. Direct DB writes risk schema changes across
#   atuin versions and could cause lock contention with concurrent atuin processes.
#   The CLI handles CWD recording, timestamps, and session management internally.
#
# @decision DEC-HOOK-002
# @title Fire-and-forget background subshell for atuin calls
# @status accepted
# @rationale `atuin history start` takes 50-200ms (SQLite write + ID generation). The hook's
#   synchronous path must return in <100ms. Solution: capture command from stdin JSON
#   synchronously, then spawn a background subshell that calls start/end. The hook returns
#   immediately; the background process completes asynchronously.
#
# @decision DEC-PLUGIN-002
# @title Self-contained hook — zero dependency on claude-ctrl libraries
# @status accepted
# @rationale As a standalone plugin, this hook must not assume source-lib.sh, log.sh, or
#   any other host library is present. All JSON parsing is done via jq directly, which is
#   always available in the runtime environment. This replaces the former DEC-HOOK-003
#   (source source-lib.sh at runtime), which assumed the plugin lived inside claude-ctrl.
#   A standalone plugin model requires no fragile installation-path assumptions.

set -euo pipefail

# --- Locate atuin binary FIRST — skip everything if not available (REQ-P0-002) ---
ATUIN_BIN=""
if command -v atuin &>/dev/null; then
  ATUIN_BIN="atuin"
elif [[ -x "${HOME:-}/.atuin/bin/atuin" ]]; then
  ATUIN_BIN="$HOME/.atuin/bin/atuin"
fi
[[ -z "$ATUIN_BIN" ]] && exit 0

# --- Read stdin and parse JSON with jq (DEC-PLUGIN-002) ---
HOOK_INPUT=$(cat)
CMD=$(printf '%s' "$HOOK_INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)
CWD=$(printf '%s' "$HOOK_INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)

# --- Skip empty or whitespace-only commands (REQ-P1-001) ---
[[ -z "${CMD// /}" ]] && exit 0

# --- Default CWD to current directory if not provided ---
[[ -z "$CWD" ]] && CWD="$(pwd)"

# --- Fire-and-forget: background subshell logs to atuin (DEC-HOOK-001, DEC-HOOK-002) ---
# The subshell: changes to the correct CWD, starts a history entry, then closes it.
# Using `--` before $CMD ensures commands starting with `-` are not parsed as flags.
# The outer hook exits immediately; atuin writes happen asynchronously.
(
  cd "$CWD" 2>/dev/null || cd "$HOME"
  ID=$("$ATUIN_BIN" history start -- "$CMD" 2>/dev/null) || exit 0
  "$ATUIN_BIN" history end --exit 0 "$ID" 2>/dev/null || true
) &
disown $! 2>/dev/null || true

exit 0
