# claude-code-market

Personal Claude Code plugin marketplace by [Mastermjr](https://github.com/Mastermjr).

## Fresh Install (One Command)

Set up [claude-ctrl](https://github.com/Mastermjr/claude-ctrl) + this marketplace from scratch:

```bash
curl -fsSL https://raw.githubusercontent.com/Mastermjr/claude-code-market/main/scripts/bootstrap.sh | bash
```

This backs up any existing `~/.claude`, clones claude-ctrl, and creates default settings. Then start `claude` and run `/claude-code-market:setup` for guided plugin installation.

## Install the Marketplace

Already have Claude Code set up? Just register this marketplace:

```
/plugin marketplace add Mastermjr/claude-code-market
```

## Available Plugins

| Plugin | Description | Install |
|--------|-------------|---------|
| [claude-code-market](#the-plugin-dev-skill) | Plugin development skill and Claude Code setup hub | `/plugin install claude-code-market@claude-code-market` |
| [atuin-history](#atuin-history) | Bridges Atuin shell history with Claude Code — logs commands and provides live search | `/plugin install atuin-history@claude-code-market` |
| [ludus-skill](https://github.com/Mastermjr/ludus-skill) | Ludus cyber range assistant — CLI, config, API for v1 and v2 | `/plugin install ludus-skill@claude-code-market` |

## The plugin-dev Skill

Install the `claude-code-market` plugin to get the `plugin-dev` skill — a comprehensive reference for designing, building, and distributing Claude Code plugins.

The skill covers: plugin.json manifest (all fields), all 6 source types, all component types (skills, commands, agents, hooks, MCP servers, LSP servers), the full hook system (all 14 events, 3 hook types), marketplace.json authoring, strict mode, plugin caching, CLI commands, and distribution patterns.

After installing the marketplace, invoke the skill at any time:

```
/claude-code-market:plugin-dev
```

Or with a specific question:

```
/claude-code-market:plugin-dev How do I add a PostToolUse hook to my plugin?
```

## atuin-history

Logs every Bash command Claude Code executes into [Atuin](https://atuin.sh)'s shell history database. Also provides the `/atuin-history:atuin` skill for searching and managing shell history directly from Claude Code.

**Prerequisite:** Atuin v18+ must be installed. Check with `atuin --version`. Install from [atuin.sh](https://atuin.sh).

```
/plugin install atuin-history@claude-code-market
```

## Recommended Setup

This marketplace is part of a broader Claude Code configuration. For the full Mastermjr setup — including companion marketplaces and recommended plugins — use the guided setup skill:

```
/claude-code-market:setup
```

Or follow the quick-start sequence manually:

```
# Register companion marketplace
/plugin marketplace add Mastermjr/claude-code-market
/plugin marketplace add astral-sh/claude-code-plugins

# Install recommended plugins
/plugin install atuin-history@claude-code-market
/plugin install frontend-design@claude-plugins-official
/plugin install context7@claude-plugins-official
/plugin install astral@astral-sh
```

**Companion marketplace:** [astral-sh/claude-code-plugins](https://github.com/astral-sh/claude-code-plugins) — Astral's official Claude Code plugins providing uv, ty, ruff, and the ty LSP server.

## Architecture

This repo follows the Astral monorepo pattern: plugins are bundled directly in this repo under `plugins/`, and `marketplace.json` uses relative path sources.

```
.claude-plugin/
└── marketplace.json     # Lists plugins with relative path sources

plugins/
├── claude-code-market/  # plugin-dev skill + setup skill
│   ├── .claude-plugin/
│   │   └── plugin.json
│   └── skills/
│       ├── plugin-dev/
│       │   └── SKILL.md
│       └── setup/
│           └── SKILL.md
└── atuin-history/       # Atuin history integration
    ├── .claude-plugin/
    │   └── plugin.json
    ├── skills/
    │   └── atuin/
    │       └── SKILL.md
    └── hooks/
        ├── hooks.json
        └── atuin-log.sh
```

**Why relative paths?** The `marketplace.json` uses `"source": "./plugins/name"` (relative path string) rather than GitHub source objects. This is the correct pattern when the plugin ships in the same repo as the marketplace — Claude Code resolves the path relative to `marketplace.json`. The Astral marketplace uses the same pattern.

## Adding More Plugins

To add a new bundled plugin:

1. Create `plugins/<name>/.claude-plugin/plugin.json` with name, version, description, author
2. Add skills at `plugins/<name>/skills/<skill-name>/SKILL.md`
3. Add hooks at `plugins/<name>/hooks/hooks.json` and scripts
4. Add an entry to `.claude-plugin/marketplace.json`:
   ```json
   {
     "name": "my-plugin",
     "source": "./plugins/my-plugin",
     "description": "What this plugin does"
   }
   ```

To list an externally-hosted plugin (lives in its own repo), use a GitHub source object instead:
```json
{
  "name": "external-plugin",
  "source": {"source": "github", "repo": "owner/plugin-repo"},
  "description": "What this plugin does"
}
```

## License

MIT
