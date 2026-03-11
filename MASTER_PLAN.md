# MASTER_PLAN: claude-code-market

## Identity

**Type:** plugin marketplace
**Languages:** JSON (60%), Markdown (30%), Shell (10%)
**Root:** /root/mastermjr-claude-plugin-repo
**Created:** 2026-03-07
**Last updated:** 2026-03-08

Personal Claude Code plugin marketplace under the Mastermjr GitHub namespace. Lists personal plugins for discoverability and installation via Claude Code's native `/plugin install` system. The marketplace repo itself is also a plugin, providing development skills to users who install it.

## Architecture

```
.claude-plugin/       — Marketplace-level plugin manifest and marketplace.json
skills/               — Skills provided by the marketplace plugin itself (e.g., plugin-dev)
.github/workflows/    — CI workflows (doc freshness checks)
```

## Original Intent

> Create a personal plugin marketplace under the Mastermjr GitHub namespace to track all personal repositories and tools written for Claude Code. The marketplace should follow Anthropic's official practices so that plugins are discoverable and installable via Claude Code's native `/plugin install` system. The first plugin to list is `atuin-claude-ctrl-plugin` (Atuin shell history integration). The marketplace repo lives at `github.com/Mastermjr/claude-code-market`.

## Principles

1. **Source Repos Are Canonical** — Plugin code lives in its own repository. The marketplace only references it; it never duplicates runtime files.
2. **Native Over Custom** — Use Claude Code's built-in mechanisms (marketplace.json, GitHub source, plugin caching) instead of building custom infrastructure (sync workflows, inline copies).
3. **Marketplace as Plugin** — The marketplace repo is itself a Claude Code plugin, providing skills and tools that help developers build and distribute plugins.
4. **Documentation is Infrastructure** — The plugin-dev skill is not optional documentation; it is load-bearing infrastructure that prevents agents from making uninformed architecture decisions.
5. **Freshness Over Completeness** — A current, accurate reference is more valuable than an exhaustive but stale one. Automated freshness checks keep the skill aligned with Claude Code's evolving plugin system.

---

## Decision Log

Append-only record of significant decisions across all initiatives. Each entry references the initiative and decision ID. This log persists across initiative boundaries — it is the project's institutional memory.

| Date | DEC-ID | Initiative | Decision | Rationale |
|------|--------|-----------|----------|-----------|
| 2026-03-07 | DEC-MARKET-001 | marketplace-v1 | Inline plugins, no submodules | Originally used inline file copies. Superseded by DEC-MARKET-004. |
| 2026-03-07 | DEC-MARKET-002 | marketplace-v1 | `plugins/` only, no `external_plugins/` | Personal marketplace — all plugins are Mastermjr's own |
| 2026-03-07 | DEC-MARKET-003 | marketplace-v1 | Plugin directory names match plugin.json `name` field | Install command resolves by directory name |
| 2026-03-07 | DEC-MARKET-004 | marketplace-v1 | Plugin directories reference source repos, not static copies | Static copies drift; homepage field points to source |
| 2026-03-07 | DEC-MARKET-005 | marketplace-v1 | GitHub Actions workflow syncs runtime files from source repos | Plugin loader needs inline files — sync bridges the gap |
| 2026-03-08 | DEC-MARKET-006 | marketplace-v2 | marketplace.json with GitHub source replaces plugins/ directory | Claude Code natively supports marketplace.json with GitHub source refs. Supersedes DEC-MARKET-001, 004, 005. |
| 2026-03-08 | DEC-MARKET-007 | marketplace-v2 | Plugin-dev skill as comprehensive SKILL.md in marketplace repo | Marketplace repo becomes a plugin providing the plugin-dev skill |
| 2026-03-08 | DEC-MARKET-008 | marketplace-v2 | Documentation freshness workflow via GitHub Actions | Scheduled check opens issue when skill content may be stale |
| 2026-03-08 | DEC-SKILL-001 | marketplace-v2 | Plugin-dev skill covers full plugin lifecycle | Single SKILL.md covering manifest, source types, components, hooks, distribution |
| 2026-03-11 | DEC-MARKET-009 | marketplace-v2 | Marketplace as setup hub — recommends companion marketplaces via setup skill | The marketplace becomes a "setup hub" for Claude Code. Rather than just listing Mastermjr's plugins, it provides a setup skill that guides users through registering companion marketplaces (starting with astral-sh) and installing recommended plugins. This is documentation + skill, not automated config mutation. |

