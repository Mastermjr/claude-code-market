# atuin-history

Bridges [Atuin](https://atuin.sh/) shell history with Claude Code.

> **Canonical source:** [Mastermjr/atuin-claude-ctrl-plugin](https://github.com/Mastermjr/atuin-claude-ctrl-plugin)
> Bug reports, feature requests, and contributions go to the source repo.

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

## Source & Sync

This marketplace listing contains the runtime files (hooks, skills) needed by Claude Code's plugin loader. The canonical source of truth — including tests, architecture docs, and full commit history — lives at:

**https://github.com/Mastermjr/atuin-claude-ctrl-plugin**

### How sync works

**DO NOT edit the plugin files in this marketplace repo directly.** They are auto-synced from the source repo by a GitHub Actions workflow (`sync-atuin-history.yml`).

The sync triggers in three ways:
1. **`repository_dispatch`** — the source repo sends a `sync-atuin-history` event after each push (set up a webhook or add a dispatch step to the source repo's CI)
2. **Manual** — run `gh workflow run sync-atuin-history.yml` in this repo
3. **Weekly fallback** — runs every Monday at 06:00 UTC as a safety net

The workflow clones the source repo, copies runtime files (`.claude-plugin/`, `hooks/`, `skills/`) into `plugins/atuin-history/`, and opens a PR if anything changed. Merge the PR to update the marketplace.

### To make changes to this plugin

1. Edit files in [atuin-claude-ctrl-plugin](https://github.com/Mastermjr/atuin-claude-ctrl-plugin)
2. Push to the source repo
3. The sync workflow creates a PR here automatically
4. Merge the PR

## License

MIT
