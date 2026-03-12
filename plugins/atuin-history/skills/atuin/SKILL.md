---
name: atuin
description: Search, analyze, and manage shell history with Atuin. Provides comprehensive CLI reference, search tips, configuration guidance, and live history queries.
argument-hint: "[search query, config question, 'stats', or 'help']"
context: fork
agent: general-purpose
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - WebFetch
  - WebSearch
  - AskUserQuestion
  - Write
---

<!--
 * @decision DEC-SKILL-001
 * @title Fork context skill with Bash+Read+WebFetch tools
 * @status accepted
 * @rationale Fork context prevents lengthy reference material from permanently
 *   consuming the parent session's context window. Bash access lets the skill
 *   run live atuin search and stats queries. WebFetch allows pulling current
 *   docs if needed. WebSearch is available for version-specific lookups.
 *   Addresses: REQ-P0-006, REQ-P1-003.
-->

# /atuin Skill — Atuin Shell History Reference and Live Query Tool

Parse `$ARGUMENTS` on invocation. If arguments are provided, determine the user's intent:

| Argument pattern | Intent |
|-----------------|--------|
| `stats` or `statistics` | Show history statistics |
| `help` or empty | Display this reference |
| A search query (any other text) | Search history for matching commands |
| A config question (contains "config", "setting", "option") | Answer from Section 5 config reference |

When the intent is a search or stats query, execute the appropriate `atuin` command and present the results. See Section 7 (Interactive Capabilities) for execution details.

---

## 1. Overview

Atuin replaces the standard shell history file (e.g., `~/.bash_history`, `~/.zsh_history`) with a SQLite database. Every command is stored with rich metadata:

| Field | Description |
|-------|-------------|
| `command` | The full command text |
| `directory` | Working directory where the command ran |
| `exit` | Exit code (0 = success) |
| `duration` | Wall-clock execution time in milliseconds |
| `host` | Hostname |
| `user` | Username |
| `session` | Shell session UUID |
| `time` | Timestamp |
| `uuid` | Unique entry identifier |

**Key capabilities:**
- SQLite backend — queryable, compact, fast even with millions of entries
- Optional end-to-end encrypted sync across machines via `atuin sync`
- Interactive TUI search triggered by `Ctrl-R` or the Up arrow key
- Shell integrations: zsh, bash, fish, nushell, xonsh

**Default paths (Linux/macOS):**
- Config: `~/.config/atuin/config.toml`
- Database: `~/.local/share/atuin/history.db`
- Encryption key: `~/.local/share/atuin/key`
- Binary (if installed via atuin installer): `/root/.atuin/bin/atuin`

---

## 2. Quick Reference — Key Commands

