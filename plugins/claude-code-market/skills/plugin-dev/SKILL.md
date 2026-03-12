---
name: plugin-dev
description: Comprehensive reference for designing, building, and distributing Claude Code plugins. Use when creating plugins, authoring marketplace.json, configuring hooks, skills, agents, MCP/LSP servers, or troubleshooting plugin issues.
---

<!--
@decision DEC-SKILL-001
@title Plugin-dev skill covers full plugin lifecycle
@status accepted
@rationale The skill must cover everything an agent needs to design, build, and distribute
  a plugin without prior knowledge. A single SKILL.md covering manifest, source types,
  all component types, hook system, marketplace authoring, strict mode, caching, CLI
  commands, and distribution patterns prevents agents from making uninformed architecture
  decisions due to gaps in their training data about Claude Code's plugin system.
-->

# Claude Code Plugin System — Complete Reference

$ARGUMENTS

This skill covers the complete Claude Code plugin system: plugin.json manifest, marketplace.json, all component types (skills, commands, agents, hooks, MCP servers, LSP servers), strict mode, caching behavior, CLI commands, and distribution patterns.

---

## 1. Plugin Manifest (`plugin.json`)

The manifest lives at `.claude-plugin/plugin.json` inside your plugin directory. It is optional — Claude Code auto-discovers components in default locations — but required when you need to declare custom paths, metadata, or marketplace behavior.

### All Fields

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "What this plugin does",
  "author": {
    "name": "Author Name",
    "email": "author@example.com",
    "url": "https://example.com"
  },
  "homepage": "https://github.com/owner/my-plugin",
  "repository": "https://github.com/owner/my-plugin.git",
  "license": "MIT",
  "keywords": ["claude", "plugin"],

  "commands": ["commands/"],
  "agents": ["agents/"],
  "hooks": "hooks/hooks.json",
  "mcpServers": ".mcp.json",
  "lspServers": ".lsp.json",
  "outputStyles": "outputStyles/"
}
```

**Required:** `name` (kebab-case string)

**Component path fields** (`commands`, `agents`, `skills`, `outputStyles`): string or array of strings, relative to the plugin root. These supplement the default locations — they do NOT replace them. Both the declared paths and the default paths are searched.

**`"skills"` array:** Claude Code auto-discovers skills from the `skills/` directory. You generally don't need to declare them in `plugin.json`.

**`"strict"` field:** Defaults to `true`. Most plugins don't need to set this explicitly. See [Section 6: Strict Mode](#6-strict-mode) for when you might use it.

**`${CLAUDE_PLUGIN_ROOT}`:** The absolute path to the installed plugin directory. Use this in hook scripts, MCP server configs, and LSP configs whenever you need to reference a file inside the plugin. Never use relative paths or hardcoded absolute paths — those break across users and installations.

---

## 2. Plugin Directory Structure

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json          # ONLY the manifest goes here
├── commands/                # Skill markdown files (one per command)
├── agents/                  # Subagent markdown files (one per agent)
├── skills/                  # Skills — each as <name>/SKILL.md
│   └── my-skill/
│       └── SKILL.md
├── hooks/
│   └── hooks.json           # Hook declarations
├── .mcp.json                # MCP server configurations
├── .lsp.json                # LSP server configurations
├── outputStyles/            # Output style definitions
├── settings.json            # Default settings (only "agent" key supported)
└── scripts/                 # Hook and utility scripts
```

**CRITICAL:** `commands/`, `agents/`, `skills/`, `hooks/`, `.mcp.json`, `.lsp.json`, and `settings.json` go at the **plugin root** — NOT inside `.claude-plugin/`. Only `plugin.json` goes in `.claude-plugin/`.

---

## 3. All 6 Source Types (for `marketplace.json`)

### 3.1 Relative Path (for Bundled Plugins)

```json
{"source": "./plugins/my-plugin"}
```

Must start with `./`. Path is relative to the marketplace.json file's directory (or `metadata.pluginRoot` if set).

Use when the plugin ships in the same repo as the marketplace (monorepo pattern). The Astral marketplace uses this: `"source": "./plugins/astral"`.

**Caveat:** Relative paths only work when the marketplace is added via Git (e.g., `/plugin marketplace add owner/repo`). If added via direct URL to the `marketplace.json` file, relative paths won't resolve. For URL-based distribution, use GitHub, git URL, or npm sources instead.

