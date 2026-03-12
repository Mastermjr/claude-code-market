# MASTER_PLAN: claude-code-market

## Identity

**Type:** plugin marketplace
**Languages:** JSON (60%), Markdown (30%), Shell (10%)
**Root:** /root/mastermjr-claude-plugin-repo
**Created:** 2026-03-07
**Last updated:** 2026-03-12

Personal Claude Code plugin marketplace under the Mastermjr GitHub namespace. Lists personal plugins for discoverability and installation via Claude Code's native `/plugin install` system. The marketplace repo itself is also a plugin, providing development skills to users who install it.

## Architecture

```
.claude-plugin/       — Marketplace-level plugin manifest and marketplace.json
skills/               — Skills provided by the marketplace plugin itself (e.g., plugin-dev, setup)
```

## Original Intent

> Create a personal plugin marketplace under the Mastermjr GitHub namespace to track all personal repositories and tools written for Claude Code. The marketplace should follow Anthropic's official practices so that plugins are discoverable and installable via Claude Code's native `/plugin install` system. The first plugin to list is `atuin-claude-ctrl-plugin` (Atuin shell history integration). The marketplace repo lives at `github.com/Mastermjr/claude-code-market`.

## Principles

1. **Source Repos Are Canonical** — Plugin code lives in its own repository. The marketplace only references it; it never duplicates runtime files.
2. **Native Over Custom** — Use Claude Code's built-in mechanisms (marketplace.json, GitHub source, plugin caching) instead of building custom infrastructure (sync workflows, inline copies).
3. **Marketplace as Plugin** — The marketplace repo is itself a Claude Code plugin, providing skills and tools that help developers build and distribute plugins.
4. **Documentation is Infrastructure** — The plugin-dev skill is not optional documentation; it is load-bearing infrastructure that prevents agents from making uninformed architecture decisions.

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
| 2026-03-08 | DEC-SKILL-001 | marketplace-v2 | Plugin-dev skill covers full plugin lifecycle | Single SKILL.md covering manifest, source types, components, hooks, distribution |
| 2026-03-11 | DEC-MARKET-009 | marketplace-v2 | Marketplace as setup hub — recommends companion marketplaces via setup skill | The marketplace becomes a "setup hub" for Claude Code. Rather than just listing Mastermjr's plugins, it provides a setup skill that guides users through registering companion marketplaces (starting with astral-sh) and installing recommended plugins. This is documentation + skill, not automated config mutation. |

---

## Active Initiatives

*No active initiatives.*

---

## Completed Initiatives

| Initiative | Period | Phases | Key Decisions | Archived |
|-----------|--------|--------|---------------|----------|
| Marketplace V1 | 2026-03-07 to 2026-03-08 | 3 phases, 11 items | DEC-MARKET-001 through 005 | N/A |
| Marketplace V2 + Plugin-Dev Skill | 2026-03-08 to 2026-03-12 | 3 waves, 9 items | DEC-MARKET-006, 007, 009; DEC-SKILL-001 | N/A |

**Marketplace V1 Summary:** Established the claude-code-market marketplace with atuin-history as the first plugin using inline file copies and a GitHub Actions sync workflow. Phases 1-3 completed: marketplace structure, registration and E2E test, source repo references and auto-sync. All completed successfully. The inline-copy approach is superseded by the Marketplace V2 initiative (DEC-MARKET-006).

**Marketplace V2 Summary:** Migrated to native `marketplace.json` with GitHub source references (no inline file copies). Created plugin-dev skill (`skills/plugin-dev/SKILL.md`) as a comprehensive plugin system reference. Made the marketplace repo itself a Claude Code plugin (`plugin.json`). Added setup hub skill (`skills/setup/SKILL.md`) guiding users through registering companion marketplaces and installing recommended plugins. Added bootstrap script for fresh install. All 9 wave items completed across 3 waves. Key decisions: DEC-MARKET-006 (marketplace.json model), DEC-MARKET-007 (plugin-dev skill), DEC-MARKET-009 (setup hub), DEC-SKILL-001 (full lifecycle coverage).

---

## Parked Issues

| Issue | Description | Reason Parked |
|-------|-------------|---------------|
| Future plugins | Add more personal plugins as they are developed (REQ-P2-001) | Ongoing — each new plugin is a trivial marketplace.json entry |