```
# Search
atuin search [QUERY]                  # Non-interactive search (prints results)
atuin search -i [QUERY]               # Interactive TUI search
atuin search --cmd-only [QUERY]       # Commands only, no metadata
atuin search -c /path [QUERY]         # Filter by working directory
atuin search -e 0 [QUERY]            # Only successful commands (exit 0)
atuin search -e 1 [QUERY]            # Only failed commands
atuin search --after "1 week ago"     # Commands after a relative time
atuin search --before "2024-01-01"    # Commands before a date
atuin search --limit 20 [QUERY]       # Limit result count
atuin search --offset 10 [QUERY]      # Skip first N results
atuin search --reverse [QUERY]        # Oldest first
atuin search --delete [QUERY]         # Delete matching entries
atuin search --delete-it-all          # Delete EVERYTHING (destructive!)
atuin search --human [QUERY]          # Human-readable time formatting
atuin search --format "..." [QUERY]   # Custom output format
atuin search --filter-mode host       # Override filter mode for this query
atuin search --search-mode prefix     # Override search mode for this query

# History management
atuin history list                    # List all history
atuin history list --cmd-only         # Commands only
atuin history list -r false           # Chronological order (oldest first)
atuin history list --limit N          # Show last N entries
atuin history list --format "..."     # Custom format
atuin history list -c                 # Filter to current directory
atuin history list -s                 # Filter to current session
atuin history prune                   # Remove entries matching history_filter/cwd_filter
atuin history dedup                   # Remove duplicate entries (same cmd+cwd+host)
atuin history last                    # Show the last command ran

# Statistics
atuin stats                           # Overall top-10 command statistics
atuin stats "last week"               # Stats for a time period
atuin stats "last month"              # Stats for last month
atuin stats "today"                   # Stats for today
atuin stats -c 20                     # Show top 20 commands (default: 10)
atuin stats -n 2                      # Bigram statistics (command pairs)
atuin stats -n 3                      # Trigram statistics (command triples)

# System
atuin info                            # Show config/data file paths and version
atuin doctor                          # Diagnose configuration and connectivity issues
atuin import auto                     # Import from detected shell history file
atuin sync                            # Manual sync to/from server
atuin key                             # Manage encryption key
atuin login                           # Log in to sync server
atuin logout                          # Log out from sync server
atuin register                        # Register a new sync account
atuin dotfiles alias set NAME CMD     # Create a synced shell alias
atuin dotfiles alias list             # List synced aliases
atuin dotfiles alias delete NAME      # Remove a synced alias
```

---

## 3. Search Modes

Controlled by `search_mode` in `config.toml` or `--search-mode` flag.

### prefix
Matches from the **start** of the command string only.
- `ls` matches `ls -la`, `ls /tmp` — but NOT `echo ls` or `git ls-files`
- Fast, predictable, mirrors traditional shell history search

### fulltext
Substring match **anywhere** in the command.
- `ls` matches `ls -la`, `echo ls`, `git ls-files`
- Most permissive; can produce many results

### fuzzy (default)
Flexible matching with fzf-compatible syntax:

| Syntax | Meaning |
|--------|---------|
| `sbtrkt` | Fuzzy match (characters in order, not necessarily adjacent) |
| `'wild` | Exact substring match (prefix with single quote) |
| `^music` | Prefix exact match (must start with "music") |
| `.mp3$` | Suffix exact match (must end with ".mp3") |
| `!fire` | Inverse exact match (must NOT contain "fire") |
| `!^music` | Inverse prefix match (must NOT start with "music") |
| `!.mp3$` | Inverse suffix match (must NOT end with ".mp3") |
| `^core go$ \| rb$ \| py$` | OR: ends with go, rb, or py |

Multiple terms are ANDed together: `git ^feat` matches commands containing "git" that start with "feat".

### skim
Similar to fuzzy with additional skim-specific matching features. Uses the skim library for matching.

---

## 4. Filter Modes

Controlled by `filter_mode` in `config.toml` or `--filter-mode` flag. Determines which machine/session scope to search.

| Mode | Scope | When to use |
|------|-------|-------------|
| `global` | All history from all machines (synced) | Find a command you ran anywhere |
| `host` | Only this machine's history | Avoid seeing commands from other machines |
| `session` | Only the current shell session | Find what you did in this terminal window |
| `session-preload` | Session, but pre-loads from this machine | Like session but starts with machine history |
| `directory` | Only commands run in the current directory | Find commands specific to this project |
| `workspace` | Commands from anywhere in the current git repo tree | Project-scoped search across all subdirectories |

**Tip:** Use `workspace` filter mode in git repos for project-scoped history — it searches any directory within the current repository tree.

The `[search]` section allows configuring which filter modes appear as tabs in the TUI:
```toml
[search]
filters = ["global", "host", "session", "workspace", "directory"]
```

---

## 5. Configuration Reference (`~/.config/atuin/config.toml`)

All options are optional — defaults shown. Restart not required for most changes (atuin reads config on each invocation).

### Search and History Behavior

