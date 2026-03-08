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
**Status:** superseded by DEC-MARKET-004
**Rationale:** Originally used inline file copies. Superseded — plugin directories should reference source repos instead.

### DEC-MARKET-002: `plugins/` only, no `external_plugins/`
**Status:** accepted
**Rationale:** This is a personal marketplace. All plugins are Mastermjr's own. The `external_plugins/` pattern is for third-party contributions to someone else's marketplace. Start with `plugins/` only.

### DEC-MARKET-003: Plugin directory names match plugin.json `name` field
**Status:** accepted
**Rationale:** The install command resolves by directory name under `plugins/`. Directory name must match `name` in plugin.json for consistent UX (e.g., `atuin-history` → `/plugin install atuin-history@claude-code-market`).

### DEC-MARKET-004: Plugin directories reference source repos, not static copies
**Status:** accepted
**Rationale:** Static file copies drift from the source repo and require manual syncing on every change. Each plugin directory in the marketplace should contain a `plugin.json` with a `homepage` field pointing to the source repo (e.g., `https://github.com/Mastermjr/atuin-claude-ctrl-plugin`), and a README that directs users to the source. The marketplace-relevant runtime files (hooks, skills) are kept in the marketplace for Claude Code's plugin loader, but the README and plugin.json make the source repo the canonical reference. Future: consider git submodules or a sync CI action to keep marketplace copies in sync with source repos automatically.

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
        │   └── plugin.json     # {name, description, author, homepage → source repo}
        ├── hooks/
        │   ├── hooks.json      # Hook registration
        │   └── atuin-log.sh    # PostToolUse:Bash hook
        ├── skills/
        │   └── atuin/
        │       └── SKILL.md    # /atuin-history:atuin skill
        └── README.md           # Points to source repo as canonical reference
```

---

## Phases

### Phase 1: Marketplace Structure + First Plugin (atuin-history)
**Status:** complete

| Item | Description | Weight | Gate | Status |
|------|-------------|--------|------|--------|
| P1-1 | Create `plugins/atuin-history/` with `.claude-plugin/plugin.json`, hooks, skills, README | S | review | done |
| P1-2 | Create marketplace `README.md` with overview and install instructions | S | review | done |
| P1-3 | Add `.claude-plugin/plugin.json` to source repo (`atuin-claude-ctrl-plugin`) for parity | S | review | done (already existed) |

### Phase 2: Registration + E2E Test
**Status:** complete

| Item | Description | Weight | Gate | Status |
|------|-------------|--------|------|--------|
| P2-1 | Register `claude-code-market` in `known_marketplaces.json` (user's machine) | S | none | done |
| P2-2 | Test `/plugin install atuin-history@claude-code-market` end-to-end | S | review | done — all structure checks pass |

### Phase 3: Source Repo References
**Status:** in-progress

Replace static file copies with proper source repo references per DEC-MARKET-004.

| Item | Description | Weight | Gate |
|------|-------------|--------|------|
| P3-1 | Update `plugins/atuin-history/.claude-plugin/plugin.json` to include `homepage` field pointing to `https://github.com/Mastermjr/atuin-claude-ctrl-plugin` | S | review |
| P3-2 | Update `plugins/atuin-history/README.md` to reference source repo as canonical, with link to issues/contributions | S | review |
| P3-3 | Update marketplace `README.md` to include source repo link in the plugins table | S | review |

### Phase 4: Future Plugins
**Status:** future

Add more personal plugins as they are developed. Each gets a directory under `plugins/` with the standard `.claude-plugin/plugin.json` manifest and `homepage` pointing to its source repo.

---

## Completed

- **Phase 1** — Marketplace structure established with atuin-history as first plugin (commit `e827641`)
- **Phase 2** — Marketplace registered in `known_marketplaces.json`, all structure checks pass
