# atuin-history

Bridges [Atuin](https://atuin.sh/) shell history with Claude Code.

**Source repo:** [Mastermjr/atuin-claude-ctrl-plugin](https://github.com/Mastermjr/atuin-claude-ctrl-plugin)

## What It Does

- **PostToolUse:Bash hook** — Every Bash command Claude executes is silently logged into Atuin's shell history database. Gives you a unified view of both human and AI commands.
- **`/atuin-history:atuin` skill** — Teaches Claude how to use the Atuin CLI for searching history, viewing statistics, and troubleshooting.

## Requirements

| Requirement | Version |
|-------------|---------|
| [Atuin](https://atuin.sh/) | v18+ |
| Claude Code | v1.0.33+ |

## Install

```bash
/plugin install atuin-history@claude-code-market
```

## Usage

The hook fires automatically — no action needed. To use the skill:

```
/atuin-history:atuin search for git commands from last week
/atuin-history:atuin show me my stats
```

## License

MIT