---

## Active Initiatives

### Initiative: Marketplace V2 + Plugin-Dev Skill
**Status:** active
**Started:** 2026-03-08
**Goal:** Convert marketplace to native marketplace.json model and create comprehensive plugin-dev skill

> The marketplace was built on the assumption that Claude Code's plugin loader cannot follow external references, requiring inline file copies and a sync workflow. This assumption is wrong — Claude Code natively supports `marketplace.json` with GitHub source references. The entire inline-copy architecture is unnecessary. Additionally, Claude agents lack a comprehensive reference for the plugin system, leading to suboptimal decisions. This initiative fixes both: proper marketplace structure and a load-bearing plugin-dev skill.

**Dominant Constraint:** simplicity

#### Goals
- REQ-GOAL-001: Plugins listed via `marketplace.json` using GitHub source references — no inline file copies
- REQ-GOAL-002: Claude agents have a comprehensive, accurate reference for the full plugin system
- REQ-GOAL-003: Plugin-dev skill stays current with Claude Code's evolving plugin system via automated freshness checks

#### Non-Goals
- REQ-NOGO-001: Community plugin submissions — personal marketplace only, premature
- REQ-NOGO-002: Automated plugin testing in CI — no test infrastructure needed for marketplace listings
- REQ-NOGO-003: Submitting to Anthropic's official marketplace — separate effort if ever pursued

#### Requirements

**Must-Have (P0)**

- REQ-P0-001: Create `.claude-plugin/marketplace.json` with atuin-history pointing to `Mastermjr/atuin-claude-ctrl-plugin` via GitHub source
  Acceptance: Given the marketplace is registered, When user runs `/plugin install atuin-history@claude-code-market`, Then Claude Code clones from GitHub source (not inline files)

- REQ-P0-002: Remove inline plugin files (`plugins/atuin-history/` directory) and sync workflow (`sync-atuin-history.yml`)
  Acceptance: Given the migration is complete, When listing repo contents, Then no `plugins/` directory or sync workflow exists

- REQ-P0-003: Create `.claude-plugin/plugin.json` for the marketplace repo itself (making it a plugin that provides the plugin-dev skill)
  Acceptance: Given the marketplace is installed as a plugin, When user types `/claude-code-market:plugin-dev`, Then the skill loads

- REQ-P0-004: Create comprehensive `skills/plugin-dev/SKILL.md` covering the full plugin system
  Acceptance: Given an agent reads the skill, When designing a plugin, Then the skill provides complete reference for manifest, source types, components, hooks, distribution, and CLI commands

- REQ-P0-005: Update `README.md` to reflect new marketplace.json model
  Acceptance: Given a new user visits the repo, When reading the README, Then install instructions and architecture are accurate

**Nice-to-Have (P1)**

- REQ-P1-001: Create GitHub Actions workflow that checks plugin documentation freshness and opens an issue when stale
- REQ-P1-002: Include example `marketplace.json` and `plugin.json` templates in the plugin-dev skill for easy copy-paste

**Future Consideration (P2)**

- REQ-P2-001: Add additional personal plugins to marketplace.json as they are developed
- REQ-P2-002: Skill auto-update mechanism that fetches latest official docs and patches SKILL.md

#### Definition of Done

The marketplace uses `.claude-plugin/marketplace.json` with GitHub source for atuin-history. The `plugins/` directory and sync workflow are removed. The marketplace repo is itself a plugin providing `/claude-code-market:plugin-dev`. The README accurately describes the new architecture. All P0 requirements pass acceptance criteria.

#### Architectural Decisions

