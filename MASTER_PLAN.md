# MASTER_PLAN.md — claude-code-market

> Personal Claude Code plugin marketplace for Mastermjr's tools.
> Follows the same patterns as [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official).

## Original Intent

Create a personal plugin marketplace under the Mastermjr GitHub namespace to track all personal repositories and tools written for Claude Code. The marketplace should follow Anthropic's official practices from `anthropics/claude-plugins-official` so that plugins are discoverable and installable via Claude Code's native `/plugin install` system. The first plugin to list is `atuin-claude-ctrl-plugin` (Atuin shell history integration). The marketplace repo lives at `github.com/Mastermjr/claude-code-market`.

## Problem Statement

The atuin-claude-ctrl-plugin (and future personal plugins) are installed via direct filesystem paths in `enabledPlugins`, bypassing Claude Code's marketplace system. This means:
- No discoverability via `/plugin > Discover`
- No install via `/plugin install plugin-name@marketplace`
- No version tracking or marketplace-managed updates
- Other users cannot install the plugins without cloning the repo manually

## Goals

1. Make personal plugins installable via `/plugin install <name>@claude-code-market`
2. Mirror Anthropic's official marketplace structure exactly so Claude Code treats it identically
3. Establish a foundation for listing additional personal plugins over time

## Non-Goals

- Community contributions / `external_plugins/` directory (premature — add later if needed)
- Plugin CI/CD or automated testing in the marketplace repo
- Submission to Anthropic's official marketplace

---

## Decisions

### DEC-MARKET-001: Inline plugins, no submodules
**Status:** accepted
**Rationale:** The official marketplace uses inline copies. Claude Code's plugin system reads files directly from the marketplace clone — it does not perform `git submodule update`. The marketplace-relevant files (`.claude-plugin/`, `skills/`, `hooks/`) are copied into the marketplace repo. Tests and dev artifacts stay in the source repo.

### DEC-MARKET-002: `plugins/` only, no `external_plugins/`
**Status:** accepted
**Rationale:** This is a personal marketplace. All plugins are Mastermjr's own. The `external_plugins/` pattern is for third-party contributions to someone else's marketplace. Start with `plugins/` only.

### DEC-MARKET-003: Plugin directory names match plugin.json `name` field
**Status:** accepted
**Rationale:** The install command resolves by directory name under `plugins/`. Directory name must match `name` in plugin.json for consistent UX (e.g., `atuin-history` → `/plugin install atuin-history@claude-code-market`).

---

## Target Structure

```
claude-code-market/
├── LICENSE              (MIT, exists)
├── README.md            (marketplace overview + install instructions)
├── MASTER_PLAN.md       (this file)
└── plugins/
    └── atuin-history/
        ├── .claude-plugin/
        │   └── plugin.json     # {name, description, author}
        ├── hooks/
        │   ├── hooks.json      # Hook registration
        │   └── atuin-log.sh    # PostToolUse:Bash hook
        ├── skills/
        │   └── atuin/
        │       └── SKILL.md    # /atuin-history:atuin skill
        └── README.md           # Plugin docs
```

---

## Phases

### Phase 1: Marketplace Structure + First Plugin (atuin-history)
**Status:** in-progress

| Item | Description | Weight | Gate |
|------|-------------|--------|------|
| P1-1 | Create `plugins/atuin-history/` with `.claude-plugin/plugin.json`, hooks, skills, README | S | review |
| P1-2 | Create marketplace `README.md` with overview and install instructions | S | review |
| P1-3 | Add `.claude-plugin/plugin.json` to source repo (`atuin-claude-ctrl-plugin`) for parity | S | review |

### Phase 2: Registration + E2E Test
**Status:** pending

| Item | Description | Weight | Gate |
|------|-------------|--------|------|
| P2-1 | Register `claude-code-market` in `known_marketplaces.json` (user's machine) | S | none |
| P2-2 | Test `/plugin install atuin-history@claude-code-market` end-to-end | S | review |

### Phase 3: Future Plugins
**Status:** future

Add more personal plugins as they are developed. Each gets a directory under `plugins/` with the standard `.claude-plugin/plugin.json` manifest.

---

## Completed

_(none yet)_
