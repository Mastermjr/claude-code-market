# claude-code-market

Personal Claude Code plugin marketplace by [Mastermjr](https://github.com/Mastermjr).

## Install the Marketplace

Register this marketplace so plugins are discoverable via `/plugin > Discover`:

```bash
/plugin add-marketplace https://github.com/Mastermjr/claude-code-market.git
```

## Available Plugins

| Plugin | Description | Source | Install |
|--------|-------------|--------|---------|
| [atuin-history](plugins/atuin-history/) | Bridges Atuin shell history with Claude Code — logs commands and provides live search | [atuin-claude-ctrl-plugin](https://github.com/Mastermjr/atuin-claude-ctrl-plugin) | `/plugin install atuin-history@claude-code-market` |

## How It Works

Plugin runtime files (hooks, skills, commands) must live inline in this repo because Claude Code's plugin loader reads directly from the marketplace clone. But each plugin is developed in its own source repo — **do not edit plugin files here directly.**

A GitHub Actions workflow (`sync-atuin-history.yml`) automatically syncs runtime files from each plugin's source repo into this marketplace. When the source repo changes, the workflow opens a PR here. Merge it to publish the update.

```
Source repo (develop here)          Marketplace repo (install from here)
atuin-claude-ctrl-plugin/    ──CI sync──▶   plugins/atuin-history/
  hooks/                                      hooks/
  skills/                                     skills/
  .claude-plugin/                             .claude-plugin/
```

## Adding Plugins

Each plugin lives under `plugins/<name>/` with the standard structure:

```
plugins/<name>/
├── .claude-plugin/
│   └── plugin.json        # Required: {name, description, author, homepage}
├── hooks/                 # Optional: hook definitions
├── skills/                # Optional: skill definitions
├── commands/              # Optional: slash commands
├── .mcp.json              # Optional: MCP server config
└── README.md
```

For each new plugin, create a corresponding sync workflow in `.github/workflows/` that copies runtime files from the source repo.

## License

MIT
