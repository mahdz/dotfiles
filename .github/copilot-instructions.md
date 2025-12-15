---
description: AI rules derived by SpecStory from the project AI interaction history
globs: *
---

# GitHub Copilot Instructions

Last updated: 2025-12-04

## Purpose

Guide Copilot and AI agents to make safe, XDG-compliant, and minimal edits to this personal dotfiles repo. All rules are derived from real project usage and `AGENTS.md`.

## Key Locations

- **Dotfiles repo:** `/Users/mh/` (bare Git repository)
- **Git directory:** `$HOME/.dotfiles/`
- **Git work tree:** `$HOME`
- **Main scripts:** `bin/` and `.local/bin/`
- **Configs:** `.config/` (XDG-compliant)
- **Documentation:** `AGENTS.md`, Vault/02-projects/dotfiles/memory-bank/
- **Warp AI shortcuts:** `ds` (status), `dan` (add -n), `da` (add), `dc` (commit), `dp` (push)

## Core Principles

- **Bare-repo workflow:** Use the `dots` wrapper for all Git operations. Located at `~/.config/zsh/custom/plugins/dotfiles/dotfiles.plugin.zsh`
- **Minimal, surgical changes:** Prefer small PRs, avoid sweeping refactors. Never edit more files than necessary.
- **Never commit secrets or private keys:** If secrets are needed, instruct user to use env vars or secret managers.
- **Respect deny-all `.gitignore` strategy:** Always update `.gitignore` when adding tracked files, then test with `dots add -n`. Include full directory paths when un-ignoring nested items.
- **Do not modify UV-managed symlinks:** Files in `~/.local/bin/` are ephemeral and should not be tracked.
- **Preserve XDG structure:** Configs in `.config/`, user scripts in `.local/bin/`, helper scripts in `bin/`.
- **Shell scripts:** Target Zsh with `emulate -L zsh`, use `setopt`, follow patterns in `AGENTS.md` and `.config/zsh/`.
- **Aliases:** Follow expansion-safe patterns from `AGENTS.md` and `.config/zsh/`. Never change global alias semantics.
- **Tool management:** Prefer `mise` for dev tools, `uv` for Python tools. Run `mise reshim` after tool installations.

## Safety Rules

**ALWAYS test first:**

- Run `dots add -n <path>` before staging any changes
- New `.gitignore` patterns can break existing tracking rules

**NEVER track:**

- UV symlinks in `$HOME/.local/bin/` (frequently change)
- Cache files, logs, or temporary data
- Secrets, private keys, or sensitive credentials

**NEVER suggest:**

- Alternate bootstrap flows - always reference `AGENTS.md`
- Tracking files in `~/.local/bin/` or cache directories
- Changes to global alias behavior or semantics
- Running arbitrary non-Git commands with `GIT_DIR` or `GIT_WORK_TREE` environment variables set.

## Developer Workflows

### Git Operations

**Enhanced dots function (from ~/.config/zsh/custom/plugins/dotfiles/dotfiles.plugin.zsh):**
```zsh
dots() {
    command git --git-dir="${DOTFILES:-$HOME/.dotfiles}" --work-tree="$HOME" "$@"
}
```

**Daily workflow:**
```zsh
dots status                          # Check what changed
dots add -n <path>                   # DRY RUN first - mandatory!
dots add <path>                      # Stage after dry run passes
dots commit -m "simple message"      # Commit changes
dots push                            # Sync to GitHub
dots pull                            # Pull latest changes
dots diff                            # View changes
```

**Warp AI shortcuts:**
```zsh
ds                                  # dots status
dan <filename>                      # dots add -n (dry-run first!)
da <filename>                       # dots add (after dry-run passes)
dc -m "message"                     # dots commit
dp                                  # dots push
dl                                  # dots pull
dd                                  # dots diff
```

### Validation Steps

1. **Always** run `dots add -n` first (critical safety check)
2. Only run `dots add` if dry run passes without errors
3. Run `dots commit` with clear, descriptive message
4. For shell files, provide revert command: `dots checkout -- <file>`

### Tool Management