### 3.2 GitHub (for External Plugins)

```json
{
  "source": {
    "source": "github",
    "repo": "owner/repo",
    "ref": "v1.2.0",
    "sha": "abc123def456abc123def456abc123def456abc123"
  }
}
```

- `repo`: required, `owner/repo` format
- `ref`: optional, branch or tag name (defaults to repo default branch)
- `sha`: optional, 40-character commit SHA for pinned installs

Use when the plugin lives in its own GitHub repository. Claude Code clones the repo and caches it locally. This is the right choice when you don't want to bundle the plugin's source code inside the marketplace repo.

### 3.3 Git URL

```json
{
  "source": {
    "source": "url",
    "url": "https://gitlab.com/owner/repo.git",
    "ref": "main",
    "sha": "abc123def456abc123def456abc123def456abc123"
  }
}
```

Works with any git-accessible URL. For private repos, credentials must be available to git (credential helpers, SSH keys).

### 3.4 Git Subdirectory (Sparse Clone)

```json
{
  "source": {
    "source": "git-subdir",
    "url": "https://github.com/owner/monorepo.git",
    "path": "packages/my-plugin",
    "ref": "main",
    "sha": "abc123def456abc123def456abc123def456abc123"
  }
}
```

Performs a sparse clone — only the specified subdirectory is fetched. Efficient for monorepos.

### 3.5 npm

```json
{
  "source": {
    "source": "npm",
    "package": "@scope/my-plugin",
    "version": "^2.0.0",
    "registry": "https://registry.npmjs.org"
  }
}
```

- `version`: optional semver range or exact version
- `registry`: optional, defaults to the public npm registry

### 3.6 pip

```json
{
  "source": {
    "source": "pip",
    "package": "my-claude-plugin",
    "version": ">=1.0.0",
    "registry": "https://pypi.org/simple"
  }
}
```

- `version`: optional pip version specifier
- `registry`: optional, defaults to PyPI

---

## 4. `marketplace.json` Schema

The marketplace.json declares the marketplace identity and lists available plugins.

### Full Schema

```json
{
  "name": "my-marketplace",
  "owner": {
    "name": "Owner Name",
    "email": "owner@example.com"
  },
  "metadata": {
    "description": "What this marketplace provides",
    "version": "1.0.0",
    "pluginRoot": "plugins/"
  },
  "plugins": [
    {
      "name": "plugin-name",
      "source": "./plugins/plugin-name",
      "description": "What this plugin does"
    }
  ]
}
```

**Required fields:**
- `name`: kebab-case marketplace identifier
- `owner.name`: marketplace owner name
- `plugins[].name`: plugin identifier (used in install commands)
- `plugins[].source`: source reference (see Section 3)

**`plugins[].source` — choosing the right source type:**
- **Bundled** (plugin ships in this repo): `"source": "./plugins/my-plugin"` — relative path string. Only works when marketplace is added via Git.
- **External** (plugin lives in another repo): `"source": {"source": "github", "repo": "owner/repo"}` — GitHub source object. Claude Code clones the repo at install time.
- Both formats are fully supported. Use relative paths for monorepo plugins, GitHub sources for plugins maintained in separate repositories.

**Optional:**
- `owner.email`: contact email
- `metadata.description`: human description of the marketplace
- `metadata.version`: marketplace schema version
- `metadata.pluginRoot`: base directory for relative-path sources
- Plugin entry fields: `description`, `homepage`, `category`, `tags`

**Reserved marketplace names:** `claude-code-marketplace`, `claude-plugins-official`, `anthropic-marketplace`, `anthropic-plugins`, `agent-skills`, `life-sciences`. Names that impersonate official marketplaces are also blocked.

---

## 5. All Plugin Component Types

### 5.1 Skills

**Location:** `skills/<name>/SKILL.md`

**Frontmatter:**

```yaml
---
name: skill-name
description: When to use this skill (shown in autocomplete and agent selection)
disable-model-invocation: false
argument-hint: "[optional argument description]"
context: |
  Additional context injected into the skill
agent: agent-name
allowed-tools:
  - Read
  - Bash
---
```