```toml
# Search algorithm: prefix, fulltext, fuzzy, skim
search_mode = "fuzzy"

# Default filter scope: global, host, session, session-preload, directory, workspace
filter_mode = "global"

# Filter mode when triggered by Up arrow key (defaults to filter_mode if unset)
filter_mode_shell_up_key_binding = "global"

# Search mode for Up arrow key (defaults to search_mode if unset)
search_mode_shell_up_key_binding = "fuzzy"

# Enable workspace filter mode (searches whole git repo tree)
workspaces = false

# Block commands matching these regexes from being saved to history
# history_filter = [
#   "^secret-cmd",
#   "^innocuous-cmd .*--secret=.+",
# ]

# Block commands run in directories matching these regexes
# cwd_filter = [
#   "^/very/secret/area",
# ]

# Auto-detect and block secrets (AWS keys, GitHub PATs, Slack tokens, Stripe keys)
secrets_filter = true

# Don't save failed commands (non-zero exit)
store_failed = true   # true = save failed commands (default)

# Enable chaining: Atuin completes the right side of &&, ||, |
command_chaining = false
```

### UI and Display

```toml
# Interface style: auto, full, compact
style = "auto"

# Max lines the TUI uses (0 = full screen)
inline_height = 0

# Invert: put search bar at top instead of bottom
invert = false

# Show command preview for truncated commands
show_preview = true

# Max lines for preview
max_preview_height = 4

# Show help row (version, keymap hint, total command count)
show_help = true

# Show tab bar (Search / Inspector tabs)
show_tabs = true

# On Enter: execute immediately (true) or copy to prompt for editing (false)
enter_accept = true

# What pressing Escape returns: return-original, return-query
exit_mode = "return-original"

# Default format for non-interactive output
# history_format = "{time}\t{command}\t{duration}"
```

### Sync and Storage

```toml
# Auto-sync when commands are run
auto_sync = true

# Sync server address
sync_address = "https://api.atuin.sh"

# How often to sync (0 = after every command)
sync_frequency = "10m"

# Custom database path (default: ~/.local/share/atuin/history.db)
# db_path = "~/.history.db"

# Custom encryption key path (default: ~/.local/share/atuin/key)
# key_path = "~/.key"

# Date format: "us" (MM/DD/YYYY) or "uk" (DD/MM/YYYY)
dialect = "us"

# Timezone: "local", "l", or UTC offset like "+9", "-05", "+03:30"
timezone = "local"
```

### Keymap

```toml
# Startup keymap: emacs, vim-insert, vim-normal, auto
keymap_mode = "auto"

# Cursor shape per keymap mode
# keymap_cursor = { emacs = "blink-block", vim_insert = "blink-block", vim_normal = "steady-block" }

[keys]
# Up/down key exits TUI when scrolled past first/last entry
scroll_exits = true
```

### Statistics

```toml
[stats]
# Commands where the subcommand matters for stats (git add vs git commit)
# common_subcommands = ["git", "cargo", "docker", "kubectl", "npm", ...]

# Commands to strip (counted without prefix): sudo git -> git
# common_prefix = ["sudo"]

# Commands to exclude entirely from stats
# ignored_commands = ["cd", "ls"]
```

### Preview

```toml
[preview]
# Height calculation strategy: auto, static, fixed
# auto: based on selected command length
# static: based on longest command in history
# fixed: always use max_preview_height
strategy = "auto"
```

### Daemon (background sync)

```toml
[daemon]
# Use background daemon for sync instead of per-command sync
enabled = false

# How often the daemon syncs (seconds)
sync_frequency = 300

# Unix socket path (Linux/macOS)
# socket_path = "~/.local/share/atuin/atuin.sock"
```

### Theme

```toml
[theme]
# Built-in themes: default, autumn, marine
# Custom themes: place NAME.toml in ~/.config/atuin/themes/
# name = "autumn"
```

### UI Columns (interactive TUI)