```zsh
# Try Homebrew first for system tools
brew install <tool>
# Use mise for developer tools
mise install <tool>@latest
# Use uv for Python tools
uv tool install <python-tool>
# Fix broken tool links
mise reshim
```

`uv pip install <package>` installs a specified Python package into the active project's virtual environment managed by `uv` and `mise`.

### Log Management

```zsh
# Rotate and compress old log files
rotate-logs --dry-run                # Preview rotation actions
rotate-logs --days 7 --keep 5       # Rotate logs older than 7 days, keep 5 archives
rotate-logs                          # Default: 7 days, 5 archives

# Check archived logs
ls -la ~/.basic-memory/archives/     # View compressed archives
zcat ~/.basic-memory/archives/name.log.gz | less  # View archived content
```

### New Machine Setup

See `AGENTS.md` for canonical steps. Key commands:
```zsh
git clone --bare git@github.com:mahdz/dotfiles.git $HOME/.dotfiles
dots() { git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"; }
mkdir -p ~/.dotfiles-backup && dots checkout
dots config --local status.showUntrackedFiles no
```

## Project-Specific Patterns

- **Memory Bank:** Documentation in `Vault/02-projects/dotfiles/memory-bank/`
- **`.gitignore`:** Deny-all strategy with 200+ specific patterns. Include full directory paths when un-ignoring nested items.
- **Python tools:** Always install via `mise`, manage packages with `uv`
- **ZSH configs:** Located in `$ZDOTDIR` (`.config/zsh/`), follow established patterns
- **VS Code:** Use workspace file, pass Git env vars for correct bare repo integration
- **Mise**: `config.toml` in `.config/mise/` to manage npm tools globally.

## Troubleshooting

**Tool not found after install:**
- Run `mise reshim` to refresh tool links
- Check `echo $PATH` for correct loading

**File not tracking despite `.gitignore`:**
- Verify pattern order (later rules override earlier ones)
- Test with `dots add -n <filename>` to debug

**Something broke:**
- Check changes with `dots status` and `dots diff`
- Revert with `dots checkout HEAD -- <filename>`

**VS Code Extension Activation Error (`Cannot activate because ./dist/extension not found`):**
- Occurs when VS Code extension can't find its main JavaScript file.
- **Solution:** Check `package.json`'s `main` field. It should point to the correct `.js` file (e.g., `"main": "./dist/extension.js"`).

**Prettier Extension Error (`Cannot find module 'prettier'`):**
- The Prettier VS Code extension (`esbenp.prettier-vscode`) cannot find the `prettier` npm package.
- **Fix:** In your project root, run `npm install --save-dev prettier`. If using `mise` for Node.js, ensure the correct Node version is active. `prettier.resolveGlobalModules` should be disabled. To force a specific Prettier version, set `"prettier.prettierPath"` in your VS Code settings to your project’s local Prettier (e.g., `./node_modules/prettier`).

**Copilot Chat Error (`TypeError: e is not iterable`):**
- The Copilot Chat extension is encountering a bug where it expects an iterable (like an array) but receives something else. This is likely an upstream bug.
  - **Fix:** Update the extension. If the bug persists, disable and re-enable it. Report the bug to the GitHub Copilot Chat repository.

**Git Extension Error (`Failed to execute git`):**
- VS Code cannot run Git commands, possibly due to Git not being installed or not in your `$PATH`, permissions issues, or misconfigured Git settings.
  - **Fix:** Check Git installation (`command -v git`). If not found, install Git (`brew install git`). Ensure your user can access the Git binary and your repositories. In VS Code, open settings and search for `git.path`. Set it if your Git binary is in a non-standard location.

**Bash IDE Error (`Cannot find module 'vscode-languageclient/node'`):**
- The Bash IDE extension (`mads-hartmann.bash-ide-vscode`) is missing a dependency.
  - **Fix:** Reinstall the extension. If installed from source, run `npm install` in the extension’s directory to install dependencies.

**GitLens Error (`Cannot read properties of undefined (reading 'dispose')`):**
- This is a minor bug during extension shutdown and is usually harmless.
  - **Fix:** Make sure you’re on the latest version. If you don’t see problems during normal use, you can safely ignore this error.