- DEC-MARKET-006: marketplace.json with GitHub source replaces plugins/ directory
  Addresses: REQ-P0-001, REQ-P0-002.
  Rationale: Claude Code natively supports `"source": {"source": "github", "repo": "owner/repo"}` in marketplace.json. The marketplace simply declares plugins with their source repos — Claude Code handles cloning and caching to `~/.claude/plugins/cache/`. This eliminates the entire inline-copy architecture: the `plugins/` directory, the sync workflow, and the drift risk. Supersedes DEC-MARKET-001, DEC-MARKET-004, and DEC-MARKET-005.

- DEC-MARKET-007: Plugin-dev skill as comprehensive SKILL.md in marketplace repo
  Addresses: REQ-P0-003, REQ-P0-004.
  Rationale: The marketplace repo itself becomes a Claude Code plugin with `plugin.json` and a `skills/plugin-dev/SKILL.md`. Users who install the marketplace get both: discoverable plugins AND the plugin-dev skill. The skill is a single comprehensive markdown file covering the entire plugin system — manifest format, all source types, all component types, hook events, strict mode, caching, CLI commands, marketplace authoring, and distribution patterns.

- DEC-MARKET-008: Documentation freshness workflow via GitHub Actions
  Addresses: REQ-P1-001.
  Rationale: A scheduled GitHub Actions workflow checks the Claude Code plugin documentation (official repo, release notes) for changes and opens an issue in this repo when the skill content may need updating. This is advisory — a human reviews the changes and updates the skill. Prevents the skill from silently going stale as Claude Code evolves.

- DEC-SKILL-001: Plugin-dev skill covers full plugin lifecycle
  Addresses: REQ-P0-004, REQ-GOAL-002.
  Rationale: The skill must cover everything an agent needs to design, build, and distribute a plugin without prior knowledge. Sections: plugin.json manifest (all fields), source types (relative, GitHub, git URL, git-subdir, npm, pip), component types (skills, commands, agents, hooks, MCP servers, LSP servers, output styles), hook system (events, types, matchers), marketplace.json authoring, strict mode, plugin caching, CLI commands, and `${CLAUDE_PLUGIN_ROOT}` usage.

- DEC-MARKET-009: Marketplace as setup hub — recommends companion marketplaces via setup skill
  Addresses: REQ-GOAL-001.
  Rationale: The marketplace evolves from a passive plugin listing into an active "setup hub" for Claude Code. A `/claude-code-market:setup` skill guides users through registering recommended companion marketplaces (starting with `astral-sh/claude-code-plugins`) and installing useful plugins. The approach is guide-based (presents recommendations and commands) rather than automated config mutation — respecting user agency while reducing discovery friction. This is the simplest viable implementation: one new skill + README section + plugin.json update.

#### Waves

##### Initiative Summary
- **Total items:** 9
- **Critical path:** 3 waves (W1-1 -> W2-1 -> W3-1)
- **Max width:** 4 (Wave 1)
- **Gates:** 7 review, 0 approve

##### Wave 1 (no dependencies)
**Parallel dispatches:** 4