```toml
[ui]
# Columns displayed left-to-right in the TUI (default: duration, time, command)
# Available types: duration, time, datetime, directory, host, user, exit, command
# columns = ["duration", "time", "command"]
#
# With metadata: show exit code, host, and directory
# columns = ["exit", "duration", "host", "directory", "command"]
#
# Custom widths:
# columns = ["duration", { type = "directory", width = 30 }, "command"]
```

### Sync v2

```toml
[sync]
# Enable sync v2 protocol (recommended for new installs)
records = true
```

### tmux Integration

```toml
[tmux]
# Open Atuin in a tmux popup (requires tmux >= 3.2)
enabled = false

# Popup dimensions
width = "80%"
height = "60%"
```

---

## 6. Format Variables

Use with `--format` flag in `atuin search` or `atuin history list`, or set `history_format` in config.

| Variable | Description | Example |
|----------|-------------|---------|
| `{command}` | The full command text | `git push origin main` |
| `{directory}` | Working directory | `/home/user/project` |
| `{duration}` | Execution time | `123ms` |
| `{user}` | Username | `root` |
| `{host}` | Hostname | `myserver` |
| `{time}` | Relative time | `5m ago` |
| `{exit}` | Exit code | `0` |
| `{relativetime}` | Relative time (alias) | `5m ago` |
| `{session}` | Session UUID | `abc123...` |
| `{uuid}` | Entry UUID | `def456...` |
| `{datetime}` | Absolute timestamp | `2024-01-15 14:35:22` |

**Example:** `atuin search --format "{time} [{exit}] {directory} {command}"`

---

## 7. Interactive Capabilities

When the user asks a question that can be answered with live atuin data, execute the appropriate command. The atuin binary may be at `/root/.atuin/bin/atuin` or in `$PATH`. Check both.

```bash
# Resolve atuin binary path
ATUIN_BIN="$(command -v atuin 2>/dev/null || echo /root/.atuin/bin/atuin)"
if [[ ! -x "$ATUIN_BIN" ]]; then
  echo "atuin not found in PATH or at /root/.atuin/bin/atuin"
  exit 1
fi
```

### Live Search
```bash
# Search by query term
$ATUIN_BIN search --cmd-only "$ARGUMENTS"

# Search with filters
$ATUIN_BIN search --cmd-only --exit 0 "$ARGUMENTS"         # Only successful
$ATUIN_BIN search --cmd-only -c /path/to/dir "$ARGUMENTS"  # By directory
$ATUIN_BIN search --cmd-only --after "1 week ago"          # Recent commands
$ATUIN_BIN search --cmd-only --limit 20 "$ARGUMENTS"       # Limit results
```

### Statistics
```bash
$ATUIN_BIN stats                  # All-time top commands
$ATUIN_BIN stats "last week"      # This week's stats
$ATUIN_BIN stats "today"          # Today's stats
$ATUIN_BIN stats -c 20            # Top 20 commands
$ATUIN_BIN stats -n 2             # Most common command pairs
```

### Recent History
```bash
$ATUIN_BIN history list --cmd-only --limit 20   # Last 20 commands
$ATUIN_BIN history list --cmd-only -c           # Commands in current dir
$ATUIN_BIN history list --cmd-only -s           # Commands in this session
```

### System Info and Diagnostics
```bash
$ATUIN_BIN info       # Config paths, DB path, version
$ATUIN_BIN doctor     # Diagnose sync, DB, and shell integration issues
```

---

## 8. Tips and Tricks

**Interactive search:**
- `Ctrl-R` or Up arrow triggers the atuin TUI in the shell
- Tab selects a command and puts it in the prompt for editing
- Enter executes immediately (when `enter_accept = true`)
- `Alt-1` through `Alt-9` jump to numbered results in the TUI