**VS Code is not loading dotfiles git repo:**
- Check `git.ignoredRepositories` setting. It should NOT include `"/Users/mh/.dotfiles"`.

**VS Code Permission Errors:**
- If VS Code shows permission errors when trying to delete files in the cache directory, fix the permissions on macOS:
  1. Open Terminal and run this command to take ownership of the directory and its contents:
```bash
sudo chown -R $USER:staff /Applications/code-portable-data
```

  2. Then set the correct permissions:
```bash
sudo chmod -R 755 /Applications/code-portable-data
```
  If you want to only fix specific directories that show errors in the log:
```bash
sudo chmod 755 "/Applications/code-portable-data/user-data/CachedExtensionVSIXs/.trash"
sudo chmod 755 "/Applications/code-portable-data/user-data/logs"
```
  After running these commands, restart VS Code.

**Zsh Parse Errors:**
- When Zsh reports errors like "Couldn't parse this brace group" or "This } is literal", it typically indicates a syntax error in your `.zshrc` file, such as a missing semicolon or newline before a closing brace in a function definition.
  - **Fix:** Add a semicolon or newline before the closing brace. For example:
````zsh
is-not-warpterm() { [[ $TERM_PROGRAM != "WarpTerminal" ]]; }
# corrected:
is-not-warpterm() { [[ $TERM_PROGRAM != "WarpTerminal" ]]; }
````

## Where to Look for Patterns

- **`AGENTS.md`** - Canonical workflow examples and patterns
- **`Vault/02-projects/dotfiles/memory-bank/`** - Setup and operational guides
- **`.github/prompts/`** - Generator blueprints and exemplars

## Quick Edit Checklist

- [ ] `dots add -n <path>` (dry run) - verify changes won't break tracking
- [ ] Update `.gitignore` if adding tracked files (include full paths)
- [ ] Test tools with `mise reshim` if new ones added
- [ ] Provide revert command `dots checkout -- <file>` for shell file changes
- [ ] Include validation steps in any PR description
- [ ] Never touch `~/.local/bin/` symlinks or secrets

## VS Code Configuration Tips

- The recommended way to work with a bare repo for dotfiles is to open your `$HOME` directory in VS Code using a workspace file that is configured for your dotfiles setup.

### Workspace File Benefits
- **Custom folder exclusions:** Hide system/user folders (like ``, ``, etc.) from the sidebar.
- **Per-project settings:** Set editor preferences (tab size, rulers, word wrap) just for your dotfiles.
- **Extension recommendations:** Suggest or require extensions only when working on dotfiles.
- **Environment variables:** Set workspace-specific terminal environment variables.
- **Multiple folders:** Add other related folders (like scripts or config backups) to the workspace if needed.
-  Using a workspace file gives you much more control and a cleaner, more focused experience for dotfiles management.

### Example .code-workspace file

````jsonc
{
  "folders": [
    {
      "name": "🏠 dotfiles",
      "path": "/Users/mh"
    }
  ],
  "settings": {
    // Git integration for bare repo
    "git.enabled": true,
    "git.detectSubmodules": false,
    // Prevent VS Code from auto-initializing Git in $HOME
    "git.autoRepositoryDetection": true,
    // Exclude noisy system/user folders from sidebar
    "files.exclude": {
      "**/.Trash": true,
      "**/Library": true,
      "**/Movies": true,
      "**/Music": true,
      "**/Pictures": true,
      "**/Public": true,
      "**/.DS_Store": true,
      "**/.cache": true,
      "**/.local/share/Trash": true,
      "**/.dotfiles": true,
      "**/node_modules": true,
      "**/.git": true
    },
    "files.watcherExclude": {
      "**/.git/objects/**": true,
      "**/.git/subtree-cache/**": true,
      "**/node_modules/**": true,
      "**/Library/**": true,
      "**/Downloads/**": true,
      "**/Pictures/**": true,
      "**/Movies/**": true,
      "**/Music/**": true
    },
    "search.exclude": {
      "Library": true,
      "Downloads": true,
      "Pictures": true,
      "Movies": true,
      "Music": true
    },
    // Editor defaults for dotfiles
    "editor.tabSize": 2,
    "editor.insertSpaces": true,
    "editor.rulers": [80],
    "editor.wordWrap": "on",
    // Terminal integration
    "terminal.integrated.defaultProfile.osx": "zsh",
    "terminal.integrated.env.osx": {
      "XDG_CONFIG_HOME": "${env:HOME}/.config",
      "XDG_DATA_HOME": "${env:HOME}/.local/share"
    },
    // Extension recommendations
    "extensions.ignoreRecommendations": false
  },
  "extensions": {
    "recommendations": [
      "foxundermoon.shell-format",
      "timonwong.shellcheck",
      "ms-vscode.cpptools",
      "streetsidesoftware.code-spell-checker",
      "yzhang.markdown-all-in-one",
      "bierner.markdown-preview-github-styles",
      "eamodio.gitlens",
      "editorconfig.editorconfig",
      "dbaeumer.vscode-eslint",
      "esbenp.prettier-vscode"
    ]
  }
}
````

