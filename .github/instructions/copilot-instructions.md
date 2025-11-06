---
description: AI rules derived by SpecStory from the project AI interaction history
globs: *
---

# GitHub Copilot Instructions

Last updated: 2025-10-18

## Purpose

Guide Copilot and AI agents to make safe, XDG-compliant, and minimal edits to this personal dotfiles repo. All rules are derived from real project usage and `AGENTS.md`.

Priority guidelines
- Respect the bare-repo dotfiles workflow: use the `dots` wrapper (git --git-dir="$HOME/.dotfiles" --work-tree="$HOME`) when suggesting Git commands or automation. See `AGENTS.md` for exact examples.
- Preserve established structure: configuration files live under `$XDG_CONFIG_HOME` (`.config/`), user scripts under `.local/bin/` and short helpers in `bin/`. Avoid editing transient files in `.local/bin/`, `.cache/`, or other ephemeral locations.
- Minimal, surgical changes only: prefer small PRs that touch the fewest files needed. Don’t refactor large groups of dotfiles in a single change.
- Never commit secrets or private keys. If changes require secrets, add instructions describing which environment variables or secure retrieval tool to use (do not include keys inline).

Patterns and conventions to follow (examples)
- Bare-repo Git: use the `dots` flow: `dots status`, `dots add -n <path>` (dry-run), `dots add <path>`, `dots commit -m "msg"`, `dots push`.
- `.gitignore` uses a deny-all strategy with selective un-ignores. When adding tracked files, update `.gitignore` and always run the `dots add -n` dry-run first.
- Zsh-first scripts: shell files target Zsh (`emulate -L zsh`) and use `setopt` options. Avoid bash-only features unless you detect a file that explicitly uses bash.
- Aliases and expansion: aliases are written to avoid expansion-time interpolation. Follow the alias patterns already present in `AGENTS.md` and `.config/zsh/` (do not change alias semantics globally).
- Tool management: prefer `mise` and `uv` for developer tools (see `AGENTS.md`). Suggest `mise reshim` if generated edits add new tools.

Developer workflows and checks
- Manual validation: after changes, the maintainer expects to run `dots add -n` then `dots add` and `dots commit`. Provide a short verification snippet for any change that affects shell startup files (example: `dots checkout -- <file>` to revert).
- New machine setup steps appear in `AGENTS.md`: cloning the bare repo and running `dots checkout` and `dots config --local status.showUntrackedFiles no`. Avoid suggesting alternate bootstrap flows.
- CI/automation: this repo is documentation/config-heavy — avoid adding heavyweight CI unless clearly documented in `.github/workflows/`.

What to avoid
- Do not modify files in `.local/bin/` that are UV-managed symlinks. These are ephemeral and should not be tracked.
- Don’t introduce project-level package managers or global language version changes (e.g., Homebrew-install Python) unless there is explicit evidence in the repo that this is intended.
- Avoid sweeping automatic changes to many dotfiles or personal settings; prefer a focused PR and a short manual validation checklist.

Where to look for examples and further rules
- `AGENTS.md` — canonical workflow, `dots` function, `mise`/`uv` guidance, and the deny-all `.gitignore` strategy.
- `Vault/02-projects/dotfiles/memory-bank/` — contextual notes and setup guides used by the maintainer.
- `.github/prompts/` — generator/blueprint prompts that describe how to produce repository-level instructions.

If unsure, be conservative: produce a short PR with a single-file or single-purpose change, include exact commands to validate locally (using `dots`), and a short explanation of why the change is safe.

Last updated: 2025-10-18

## PROJECT OVERVIEW

- This repository configures macOS developer environments, targeting Apple Silicon and modern macOS versions.
- Zsh is the default shell (`.zshrc`, `.zprofile`).
- The project uses a bare Git repository for dotfiles, adhering to the XDG Base Directory Specification.
- The repository is located at `$HOME/.dotfiles`, with the working tree set to `$HOME`.
- The project includes a memory bank for persistent shell intelligence, located in `$HOME/Developer/dotfiles/memory-bank`.

## CODE STYLE

- Follow the style of existing scripts:
  - Follow clean code principles.
  - Write comprehensive error handling.
  - Use modern Bash and ZSH conventions.
  - Follow ShellCheck and Google's Shell Style Guide.
  - Use descriptive variable names.
  - Comment code where necessary.
  - Write modular scripts and use functions for repeated logic.
  - Decompose complex operations into focused, single-purpose functions.
  - Validate user input and check command existence before use.

### Comment Conventions

- **File headers**: Use a multi-line block with script purpose and usage examples:

  ```bash
  # =============================================================================
  # Script Name
  # =============================================================================
  # Brief description of the script's purpose
  #
  # Usage:
  #   ./script.sh [options]
  ```

- **Section headers**: Use consistent section dividers with descriptive names:

  ```bash
  # =============================================================================
  # SECTION NAME
  # =============================================================================
  ```

- **Subsection headers**: Use shorter dividers for subsections:

  ```bash
  # Function group description
  # =============================================================================
  ```

- **Function comments**: Document function purpose, parameters, and return values:

  ```bash
  # Function description
  # Usage: function_name "param1" "param2"
  # Arguments: param1 description, param2 description
  # Returns: 0 on success, 1 on failure
  ```

- **Inline comments**: Use sparingly for complex logic or important notes:

  ```bash
  command --flag  # Explain why this flag is needed
  ```

- **Block comments**: For multi-step logic explanations, align with code indentation

## FOLDER ORGANIZATION

~/
├── .dotfiles/                # Bare Git repository (GIT_DIR)
├── .config/                  # XDG-compliant config files
│   └── zsh/                  # Zsh config (ZDOTDIR)
│   └── git/                  # Git config files
│   └── homebrew/             # Homebrew config files
│   └── mise/                  # Mise config files
│   └── vscode/              # VS Code config files
├── .local/
│   ├── share/                # User data (XDG_DATA_HOME)
│   ├── bin/                  # Executables (XDG_BIN_HOME)
│   └── state/                # App state (not tracked)
├── .cache/                   # Cache files (not tracked)
├── Developer/
│   ├── code-portable-data/   # VS Code data
│   ├── repos/                # Cloned repositories
│   └── dotfiles/             # Dotfiles project folder
│      └── memory-bank/       # Memory Bank for Dotfiles project

## TECH STACK

- Shell scripting (Bash, Zsh)
- Git (bare repo strategy)
- GitHub for version control
- Cline Memory Bank for persistent memory
- Mise
- UV

## PROJECT-SPECIFIC STANDARDS

- `dots()` wraps Git commands:  
  `git --git-dir=$HOME/.dotfiles --work-tree=$HOME`
- Cline Memory Bank stores reusable shell logic
- Treat Memory Bank files as documentation, not execution logic
- `.gitignore` should filter:
  - Any secrets or credentials
  - Machine-specific or ephemeral files
  - Cache, Trash, and keyring files
- All configuration files should reside in `$XDG_CONFIG_HOME` (default: `~/.config`) unless app requires it.
- Validate `.gitignore` covers secrets and clutter
- Use specific patterns in `.gitignore` instead of broad catch-all rules to avoid unintended ignores. Example:
    ```ignore
    # Sensitive or machine-specific files
    .env
    *.key
    *.secret
    *_history
    .DS_Store

    # Ignore specific patterns instead of everything
    *.log
    *.cache
    node_modules/
    ```
- When un-ignoring nested directories in `.gitignore`, ensure all levels are explicitly un-ignored:
    ```ignore
    !.config/
    !.config/*
    !.config/*/*
    !.config/*/*/*
    ```
- For `mise`, ensure `idiomatic_version_file_enable_tools` includes all actively used tools to enable automatic version detection via version files (e.g., `.nvmrc`, `.python-version`). Example:
    ```toml
    idiomatic_version_file_enable_tools = [
      "ffmpeg",
      "fzf",
      "node",
      "python",
      "pnpm",
      "pipx",
      "rust",
      "shfmt",
      "shellcheck",
      "usage",
      "uv"
    ]
    ```
  - Do not include npm packages (eslint, prettier, etc.) in this list since they're managed through node/npm version files already.
- Configuration files (e.g., `.gitconfig`, `.ssh/config`) must use the INI format, where sections start with `[section]` and settings are `key = value`, or the SSH config format where entries typically start with `Host` or a comment (`#`). For SSH config files, ensure there are no stray characters or invalid lines that could cause parsing errors. Ensure SSH config files entries start with `Host` or a comment (`#`), and that there are no stray characters or invalid lines that could cause parsing errors.
- For a modern macOS developer environment using UV and Mise, the best practice is to install Python via Mise (not Homebrew or UV directly). Mise manages Python versions, virtualenvs, and shims, and integrates with UV for fast installs. Mise respects `.python-version` and other version files, making it easy to switch Python versions per project. Homebrew installs Python globally, which can conflict with system tools or other Python managers and is less flexible for per-project versioning. UV is a package manager, not a Python installer, and expects a Python interpreter to already exist.
  - Install Python with Mise, let Mise handle version switching, and let UV manage your virtualenvs and packages. This is the most robust, XDG-compliant, and flexible setup for your workflow.
  - Do NOT install Python via Homebrew unless you have a specific reason. Homebrew Python is fine for system scripts, but not ideal for development environments that need version flexibility.
- When defining aliases, ensure that expansion happens at the time of use, not when defined, by escaping the variable: `alias cp="\${aliases[cp]:-cp} -p"`
- **Best Practice**: Declare and assign variables separately to avoid masking return values.
- **Best Practice**: When encountering issues with VS Code extensions, check the extension's documentation for specific build instructions (often `npm install` and `npm run build`).
- **Best Practice Note**: This pattern is secure because it:
  - Checks for file existence before attempting to load it
  - Uses XDG spec for configuration location
  - Fails silently if the secrets file isn't present
- When editing `.git/config` files:
  - Remove any TOML-style comments at the top of the file (e.g., `// filepath: ...`). These are not valid in a Git config file.
  - Use tabs consistently for indentation.
  - Ensure all sections and keys are properly aligned.
- When launching VS Code with a workspace file, pass `GIT_WORK_TREE` and `GIT_DIR` inline to ensure VS Code and its Git integration use the correct environment for the bare repo. This prevents global Git settings from being affected. Example: `GIT_WORK_TREE="$HOME" GIT_DIR="$HOME/.dotfiles" code "$HOME/.config/vscode/dotfiles.code-workspace"`
- When configuring tools, prefer using environment variables for API keys and secrets instead of hardcoding them directly in configuration files.
  - Store secrets in encrypted environment variables (e.g., using SOPS and age) and reference them in your configurations.
  - For dynamic secrets, use a tool like `pw` (password/secret retrieval tool) to fetch secrets from your keychain or other secure storage.
- When using environment variables, ensure they are properly set in your shell environment or VS Code's terminal settings.
- When modifying configurations, ensure that the changes maintain the functionality while improving security and integration with your existing secret management structure.
- When defining JSON configurations for interacting with backend services, ensure the structure includes `inputs` (specifying input parameters) and `servers` (listing backend services with their configurations).
  - The `inputs` array should define input parameters, including their `id`, `type` (e.g., `promptString`), `description`, and whether they are treated as passwords.
  - The `servers` object should list backend services, each with its own configuration, including the command to launch the service, arguments, environment variables, and type of communication (e.g., `stdio`, `http`).

## WORKFLOW & RELEASE RULES

- For dotfiles maintenance utilities closely tied to the Git dotfiles workflow, refactor scripts into Zsh functions within `~/.config/zsh/functions` instead of storing them as standalone executables in `~/.local/bin`.
- Ensure `.zshrc` is configured to autoload functions from `$ZDOTDIR/functions`.
- When facing extension activation errors in VS Code, first try reinstalling the extension. If the issue persists, examine the extension's `package.json` file for any misconfigurations, particularly in the `main` field, and correct them accordingly.
- To generate or update `.github/copilot-instructions.md` for guiding AI coding agents:
  - Focus on discovering essential knowledge for AI agents to be productive, including:
    - The "big picture" architecture that requires reading multiple files to understand - major components, service boundaries, data flows, and the "why" behind structural decisions
    - Critical developer workflows (builds, tests, debugging) especially commands that aren't obvious from file inspection alone
    - Project-specific conventions and patterns that differ from common practices
    - Integration points, external dependencies, and cross-component communication patterns
  - Source existing AI conventions from `**/{.github/copilot-instructions.md,AGENT.md,AGENTS.md,CLAUDE.md,.cursorrules,.windsurfrules,.clinerules,.cursor/rules/**,.windsurf/rules/**,.clinerules/**,README.md}` (do one glob search).
  - If `.github/copilot-instructions.md` exists, merge intelligently - preserve valuable content while updating outdated sections
  - Write concise, actionable instructions (~20-50 lines) using markdown structure
  - Include specific examples from the codebase when describing patterns
  - Avoid generic advice ("write tests", "handle errors") - focus on THIS project's specific approaches
  - Document only discoverable patterns, not aspirational practices
  - Reference key files/directories that exemplify important patterns
  - Update `.github/copilot-instructions.md` and ask for feedback on any unclear or incomplete sections to iterate.

## REFERENCE EXAMPLES

## PROJECT DOCUMENTATION & CONTEXT SYSTEM
- Use the memory bank for persistent context and documentation.
- The memory bank is located at `../Developer/dotfiles/memory-bank`.

## AI AGENT GUIDANCE

- The `.github/copilot-instructions.md` file provides specific guidance for AI coding agents working on this project. It is essential to consult this file before making any changes to the codebase.

---
description: Concise Copilot rules for the dotfiles repo (derived from AGENTS.md)
globs: *
---

# GitHub Copilot Instructions

Last updated: 2025-10-18

## Purpose

Guide Copilot and AI agents to make safe, XDG-compliant, and minimal edits to this personal dotfiles repo. All rules are derived from real project usage and `AGENTS.md`.

## Core Principles
- **Bare-repo workflow:** Use the `dots` wrapper (`git --git-dir=$HOME/.dotfiles --work-tree=$HOME`) for all Git operations. See `AGENTS.md` for canonical usage.
- **Minimal, surgical changes:** Prefer small PRs and avoid sweeping refactors. Never touch more files than needed.
- **Never commit secrets or private keys.** If a secret is needed, instruct the user to use env vars or a secret manager.
- **Respect the deny-all `.gitignore` strategy:** When adding tracked files, update `.gitignore` and always run `dots add -n` first.
- **Do not modify UV-managed symlinks in `~/.local/bin/`.** These are ephemeral and not tracked.
- **Preserve structure:** Configs live in `$XDG_CONFIG_HOME` (`.config/`), user scripts in `.local/bin/`, helpers in `bin/`.
- **Shell scripts:** Target Zsh (`emulate -L zsh`), use `setopt`, and follow patterns in `AGENTS.md` and `.config/zsh/`.
- **Aliases:** Follow alias patterns in `AGENTS.md` and `.config/zsh/`. Do not change global alias semantics.
- **Tool management:** Prefer `mise` and `uv` for developer tools. Suggest `mise reshim` if new tools are added.

## Developer Workflows
- **Git:** Use `dots status`, `dots add -n <path>`, `dots add <path>`, `dots commit -m "msg"`, `dots push`.
- **Validation:** After changes, run `dots add -n` (dry run), then `dots add`, then `dots commit`. For shell startup files, provide a revert snippet (e.g., `dots checkout -- <file>`).
- **New machine setup:** See `AGENTS.md` for cloning and setup steps. Do not suggest alternate bootstrap flows.
- **CI/automation:** Avoid adding CI unless clearly documented in `.github/workflows/`.

## Project-Specific Patterns
- **Memory Bank:** Persistent context and documentation live in `~/Developer/dotfiles/memory-bank/`.
- **.gitignore:** Uses a deny-all strategy with explicit un-ignores. When un-ignoring nested directories, ensure all levels are explicitly un-ignored.
- **Aliases:** Use expansion-safe patterns (see `AGENTS.md`).
- **Python:** Install via Mise, not Homebrew. Let Mise manage versions and UV manage virtualenvs.
- **VS Code:** Open `$HOME` via a workspace file for dotfiles. Pass `GIT_WORK_TREE` and `GIT_DIR` inline when launching VS Code for correct Git integration.

## Where to Look for Patterns
- `AGENTS.md` — canonical workflow, `dots` function, `.gitignore` strategy, and shell script patterns.
- `Vault/02-projects/dotfiles/memory-bank/` — setup and operational notes.
- `.github/prompts/` — generator blueprints and exemplars.

## Quick PR Checklist
1. `dots add -n` (dry run) — verify
2. Update `.gitignore` if adding tracked files
3. Include a one-line validation step in PR description (how to verify on a machine)
4. Avoid touching `~/.local/bin/` symlinks or secrets

---
*This guidance intentionally follows the format and examples in `AGENTS.md`. If any section is unclear or incomplete, please provide feedback for further refinement.*
...existing code...
- To add a `NO_COLOR` environment variable check:
    ````bash
    # Debug configuration with smart color support
    DEBUG=${DEBUG:-0}
    NO_COLOR=${NO_COLOR:-0}

    light_purple() {
        if [[ $NO_COLOR -eq 1 ]]; then
            printf "%s" "$1"
        else
            printf "\033[1;35m%s\033[0m" "$1"
        fi
    }

    debug() {
        if [[ $DEBUG -eq 1 ]]; then
            printf "%s %s\n" "$(light_purple '**DEBUG**')" "$*" >&2
        fi
    }
    ````

## VS CODE TESTING

- While `.code-workspace` files are configuration files and not directly unit-testable, their structure and settings can be validated. Here's an example structure to verify the main settings and structure of `dotfiles.code-workspace`. This includes checking folder paths, Git settings, file exclusions, terminal integration, editor defaults, and extension recommendations. This example can be used as a template for manual inspection or adapted for automated testing using tools that can parse and validate JSON files.

````jsonc
{
  // Test: Workspace folders
  "folders": [
    {
      "name": "🏠 dotfiles",
      "path": "/Users/mh"
    }
  ],
  // Test: Settings
  "settings": {
    // Git settings
    "git.enabled": true,
    "git.detectSubmodules": false,
    "git.autoRepositoryDetection": true,
    // File exclusions
    "files.exclude": {
      "**/.Trash": true,
      "**/Library": true,
      "**/Movies": true,
      "**/Music": true,
      "**/Pictures": true,
      "**/Public": true,
      "**/.DS_Store": true
    },
    // Terminal integration
    "terminal.integrated.defaultProfile.osx": "zsh",
    "terminal.integrated.env.osx": {
      "XDG_CONFIG_HOME": "~/.config",
      "XDG_DATA_HOME": "~/.local/share"
    },
    // Editor defaults
    "editor.tabSize": 2,
    "editor.insertSpaces": true,
    "editor.rulers": [
      80
    ],
    "editor.wordWrap": "on",
    // Extension recommendations setting
    "extensions.ignoreRecommendations": false
  },
  // Test: Extension recommendations
  "extensions": {
    "recommendations": [
      "foxundermoon.shell-format",
      "timonwong.shellcheck",
      "ms-vscode.cpptools",
      "streetsidesoftware.code-spell-checker",
      "yzhang.markdown-all-in-one",
      "bierner.markdown-preview-github-styles"
    ]
  }
}
````

## SHELL USAGE

- To create a virtual environment