**Secrets and privacy:**
- Set `secrets_filter = true` (default) to auto-block AWS keys, GitHub PATs, Slack tokens, Stripe keys from being saved
- Use `history_filter` regex array to block sensitive command patterns
- Use `cwd_filter` to block entire directory trees (e.g., secrets vault directories)
- Run `atuin search --delete "PATTERN"` to remove existing sensitive entries
- `atuin history dedup` removes duplicate entries (same command + cwd + hostname)
- `atuin history prune` removes entries matching your current `history_filter`/`cwd_filter`

**Multi-machine workflows:**
- `atuin sync` syncs history to/from the configured server
- Use `filter_mode = "host"` to see only local commands when synced history is too noisy
- Use `filter_mode = "global"` to find commands run on any machine
- Set `[ui] columns = ["host", "command"]` to always see which machine ran a command

**Project/workspace history:**
- Set `workspaces = true` and `filter_mode = "workspace"` to auto-scope history to the current git repo
- This searches any directory within the git repo tree — useful for mono-repos

**Statistics and analysis:**
- `atuin stats -n 2` shows most common two-command sequences (bigrams)
- `atuin stats "last month"` for monthly usage reports
- `atuin stats -c 50` to see more commands in the ranking

**Export and scripting:**
- `atuin search --cmd-only > commands.txt` — export matching commands
- `atuin search --cmd-only --format "{time}\t{exit}\t{command}"` — TSV with metadata
- `atuin history list --print0 | xargs -0 ...` — null-separated for safe pipelines
- `atuin search --format "{uuid}"` — get entry UUIDs for precise operations

**Shell integration verification:**
- Check that your shell rc file contains: `eval "$(atuin init SHELL)"` (replace SHELL with zsh, bash, fish, etc.)
- Run `atuin doctor` to verify the integration is working

---

## 9. Troubleshooting

| Problem | Likely Cause | Resolution |
|---------|-------------|------------|
| "DB locked" error | Another atuin process holds the SQLite lock | Wait for other process to finish; run `atuin doctor` to identify it |
| Commands not appearing in history | Shell integration missing or `history_filter` matching | Verify `eval "$(atuin init <shell>)"` in your rc file; check `history_filter` in config |
| Missing history after sync | `filter_mode = "host"` hiding other machines | Switch to `filter_mode = "global"` or use `--filter-mode global` flag |
| Sync failing | Network or auth issue | Run `atuin doctor`; check `sync_address` reachability; try `atuin login` again |
| "Key not found" | Encryption key missing or mismatched | Re-import key with `atuin key`; restore from backup if available |
| Slow search | Searching too large a scope | Try `--filter-mode host` or `--filter-mode session` to reduce the search space |
| Commands logged twice | Duplicate shell integration entries in rc file | Check rc file for duplicate `atuin init` calls; remove duplicates |
| Atuin not in PATH | Installed to non-standard location | Add `/root/.atuin/bin` to PATH, or use full path `/root/.atuin/bin/atuin` |
| Secrets appear in history | `secrets_filter = false` or pattern not covered | Enable `secrets_filter = true`; add specific patterns to `history_filter`; run `atuin history prune` |

---

## 10. Write Context Summary (MANDATORY — do this LAST)

After completing the user's request (answering a question, performing a search, showing stats), write a compact summary so the parent session receives key findings:

```bash
cat > .claude/.skill-result.md << 'SKILLEOF'
## Atuin Skill Result

**Query:** $ARGUMENTS
**Action taken:** [describe what was done: answered config question / ran live search / showed stats / provided reference]

### Key Information
- [relevant findings, search results, or answers to the user's question]
- [any commands executed and their output summary]
- [configuration recommendations if applicable]
SKILLEOF
```

Keep the summary under 2000 characters. This is consumed by the parent session's hook — it will be surfaced automatically.

---

## After Completion

```
---
/atuin skill complete.
- Action: [what was done]
- Results: [summary of findings or answer provided]

Need to search history, check stats, or configure Atuin? Just ask.
```
