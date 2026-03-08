# claude-code-market

Personal Claude Code plugin marketplace by [Mastermjr](https://github.com/Mastermjr).

## Install the Marketplace

Register this marketplace so plugins are discoverable via `/plugin > Discover`:

```bash
/plugin add-marketplace https://github.com/Mastermjr/claude-code-market.git
```

## Available Plugins

| Plugin | Description | Install |
|--------|-------------|---------|
| [atuin-history](plugins/atuin-history/) | Bridges Atuin shell history with Claude Code — logs commands and provides live search | `/plugin install atuin-history@claude-code-market` |

## Adding Plugins

Each plugin lives under `plugins/<name>/` with the standard structure:

```
plugins/<name>/
├── .claude-plugin/
│   └── plugin.json        # Required: {name, description, author}
├── hooks/                 # Optional: hook definitions
├── skills/                # Optional: skill definitions
├── commands/              # Optional: slash commands
├── .mcp.json              # Optional: MCP server config
└── README.md
```

## License

MIT