- Ensure the workspace file path in your function matches your actual file location and project conventions.

### VS Code Settings

- If you use Mise to manage your global npm tools (including Prettier), you **do not need to enable** the `prettier.resolveGlobalModules` setting in VS Code.
- If you want to force a specific Prettier version, set `"prettier.prettierPath"` in your VS Code settings to your project’s local Prettier (e.g., `./node_modules/prettier`).

### Git Configuration

- In a bare git repo configuration, set the worktree and gitdir in the .gitconfig:
```ini
[core]
    worktree = ~
    gitdir = ~/.dotfiles
```

### VS Code Environment Variables

- Setting `GIT_DIR` and `GIT_WORK_TREE` in `terminal.integrated.env.osx` would affect all terminals in VS Code, which would break Git functionality for any other repositories you work with.

### VS Code Source Control

- If VS Code Source Control is not opening your dotfiles repo, check `git.ignoredRepositories` setting. It should NOT include `"/Users/mh/.dotfiles"`.

### Zsh Configuration

- Avoid global aliases (e.g., `alias -g dot='dots'`) to prevent surprising expansions. Use regular aliases instead.
- To prevent function/alias name collisions (e.g., `dotcode`), use distinct names (e.g., `dotedit`) or keep the function and remove the alias.

### Dots Function Enhancements

- Check for the bare repo's presence within the `dots` function for added safety.

### Excludesfile Path

- Use meaningful naming for excludesfile paths (e.g., `$HOME/.config/dotfiles/excludes`).

### Recommended Zsh Refinements

Apply the refinements below before merging — they fix undefined helpers, avoid surprising fallback behavior, prevent alias shadowing/global alias pitfalls, and add small safety checks.

Minimal patch (safe, small, surgical) to apply to the current file (`~/.config/zsh/custom/plugins/dotfiles/dotfiles.plugin.zsh`):

````zsh
# ...existing code...

# --- Helpers ---
# small portable command-exists helper
_command_exists() { command -v "$1" >/dev/null 2>&1 }

dotcode() {
  emulate -L zsh
  # keep this simple; avoid setopt changes here
  if _command_exists code; then
    dots code "$DOT_WORKSPACE"
  else
    echo "VSCode 'code' command not found."
  fi
}

show_dotfiles_workspace() {
  if [[ -f "$DOT_WORKSPACE" ]]; then
    cat "$DOT_WORKSPACE"
  else
    echo "Workspace file not found: $DOT_WORKSPACE" >&2
    return 1
  fi
}

# ...existing code...

# --- Aliases ---
# Use normal alias to avoid global alias surprises
alias dot='dots'

# Dotfiles shortcuts for Warp AI suggestions
alias ds='dots status'
alias da='dots add'
alias dan='dots add -n'  # dry-run first!
alias dc='dots commit'
alias dp='dots push'
alias dl='dots pull'
alias dd='dots diff'

alias zdot="cd \"$ZDOTDIR\""
alias zcust="cd \"$ZSH_CUSTOM\""
alias dotg="dots git"

if _command_exists code; then
  alias dotty="dots code \"$DOT_WORKSPACE\""
fi

# dotfiles
alias dotdir='cd "$DOTFILES"'
# avoid shadowing dotcode function; use dotedit for opening repo in editor
alias dotedit='cd "$DOTFILES" && code .'

