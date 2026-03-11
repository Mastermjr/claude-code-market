---
name: setup
description: Mastermjr's personal Claude Code deployment blueprint. Sets up all recommended marketplaces, plugins, and configuration. Use when setting up a new machine or reconfiguring Claude Code.
context: fork
agent: general-purpose
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
---

<!--
@decision DEC-MARKET-009
@title Marketplace as setup hub — recommends companion marketplaces via setup skill
@status accepted
@rationale The marketplace evolves from a passive plugin listing into an active "setup hub"
  for Claude Code. A /claude-code-market:setup skill guides users through registering
  recommended companion marketplaces and installing recommended plugins. The approach is
  guide-based (presents recommendations and commands) rather than automated config mutation —
  respecting user agency while reducing discovery friction.
-->

# Mastermjr's Claude Code Setup Blueprint

This skill walks you through setting up Claude Code exactly the way Mastermjr runs it — preferred marketplaces, plugins, model, and settings.

This is a **personal blueprint**, not a generic getting-started guide. Every recommendation here is deliberate.

---

## Step 1: Check What's Already Installed

Before installing anything, let's see your current state. Run these commands in Claude Code:

```
/plugin list-marketplaces
/plugin list
```

Note which marketplaces and plugins you already have. We'll only install what's missing.

---

## Step 2: Register Marketplaces

**`claude-plugins-official`** is built in — no registration needed.

Register these two companion marketplaces:

```
/plugin marketplace add Mastermjr/claude-code-market
/plugin marketplace add astral-sh/claude-code-plugins
```

| Marketplace | What It Provides |
|-------------|-----------------|
| `Mastermjr/claude-code-market` | Personal plugins: Atuin history integration, plugin-dev reference skill, this setup skill |
| `astral-sh/claude-code-plugins` | Astral's official Python tooling plugins: uv, ty, ruff + ty LSP |

---

## Step 3: Install Plugins

Install all recommended plugins. Skip any you don't need.

### Shell & History

```
/plugin install atuin-history@claude-code-market
```

**atuin-history** — Bridges Atuin shell history with Claude Code. Logs commands Claude executes and lets you search your shell history directly from Claude Code.

**Prerequisite:** Atuin v18+ must be installed. Check with `atuin --version`. Install from [atuin.sh](https://atuin.sh) if missing.

### Frontend Development

```
/plugin install frontend-design@claude-plugins-official
```

**frontend-design** — UI/UX implementation guidance. Helps Claude make better decisions about layouts, component design, and visual hierarchy.

### Documentation

```
/plugin install context7@claude-plugins-official
```

**context7** — Real-time documentation lookup via Upstash Context7 MCP. Gives Claude access to current library docs instead of relying on training data.

**Prerequisite:** Node.js must be installed (for the MCP server). Check with `node --version`.

### Python Tooling

```
/plugin install astral@astral-sh
```

**astral** — The full Astral Python toolchain: uv package manager, ruff linter/formatter, ty type checker, and ty LSP server integration.

**Prerequisite:** `uvx` must be available (comes with uv). Install uv from [docs.astral.sh/uv](https://docs.astral.sh/uv/getting-started/installation/).

### Plugin Development

```
/plugin install claude-code-market@claude-code-market
```

**claude-code-market** — Installs this marketplace as a plugin, providing the `plugin-dev` skill: a comprehensive reference for designing, building, and distributing Claude Code plugins.

---

## Quick-Start: Full Setup Sequence

If you're setting up from scratch, run these in order:

```bash
# Register marketplaces
/plugin marketplace add Mastermjr/claude-code-market
/plugin marketplace add astral-sh/claude-code-plugins

# Install plugins
/plugin install atuin-history@claude-code-market
/plugin install frontend-design@claude-plugins-official
/plugin install context7@claude-plugins-official
/plugin install astral@astral-sh
```

---

## Step 4: Recommended Settings

Add these to your `settings.local.json` (user-level settings, not committed to repos):

```json
{
  "model": "opus",
  "enableAllProjectMcpServers": true
}
```

`settings.local.json` lives at `~/.claude/settings.local.json`.

| Setting | Value | Why |
|---------|-------|-----|
| `model` | `"opus"` | Best reasoning for complex tasks. Claude Code defaults to a lighter model — override here. |
| `enableAllProjectMcpServers` | `true` | Automatically enables MCP servers declared in `.mcp.json` without prompting per-project. Required for context7 to work seamlessly. |

---

## Prerequisites Summary

| Prerequisite | Required By | Check | Install |
|-------------|-------------|-------|---------|
| Atuin v18+ | `atuin-history` | `atuin --version` | [atuin.sh](https://atuin.sh) |
| Node.js | `context7` | `node --version` | [nodejs.org](https://nodejs.org) |
| uvx (via uv) | `astral` ty LSP | `uvx --version` | [docs.astral.sh/uv](https://docs.astral.sh/uv/getting-started/installation/) |

---

## Walkthrough Mode

If you'd like me to guide you interactively:

1. Tell me which step you're on
2. I'll check what's installed, identify what's missing, and walk through each installation
3. I can verify each plugin loaded correctly before moving to the next

Just say "let's go" and I'll start by checking your current setup.
