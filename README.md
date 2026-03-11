# claude-code-market

Personal Claude Code plugin marketplace by [Mastermjr](https://github.com/Mastermjr).

## Install the Marketplace

Register this marketplace so plugins are discoverable and installable:

```
/plugin marketplace add Mastermjr/claude-code-market
```

## Available Plugins

| Plugin | Description | Source | Install |
|--------|-------------|--------|---------|
| [atuin-history](https://github.com/Mastermjr/atuin-claude-ctrl-plugin) | Bridges Atuin shell history with Claude Code — logs commands and provides live search | [atuin-claude-ctrl-plugin](https://github.com/Mastermjr/atuin-claude-ctrl-plugin) | `/plugin install atuin-history@claude-code-market` |

## The plugin-dev Skill

This marketplace repo is itself a Claude Code plugin. Install it to get the `plugin-dev` skill — a comprehensive reference for designing, building, and distributing Claude Code plugins.

The skill covers: plugin.json manifest (all fields), all 6 source types, all component types (skills, commands, agents, hooks, MCP servers, LSP servers), the full hook system (all 14 events, 3 hook types), marketplace.json authoring, strict mode, plugin caching, CLI commands, and distribution patterns.

After installing the marketplace, invoke the skill at any time:

```
/claude-code-market:plugin-dev
```

Or with a specific question:

```
/claude-code-market:plugin-dev How do I add a PostToolUse hook to my plugin?
```

## How It Works

```
marketplace.json                    Claude Code
  plugins[]:
    name: atuin-history    ──────▶  /plugin install atuin-history@claude-code-market
    source:
      github: Mastermjr/            Claude Code clones the source repo directly
              atuin-claude-          into ~/.claude/plugins/cache/atuin-history/
              ctrl-plugin
```

Plugin code lives in its own source repository. This marketplace only declares where each plugin lives — it never duplicates runtime files. Claude Code handles cloning and caching natively.

## Architecture

```
.claude-plugin/
├── marketplace.json     # Lists available plugins with GitHub source references
└── plugin.json          # Makes this repo itself a plugin (provides plugin-dev skill)

skills/
└── plugin-dev/
    └── SKILL.md         # Comprehensive plugin system reference
```

## Adding More Plugins

Each entry in `.claude-plugin/marketplace.json` is a plugin listing. To add a new plugin:

1. Add an entry to the `plugins` array in `marketplace.json`
2. Point `source` at the plugin's GitHub repo (or any supported source type)

No sync workflows. No inline file copies. Claude Code handles the rest.

## License

MIT