- `$ARGUMENTS`: placeholder replaced with user-provided arguments at invocation time
- **Namespaced invocation:** `/plugin-name:skill-name` — the plugin name prefix prevents collisions
- `disable-model-invocation`: set true for pure-data skills that shouldn't spawn LLM calls
- `agent`: if set, invokes a specific agent subagent instead of the main model
- `allowed-tools`: restricts which tools the skill can use

### 5.2 Commands

**Location:** `commands/<name>.md`

**Frontmatter:**

```yaml
---
description: Short description (shown in /help)
argument-hint: "[optional argument]"
allowed-tools:
  - Read
  - Grep
---
```

Commands are simpler than skills — they do not have the `skills/<name>/` subdirectory structure. One markdown file per command.

### 5.3 Agents (Subagents)

**Location:** `agents/<name>.md`

**Frontmatter:**

```yaml
---
name: agent-name
description: What this agent does and when to use it
---
```

**Body:** The system prompt for the subagent. Defines the agent's role, capabilities, and constraints. The body becomes the agent's system prompt when it is dispatched.

### 5.4 Hooks (`hooks/hooks.json`)

Hooks intercept Claude Code events. Declare them in `hooks/hooks.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/log-command.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Review this tool call for safety: $ARGUMENTS"
          }
        ]
      }
    ]
  }
}
```

**All 14 hook events:**

| Event | When it fires |
|-------|---------------|
| `PreToolUse` | Before any tool call executes |
| `PostToolUse` | After a tool call succeeds |
| `PostToolUseFailure` | After a tool call fails |
| `PermissionRequest` | When Claude requests elevated permissions |
| `UserPromptSubmit` | When the user submits a prompt |
| `Notification` | When Claude sends a notification |
| `Stop` | When Claude's response generation stops |
| `SubagentStart` | When a subagent session begins |
| `SubagentStop` | When a subagent session ends |
| `SessionStart` | When a Claude Code session begins |
| `SessionEnd` | When a Claude Code session ends |
| `TeammateIdle` | When a teammate agent goes idle |
| `TaskCompleted` | When a task is marked complete |
| `PreCompact` | Before context compaction |

**3 hook types:**

1. **`command`** — Runs a shell command. Input: JSON on stdin with `tool_input`, `cwd`, and context. Exit code 0 = success; non-zero = failure that may block the action.

   ```json
   {"type": "command", "command": "${CLAUDE_PLUGIN_ROOT}/hooks/my-hook.sh"}
   ```

2. **`prompt`** — Evaluates a prompt using the LLM. `$ARGUMENTS` is replaced with the serialized event context.

   ```json
   {"type": "prompt", "prompt": "Verify this action is safe: $ARGUMENTS"}
   ```

3. **`agent`** — Runs an agentic verifier that can use tools (Read, Grep, etc.) to inspect state before allowing the action.

   ```json
   {"type": "agent", "agent": "my-verifier-agent"}
   ```

**Matcher patterns:** Empty string `""` matches all tools. A tool name string (e.g., `"Bash"`) matches that specific tool. Supports glob patterns.

**Hook input (stdin):** JSON object with:
- `tool_input`: the tool's input parameters
- `cwd`: current working directory
- `session_id`: current session ID
- Additional context fields depending on the event

**`${CLAUDE_PLUGIN_ROOT}`:** Always use this variable in hook command paths. Never use relative paths or hardcoded absolute paths.

**Hook executability:** Hook scripts must be executable (`chmod +x`). Always include a shebang line (e.g., `#!/bin/bash`).

### 5.5 MCP Servers (`.mcp.json`)

```json
{
  "mcpServers": {
    "my-server": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/my-server",
      "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"],
      "env": {
        "MY_VAR": "value"
      },
      "cwd": "${CLAUDE_PLUGIN_ROOT}"
    }
  }
}
```

**HTTP transport:**

```json
{
  "mcpServers": {
    "remote-server": {
      "type": "http",
      "url": "https://mcp.example.com/server"
    }
  }
}
```

- `command`: path to executable — use `${CLAUDE_PLUGIN_ROOT}` prefix
- `args`: array of command-line arguments
- `env`: environment variables to set for the server process
- `cwd`: working directory for the server process

### 5.6 LSP Servers (`.lsp.json`)