**W1-1: Create marketplace.json and marketplace plugin.json (#3)** — Weight: S, Gate: review
- Create `.claude-plugin/marketplace.json` with structure:
  ```json
  {
    "name": "claude-code-market",
    "owner": {"name": "Mastermjr"},
    "plugins": [
      {
        "name": "atuin-history",
        "source": {"source": "github", "repo": "Mastermjr/atuin-claude-ctrl-plugin"},
        "description": "Bridges Atuin shell history with Claude Code — logs commands and provides live search",
        "homepage": "https://github.com/Mastermjr/atuin-claude-ctrl-plugin"
      }
    ]
  }
  ```
- Create `.claude-plugin/plugin.json` for the marketplace repo itself:
  ```json
  {
    "name": "claude-code-market",
    "version": "2.0.0",
    "description": "Mastermjr's personal plugin marketplace — includes plugin-dev skill",
    "author": {"name": "Mastermjr"},
    "homepage": "https://github.com/Mastermjr/claude-code-market",
    "skills": ["skills/plugin-dev"],
    "strict": true
  }
  ```
- **Integration:** This is the root marketplace definition. Claude Code reads `.claude-plugin/marketplace.json` when the marketplace is registered.

**W1-2: Remove inline plugin files and sync workflow (#4)** — Weight: S, Gate: review
- Delete entire `plugins/` directory (contains `atuin-history/` with inline copies)
- Delete `.github/workflows/sync-atuin-history.yml`
- These are superseded by marketplace.json GitHub source (DEC-MARKET-006)
- **Integration:** Removal only — no new integrations needed

**W1-3: Create plugin-dev skill (#5)** — Weight: M, Gate: review
- Create `skills/plugin-dev/SKILL.md` with comprehensive plugin system reference
- Frontmatter: name, description, instructions for invocation
- Sections covering:
  - Plugin manifest (`plugin.json`) — all fields, required vs optional
  - Source types — relative path, GitHub, git URL, git-subdir, npm, pip with examples
  - Component types — skills, commands, agents, hooks, MCP servers, LSP servers, output styles
  - Hook system — all 14 events, 3 hook types (command, prompt, agent), matchers, `${CLAUDE_PLUGIN_ROOT}`
  - Marketplace authoring — `marketplace.json` format, plugin listing, source configuration
  - Strict mode — true vs false behavior
  - Plugin caching — `~/.claude/plugins/cache/`, path restrictions, symlinks
  - CLI commands — install, uninstall, enable, disable, update, validate, marketplace add
  - Distribution patterns — marketplace vs direct install, versioning with ref/sha
  - Settings scopes — user, project, local, managed
- **Integration:** Referenced by `.claude-plugin/plugin.json` `skills` array

**W1-4: Update README.md (#6)** — Weight: S, Gate: review
- Rewrite to reflect marketplace.json model (not plugins/ directory model)
- Update install instructions (unchanged: `/plugin add-marketplace`)
- Update architecture diagram to show marketplace.json -> GitHub source flow
- Remove references to sync workflow and inline file editing warnings
- Add section about the plugin-dev skill
- **Integration:** No code integration — documentation only

##### Wave 2
**Parallel dispatches:** 2
**Blocked by:** W1-1, W1-3

**W2-1: Create documentation freshness workflow (#7)** — Weight: S, Gate: review, Deps: W1-1, W1-3
- Create `.github/workflows/check-plugin-docs.yml`
- Scheduled weekly: fetch latest Claude Code plugin documentation
- Compare key version indicators (plugin.json schema fields, hook events, source types)
- If changes detected, open a GitHub issue with diff summary
- **Integration:** `.github/workflows/` directory. Opens issues in this repo.

**W2-2: End-to-end validation (#8)** — Weight: S, Gate: review, Deps: W1-1, W1-2, W1-3, W1-4
- Verify marketplace.json is valid and parseable
- Verify atuin-history is installable via the new source model
- Verify plugin-dev skill loads via `/claude-code-market:plugin-dev`
- Verify no stale references to plugins/ directory or sync workflow
- **Integration:** Validation only — no new code

##### Wave 3
**Status:** planned
**Parallel dispatches:** 3
**Blocked by:** W2-2

**W3-1: Create setup skill for marketplace hub configuration (#12)** — Weight: M, Gate: review, Deps: W2-2
- Create `skills/setup/SKILL.md` providing the `/claude-code-market:setup` skill
- The skill guides users through configuring their Claude Code with recommended marketplaces and plugins:
  1. Check which marketplaces are currently registered (`/plugin list-marketplaces`)
  2. Recommend adding `astral-sh/claude-code-plugins` if not already registered
  3. List recommended plugins from each marketplace (uv, ty, ruff from Astral; atuin-history from this marketplace)
  4. Provide copy-paste commands for each: `/plugin add-marketplace astral-sh/claude-code-plugins`, `/plugin install <name>`
  5. Suggest enabling useful plugins based on user's detected environment (Python project? recommend uv+ruff+ty)
- Skill frontmatter:
  ```yaml
  ---
  name: setup
  description: "Guide users through configuring Claude Code with recommended marketplaces and plugins"
  ---
  ```
- The skill is a guided walkthrough, not automation — it presents recommendations and commands, the user decides what to install
- Maintain a "Recommended Marketplaces" registry within the skill content:
  - `astral-sh/claude-code-plugins` — Python tooling (uv, ty, ruff, ty LSP)
  - More can be added over time as the ecosystem grows
- **Integration:** Add `"skills/setup"` to `.claude-plugin/plugin.json` `skills` array. Invoked as `/claude-code-market:setup`.

**W3-2: Update README with Recommended Setup section (#13)** — Weight: S, Gate: review, Deps: W2-2
- Add a "Recommended Setup" section to README.md after the install instructions
- List companion marketplaces with brief descriptions:
  - `astral-sh/claude-code-plugins` — Astral's official Claude Code plugins (uv, ty, ruff)
- Include a "Quick Start" block showing the full recommended setup sequence:
  ```
  /plugin add-marketplace Mastermjr/claude-code-market
  /plugin add-marketplace astral-sh/claude-code-plugins
  /plugin install atuin-history@claude-code-market
  /plugin install uv@astral-sh/claude-code-plugins
  ```
- Mention the `/claude-code-market:setup` skill as an interactive alternative
- **Integration:** README.md — documentation only

**W3-3: Update plugin.json to register setup skill (#14)** — Weight: S, Gate: review, Deps: W2-2
- Add `"skills/setup"` to the `skills` array in `.claude-plugin/plugin.json`
- Update `version` to `"2.1.0"` (new skill = minor version bump)
- Update `description` to mention setup hub capability
- **Integration:** `.claude-plugin/plugin.json` — skill registration

##### Critical Files
- `.claude-plugin/marketplace.json` — the marketplace plugin listing, core of the new model
- `.claude-plugin/plugin.json` — makes the marketplace repo itself a plugin (updated in W3-3)
- `skills/plugin-dev/SKILL.md` — comprehensive plugin system reference
- `skills/setup/SKILL.md` — setup hub skill guiding users through marketplace configuration (W3-1)
- `README.md` — user-facing documentation (updated in W3-2)
- `.github/workflows/check-plugin-docs.yml` — documentation freshness workflow

##### Decision Log
<!-- Guardian appends here after wave completion -->

#### Marketplace V2 Worktree Strategy

Main is sacred. Each wave dispatches parallel worktrees:
- **Wave 1:** `.worktrees/market-v2-w1` on branch `feature/marketplace-v2-wave1` (all 4 items can be done in one worktree since they are tightly coupled file changes)
- **Wave 2:** `.worktrees/market-v2-w2` on branch `feature/marketplace-v2-wave2`
- **Wave 3:** `.worktrees/market-v2-w3` on branch `feature/marketplace-v2-wave3` (all 3 items in one worktree — tightly coupled skill+readme+manifest changes)

#### Marketplace V2 References

- [Claude Code Plugin System Docs](https://docs.anthropic.com/en/docs/claude-code/plugins) — official plugin documentation
- [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) — official marketplace structure reference
- [Mastermjr/atuin-claude-ctrl-plugin](https://github.com/Mastermjr/atuin-claude-ctrl-plugin) — atuin-history source repo
- [astral-sh/claude-code-plugins](https://github.com/astral-sh/claude-code-plugins) — Astral's official Claude Code plugins (uv, ty, ruff)

---

## Completed Initiatives

| Initiative | Period | Phases | Key Decisions | Archived |
|-----------|--------|--------|---------------|----------|
| Marketplace V1 | 2026-03-07 to 2026-03-08 | 3 phases, 11 items | DEC-MARKET-001 through 005 | N/A |

**Marketplace V1 Summary:** Established the claude-code-market marketplace with atuin-history as the first plugin using inline file copies and a GitHub Actions sync workflow. Phases 1-3 completed: marketplace structure, registration and E2E test, source repo references and auto-sync. All completed successfully. The inline-copy approach is superseded by the Marketplace V2 initiative (DEC-MARKET-006).

---

## Parked Issues

| Issue | Description | Reason Parked |
|-------|-------------|---------------|
| Future plugins | Add more personal plugins as they are developed | Ongoing — each new plugin is a trivial marketplace.json entry |