# only set vault hash if VAULT_PATH is present
[[ -n "$VAULT_PATH" && -d "$VAULT_PATH" ]] && hash -d vault="$VAULT_PATH"

# ...existing code...
````

### Debugging

- When creating debugging functions, always write to `stderr` (`>&2`).
- Use parameter expansion `${DEBUG:-0}` to provide a default value for debug flags.
- To add color support, define a color function and use it within the debug function. Respect the `NO_COLOR` environment variable to disable colors when needed. Example:

````bash
# Debug configuration with color support
DEBUG=${DEBUG:-0}  # Default to off, enable with DEBUG=1
NO_COLOR=${NO_COLOR:-0}

# ANSI color function for purple debug messages
light_purple() {
    if [[ $NO_COLOR -eq 1 ]]; then
        printf "%s" "$1"
    else
        printf "\033[1;35m%s\033[0m" "$1"
    fi
}

# Enhanced debug function with color and stderr output
debug() {
    if [[ $DEBUG -eq 1 ]]; then
        printf "%s %s\n" "$(light_purple '**DEBUG**')" "$*" >&2
    fi
}
````

### MCP Context Rules

- When updating MCP context rules, organize tools into logical categories, expand trigger words, and update priority order based on usage frequency. Validate the JSON syntax after making changes. Example:

````json
{
  "mcpRules": {
    "webInteraction": {
      "servers": [
        "fetch",
        "webresearch",
        "context7"
      ],
      "triggers": [
        "web",
        "scrape",
        "browse",
        "website",
        "search",
        "documentation"
      ],
      "description": "Tools for web browsing, searching, and documentation retrieval"
    },
    "knowledgeManagement": {
      "servers": [
        "basic-memory",
        "mcp-obsidian",
        "memory",
        "markdownify"
      ],
      "triggers": [
        "context",
        "memory",
        "knowledge graph",
        "notes",
        "markdown",
        "convert"
      ],
      "description": "Tools for managing knowledge, notes, and content conversion"
    },
    "fileSystemOperations": {
      "servers": [
        "filesystem",
        "apple-script"
      ],
      "triggers": [
        "file",
        "filesystem",
        "applescript",
        "directory"
      ],
      "description": "Tools for interacting with files, directories, and system automation"
    },
    "sourceControl": {
      "servers": [
        "git",
        "github"
      ],
      "triggers": [
        "git",
        "github",
        "repository",
        "code search"
      ],
      "description": "Tools for Git and GitHub operations"
    },
    "aiAssistance": {
      "servers": [
        "sequential-thinking",
        "ollama-mcp"
      ],
      "triggers": [
        "reasoning",
        "llm",
        "model",
        "think"
      ],
      "description": "Tools for AI-powered reasoning and local model execution"
    }
  },
  "defaultBehavior": {
    "priorityOrder": [
      "knowledgeManagement",
      "fileSystemOperations",
      "webInteraction",
      "sourceControl",
      "aiAssistance"
    ],
    "fallbackBehavior": "Ask user which tool would be most appropriate"
  }
}
````

### Shell Script Shebang

- Always include a shebang line (`#!/bin/zsh`) at the beginning of Zsh script files to specify the interpreter. Although technically not required for `.zshrc`, it's a good practice for clarity and editor support.

### VS Code Environment Variables

- When setting environment variables in `settings.json`, use the `${input:variableName}` syntax for sensitive values like tokens. Define corresponding input configurations in `tasks.json` or `launch.json` to prompt for the value securely.

### Global Aliases

- Avoid using global aliases (`alias -g`) unless absolutely necessary. They can cause unexpected behavior due to expansions anywhere on the command line. Prefer regular aliases instead.

### Bat Aliases

-  When creating aliases that use the `bat` command, ensure `bat` is installed and available in the system's PATH. Consider adding a check to ensure `bat` exists before creating the aliases:

````bash
if command -v bat >/dev/null 2>&1; then
    alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
    alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
fi
````

---

*This guidance follows the format and examples in `AGENTS.md`. If any section needs clarification, please provide feedback for further refinement.*