```json
{
  "my-language": {
    "command": "my-language-server",
    "args": ["--stdio"],
    "extensionToLanguage": {
      ".mylang": "my-language"
    },
    "transport": "stdio",
    "env": {"MY_VAR": "value"},
    "initializationOptions": {},
    "settings": {},
    "workspaceFolder": "${CLAUDE_PLUGIN_ROOT}",
    "startupTimeout": 5000,
    "shutdownTimeout": 3000,
    "restartOnCrash": true,
    "maxRestarts": 3
  }
}
```

**Note:** The LSP server binary must be installed separately — the plugin only configures how Claude Code connects to it. If the binary is not found, the plugin loads but the LSP feature silently does nothing.

### 5.7 Output Styles

**Location:** `outputStyles/` (or custom path via `plugin.json`)

Markdown files that define output formatting rules and styles. Claude Code applies these when generating responses.

### 5.8 Settings (`settings.json`)

```json
{
  "agent": "my-main-agent"
}
```

Currently, only the `agent` key is supported. When set, activates the named agent as the main conversation thread for this plugin. This makes the plugin's agent the primary interface instead of the default Claude model behavior.

---

## 6. Strict Mode

The `strict` field in `plugin.json` (and per-plugin in `marketplace.json`) controls how Claude Code resolves conflicts between the plugin's own `plugin.json` and the marketplace entry.

**`strict: true` (default):**
- `plugin.json` is the authority for component declarations
- Marketplace entry can supplement with additional metadata and components; both are merged
- This is the default — you don't need to set it explicitly

**`strict: false`:**
- The marketplace entry becomes the entire plugin definition
- The plugin repo provides raw files; the marketplace controls which are exposed
- If the plugin's `plugin.json` also declares components, the plugin fails to load
- Use when the marketplace operator wants full control over which components are exposed

Most plugins work fine without setting `strict` at all (defaults to `true`).

---

## 7. Plugin Caching

- Marketplace plugins are copied to `~/.claude/plugins/cache/<plugin-name>/`
- The cache directory is the installed version — hooks, skills, and MCP servers run from here
- **Path traversal is blocked:** plugins cannot reference files outside their plugin directory using `../` or absolute paths that escape the cache dir
- **Symlinks ARE followed** during the cache copy operation — this is an intentional feature you can use to share files across plugins from a monorepo structure
- Use `${CLAUDE_PLUGIN_ROOT}` (which resolves to the cache dir) for all intra-plugin references
- `--plugin-dir <path>`: loads a plugin directly from the given path without caching — designed for development and testing

---

## 8. CLI Commands

### Installation

```bash
# Install from a registered marketplace
claude plugin install <plugin-name>@<marketplace-name>

# Install from a specific scope
claude plugin install <plugin>[@marketplace] --scope user|project|local

# Uninstall
claude plugin uninstall <plugin-name> --scope user|project|local

# Enable / disable without removing
claude plugin enable <plugin-name> --scope user|project|local
claude plugin disable <plugin-name> --scope user|project|local

# Update
claude plugin update <plugin-name> --scope user|project|local|managed

# Validate plugin structure (run from plugin root)
claude plugin validate .
```

### Marketplace Registration

```bash
# From within Claude Code (slash commands)
/plugin marketplace add <source>
/plugin marketplace update
```

**Source formats for marketplace add:**
- GitHub: `owner/repo` or `https://github.com/owner/repo`
- Other git: `https://gitlab.com/owner/repo`
- Local: `./path/to/local-marketplace`

### Settings Scopes

| Scope | File | When to Use |
|-------|------|-------------|
| `user` | `~/.claude/settings.json` | Personal plugins across all projects |
| `project` | `.claude/settings.json` | Team-shared plugins (commit to repo) |
| `local` | `.claude/settings.local.json` | Per-project, not committed |
| `managed` | Managed by IT/admin | Enterprise lockdown configurations |

---

## 9. Distribution & Versioning

### SemVer

Use MAJOR.MINOR.PATCH versioning in `plugin.json`:
- MAJOR: breaking changes (removed commands, changed hook behavior)
- MINOR: new features, new skills/commands added
- PATCH: bug fixes, documentation updates

**Version resolution:** Version in `plugin.json` takes priority over the version declared in `marketplace.json`. Bump version for users to receive updates — Claude Code uses the version for cache invalidation.

### Release Channels via Ref Pinning

```json
{
  "source": {
    "source": "github",
    "repo": "owner/plugin",
    "ref": "stable"
  }
}
```

Use branch names as channels (`stable`, `latest`, `beta`) or pin to tags (`v1.2.0`) for locked installs. SHA pinning (`sha`) provides the highest reproducibility guarantee.

### Private Repos

- Works if `git clone <url>` works in the user's shell (credential helpers, SSH keys, HTTPS tokens)
- For auto-updates from private repos, these environment variables must be set:
  - GitHub: `GITHUB_TOKEN`
  - GitLab: `GITLAB_TOKEN`
  - Bitbucket: `BITBUCKET_TOKEN`

---

## 10. Marketplace Hosting & Distribution

### GitHub (Recommended)

Host `marketplace.json` in a GitHub repo and register with:

```bash
/plugin marketplace add owner/repo
```

or equivalently:

```bash
/plugin marketplace add https://github.com/owner/repo
```

### Other Git Hosts

```bash
/plugin marketplace add https://gitlab.com/owner/marketplace-repo
/plugin marketplace add https://bitbucket.org/owner/marketplace-repo
```

### Team Configuration (`.claude/settings.json`)

```json
{
  "extraKnownMarketplaces": {
    "my-org-marketplace": {
      "source": {
        "source": "github",
        "repo": "my-org/claude-plugins"
      }
    }
  },
  "enabledPlugins": {
    "my-plugin@my-org-marketplace": true
  }
}
```

Commit this to your project repo to share marketplace registrations with your team.

### Managed / Enterprise Restrictions

Managed settings can restrict which marketplaces are allowed:

```json
{
  "strictKnownMarketplaces": []
}
```

- Empty array `[]`: lockdown — no external marketplaces allowed
- Array with entries: allowlist — only listed marketplaces allowed
- Entries support `hostPattern` and `pathPattern` for regex matching

### Local Testing

```bash
/plugin marketplace add ./path/to/local-marketplace
```

Or load a plugin directly without caching (bypasses marketplace entirely):

```bash
claude --plugin-dir ./my-plugin-dev-dir
```

---

## 11. Debugging & Troubleshooting

### Debug Mode

```bash
claude --debug
```

Or within a session:

```
/debug
```

Debug mode shows plugin loading details: which manifests were found, which components were registered, and any errors during initialization.

### Common Issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| Skill not found | Wrong directory structure | Skills must be at `skills/<name>/SKILL.md` — not `skills/<name>.md` |
| Hook not executing | Script not executable | `chmod +x hooks/my-hook.sh` |
| Hook script not found | Using relative path | Use `${CLAUDE_PLUGIN_ROOT}/hooks/my-hook.sh` |
| MCP server fails to start | Wrong command path | Use `${CLAUDE_PLUGIN_ROOT}/servers/my-server` |
| LSP not working | Binary not installed | The plugin configures the connection; the binary must be installed separately |
| Invalid plugin.json | Schema error | Run `claude plugin validate .` from the plugin root |
| Components in wrong dir | Manifest misread | Commands/agents/skills go at plugin root, NOT inside `.claude-plugin/` |
| Marketplace not found | Wrong format | Use `owner/repo` for GitHub or full URL for other hosts |
| Auto-updates not working | Missing token | Set `GITHUB_TOKEN` / `GITLAB_TOKEN` / `BITBUCKET_TOKEN` |

### Hook Troubleshooting

1. Verify the script is executable: `ls -la hooks/`
2. Verify the shebang line: `head -1 hooks/my-hook.sh` — should be `#!/bin/bash` or similar
3. Check `${CLAUDE_PLUGIN_ROOT}` is set: run the hook manually with `CLAUDE_PLUGIN_ROOT=/path/to/plugin ./hooks/my-hook.sh`
4. Test hook input: pipe sample JSON to the script to verify it parses correctly
5. Check hook output: hooks must exit 0 to allow the action; non-zero blocks it

### MCP Troubleshooting

1. Verify the command exists: `which <command>` or `ls ${CLAUDE_PLUGIN_ROOT}/servers/`
2. Test the server manually: run the command directly and verify it starts
3. Check logs: `claude --debug` shows MCP connection details
4. Verify the command path uses `${CLAUDE_PLUGIN_ROOT}` — not hardcoded absolute paths

---

## 12. Quick Reference Templates

### Minimal `plugin.json`

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "What my plugin does",
  "author": {"name": "MyName"},
  "homepage": "https://github.com/MyName/my-plugin"
}
```

Skills are auto-discovered; `"skills"` array is optional. `"strict"` defaults to `true`; omit unless you need `strict: false` behavior.

### `marketplace.json` with Mixed Sources (Bundled + External)

```json
{
  "name": "my-marketplace",
  "owner": {"name": "MyName"},
  "plugins": [
    {
      "name": "my-bundled-plugin",
      "source": "./plugins/my-bundled-plugin",
      "description": "Plugin shipped in the same repo"
    },
    {
      "name": "my-external-plugin",
      "source": {"source": "github", "repo": "MyName/my-external-plugin"},
      "description": "Plugin from a separate GitHub repo"
    }
  ]
}
```

Bundled plugins use relative paths. External plugins use GitHub source objects. Both are fully supported — choose based on where the plugin's source code lives.

### `hooks/hooks.json` with PostToolUse Example

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/post-bash.sh"
          }
        ]
      }
    ]
  }
}
```

### `skills/<name>/SKILL.md` with Frontmatter

```markdown
---
name: my-skill
description: What this skill does and when to use it
argument-hint: "[optional: describe what arguments this accepts]"
allowed-tools:
  - Read
  - Bash
---

# My Skill

$ARGUMENTS

Your skill content here. $ARGUMENTS is replaced with user-provided text at invocation.
```

### `.mcp.json` with Command Server

```json
{
  "mcpServers": {
    "my-server": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/my-server",
      "args": ["--stdio"],
      "env": {},
      "cwd": "${CLAUDE_PLUGIN_ROOT}"
    }
  }
}
```

### `.lsp.json`

```json
{
  "my-language": {
    "command": "my-language-server",
    "args": ["--stdio"],
    "extensionToLanguage": {
      ".myl": "my-language"
    },
    "restartOnCrash": true,
    "maxRestarts": 3
  }
}
```

---

## 13. Official Documentation

For the latest specifications, refer to the official Claude Code documentation:

- **[Create plugins](https://code.claude.com/docs/en/plugins)** — plugin creation guide, directory structure, testing
- **[Create and distribute a marketplace](https://code.claude.com/docs/en/plugin-marketplaces)** — marketplace.json schema, all source types, hosting, distribution
- **[Plugins reference](https://code.claude.com/docs/en/plugins-reference)** — complete technical specifications, manifest schema, caching, debugging
- **[Discover and install plugins](https://code.claude.com/docs/en/discover-plugins)** — user guide for finding and installing plugins
- **[Agent Skills](https://code.claude.com/docs/en/skills)** — skill authoring, frontmatter, progressive disclosure
- **[Hooks](https://code.claude.com/docs/en/hooks)** — hook events, types, matchers, input format

This skill is derived from these docs. When this skill and the official docs disagree, the official docs are correct.

---

## Summary: Key Rules to Remember

1. **`${CLAUDE_PLUGIN_ROOT}`** — always use it for paths to files inside your plugin. Never hardcode paths.
2. **Component directories at plugin root** — `skills/`, `hooks/`, `agents/`, `commands/` go at the plugin root, NOT inside `.claude-plugin/`.
3. **Only `plugin.json` in `.claude-plugin/`** — the manifest directory holds only the manifest.
4. **Skills use subdirectory structure** — `skills/<name>/SKILL.md`, not `skills/<name>.md`.
5. **Hook scripts must be executable** — `chmod +x` and include a shebang.
6. **Bump version for updates to propagate** — cached plugins use version for invalidation.
7. **Skills are auto-discovered** — Claude Code finds skills in `skills/`. You generally don't need a `"skills"` array in `plugin.json`.
8. **Strict mode defaults to `true`** — most plugins don't need to set it. Only use `strict: false` for marketplace-controlled plugin surfaces.
9. **Choose the right source type** — relative paths (`"./plugins/name"`) for bundled plugins, GitHub source objects for external repos. Both work in `marketplace.json`.
10. **LSP binaries are external** — the plugin configures the connection; users install the binary.
