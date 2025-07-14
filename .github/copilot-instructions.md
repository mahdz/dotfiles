---
description: AI rules derived by SpecStory from the project AI interaction history
globs: *
---

---
description: AI rules derived by SpecStory from the project AI interaction history
applyTo: "**"
---

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
│   └── mise/                 # Mise config files
│   └── vscode/               # VS Code config files
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

## WORKFLOW & RELEASE RULES

- For dotfiles maintenance utilities closely tied to the Git dotfiles workflow, refactor scripts into Zsh functions within `~/.config/zsh/functions` instead of storing them as standalone executables in `~/.local/bin`.
- Ensure `.zshrc` is configured to autoload functions from `$ZDOTDIR/functions`.
- When facing extension activation errors in VS Code, first try reinstalling the extension. If the issue persists, examine the extension's `package.json` file for any misconfigurations, particularly in the `main` field, and correct them accordingly.

## REFERENCE EXAMPLES

## PROJECT DOCUMENTATION & CONTEXT SYSTEM
- Use the memory bank for persistent context and documentation.
- The memory bank is located at `../Developer/dotfiles/memory-bank`.
- The memory bank contains:
  - `projectbrief.md`: Overview and purpose of the project.
  - `productContext.md`: Context about the product and its goals.
  - `activeContext.md`: Current work focus, recent changes, and next steps.
  - `systemPatterns.md`: System architecture and key technical decisions.
  - `techContext.md`: Technologies used, development setup, and technical constraints.
  - `../Developer/dotfiles/memory-bank.md`: Guidelines for using the memory bank effectively.
- To persist important context from VS Code chats, copy summaries, solutions, or code from the chat into your Memory Bank (`~/Developer/dotfiles/memory-bank`). This makes it accessible from any folder.
- VS Code chat history is workspace-specific and does not sync across folders.

## DEBUGGING

- To check if a file is tracked and identify ignore patterns, use the following `dotfiles` commands:
  ```bash
  # Check git status for this file
  dotfiles status -- <path_to_file>

  # List ignore patterns affecting this path
  dotfiles check-ignore -v <path_to_file>

  # See if the file is tracked
  dotfiles ls-files --error-unmatch <path_to_file>
  ```
  - The `dotfiles` command is an alias for: `git --git-dir=$HOME/.dotfiles --work-tree=$HOME`
- When encountering issues with Mise and Python plugin installations (e.g., missing `origin` remote), follow these steps:
  1. **Remove the broken pyenv directory:**
     ```bash
     rm -rf ~/.cache/mise/python/pyenv
     ```
  2. **Retry your uninstall or install command:**
     ```bash
     mise uninstall python -v
     # or, if you want to reinstall:
     mise install python
     ```
  3. **Update Mise itself or check for plugin updates:**
     ```bash
     mise self-update
     mise plugins update
     ```
- To fix file permission errors in VS Code (e.g., `EACCES: permission denied, unlink`), use the following commands in the terminal:
  ```bash
  sudo chown -R $USER:staff /Applications/code-portable-data
  sudo chmod -R 755 /Applications/code-portable-data
  ```
  For specific directories, use:
  ```bash
  sudo chmod 755 "/Applications/code-portable-data/user-data/CachedExtensionVSIXs/.trash"
  sudo chmod 755 "/Applications/code-portable-data/user-data/logs"
  ```
- When VS Code’s settings sync is failing with `LocalInvalidContent (UserDataSyncError)` because there are syntax errors in your `settings.json` file. The error message means the file is not valid JSON. To fix it:
  - Always check for missing or extra commas between properties in JSON.
  - VS Code’s settings.json must be valid JSON (not JSONC, so comments are not allowed in the actual file).
  - You can use the "Format Document" command in VS Code to help spot syntax errors.
  - Check for trailing commas at the end of the last property in an object (not allowed in JSON).
  - Remove comments (remove them).
  - Check for any other missing or extra brackets/braces.
- When encountering issues with the Prettier extension, and error messages like "Cannot find module 'prettier'", make sure Prettier is installed in your project or set the `prettier.prettierPath` setting to the correct location.
- When VS Code reports extension update errors like `Cannot activate because ./dist/extension not found`:
  1. Check the extension's documentation for build instructions (often `npm install` and `npm run build`).
  2. Make sure you have run the build command in the extension's root directory.
  3. Verify that the `./dist/extension` file (or folder) exists after building.
  4. Ensure that the `main` field in the extension's `package.json` correctly points to the main Javascript file of the extension (e.g., `"main": "./dist/extension.js"`).

## FINAL DOs AND DON'Ts
- **DO**: Use the provided memory bank for context and documentation.
- **DO**: Write clear, maintainable code with proper error handling.
- **DO**: Use descriptive comments and function headers.
- **DON'T**: Modify or read sensitive files like `.env` or `secrets.*`.
- **DON'T**: Introduce unnecessary complexity; keep scripts modular and focused.
- **DON'T**: Introduce security vulnerabilities; follow best practices for handling sensitive data.

## VS CODE CONFIGURATION

- Use a simplified VS Code workspace structure with a single root folder pointing to `$HOME`.
- Configure `files.watcherExclude`, `files.exclude`, and `search.exclude` in `.code-workspace` to exclude large system directories (e.g., `Library`, `Downloads`, `Pictures`, `Movies`, `Music`) for better performance.
- When encountering "Unknown Configuration Setting" or warnings related to experimental/preview settings in VS Code's `settings.json`, follow these steps:
    1. **Identify Problematic Settings**: Review the `settings.json` file and identify the settings flagged as "Unknown Configuration Setting" or related to experimental/preview features.
    2. **Check VS Code Documentation**: Consult the official VS Code documentation or release notes to determine if these settings have been deprecated, renamed, or moved.
    3. **Update or Remove Settings**:
        *   If a setting has been renamed, update the `settings.json` file with the new name.
        *   If a setting is deprecated and no longer needed, remove it from the `settings.json` file.
        *   For experimental/preview settings, consider the stability implications. If you rely on the functionality, keep the setting but be aware it might change. If you don't need it, remove it.
    4. **Review and Test**: After making changes, review the `settings.json` file to ensure the changes are correct. Restart VS Code to apply the changes and test if any functionality is affected.
- When editing `settings.json` in VS Code:
  - Ensure it is valid JSON and not JSONC (i.e., comments are not allowed).
  - Always check for missing or extra commas between properties. Trailing commas at the end of the last property in an object are not allowed.
- The recommended way to work with a bare repo for dotfiles is to **open your `$HOME` directory in VS Code using a workspace file** that is configured for your dotfiles setup. This allows you to:
  - Exclude noisy system folders from the sidebar.
  - Set editor and extension preferences specific to dotfiles.
  - Ensure VS Code and its Git integration use the correct `GIT_DIR` and `GIT_WORK_TREE` for the bare repo.
- Using a workspace file gives you more control and a cleaner, more focused experience for dotfiles management, with benefits such as custom folder exclusions, per-project settings, and extension recommendations, that are not available when opening `$HOME` directly.
- Example `dotfiles.code-workspace` configuration:
````jsonc
{
  "folders": [
    {
      "name": "HOME",
      "path": "../.."
    }
  ],
  "settings": {
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
    "files.exclude": {
      "Library": true,
      "Downloads": true,
      "Pictures": true,
      "Movies": true,
      "Music": true,
      "**/.dotfiles": true,
      "**/.DS_Store": true,
      "**/node_modules": true,
      "**/.git": true
    },
    "search.exclude": {
      "Library": true,
      "Downloads": true,
      "Pictures": true,
      "Movies": true,
      "Music": true
    },
    "git.ignoredRepositories": [
      "/Users/mh/.dotfiles"
    ]
  },
  "extensions": {
    "recommendations": [
      "eamodio.gitlens",
      "editorconfig.editorconfig",
      "dbaeumer.vscode-eslint",
      "esbenp.prettier-vscode"
    ]
  }
}
````

- When encountering issues related to invalid values or syntax errors in VS Code's `settings.json`, especially with formatters or exclude settings:
    1. **Validate Formatter Settings**: Ensure that the `editor.defaultFormatter` setting, if present at the root level, has a valid value. If the formatter is only intended for a specific language, define it within the language-specific configuration block (e.g., `[markdown]`).
    2. **Correct JSON Syntax**: Review the `settings.json` file for any syntax errors, such as missing or extra commas, invalid property keys (ensure they are double-quoted), or trailing commas at the end of the file.
    3. **Review Exclude Settings**: Check the `search.exclude` and `files.exclude` settings for any invalid entries or syntax errors. Ensure that each key-value pair is correctly formatted and that there are no stray characters.
- The **"Prettier: Prettier Path"** setting in VS Code is a user or workspace setting that tells the Prettier extension where to find the `prettier` module. If you use Mise to manage Prettier globally, you usually don’t need to set this path unless you want to force VS Code to use a project-local version. If you see errors about "Cannot find module 'prettier'", make sure Prettier is installed in your project or set this path to the correct location.
  - To set it:
    - **User-wide:** `~/.config/Code/User/settings.json` (or via the VS Code UI: Preferences → Settings)
    - **Workspace:** `settings.json` in your project folder
  - Example:
    ```json
    {
      "prettier.prettierPath": "./node_modules/prettier"
    }
    ```
  - If you use Mise to manage Prettier globally, you usually don’t need to enable the `prettier.resolveGlobalModules` setting in VS Code. In fact, enabling it can sometimes cause confusion or conflicts, because Mise installs global npm packages in its own isolated environment, not in the system or Homebrew global npm space.

## SHELL SCRIPTING BEST PRACTICES

- To prevent alias interference in shell scripts:
  - Use the `command` builtin to bypass aliases:
    ```zsh
    # Instead of: grep pattern file
    command grep pattern file
    ```
  - In `.zshrc`, set up safe aliases that won't interfere with scripts:
    ```zsh
    # Safe aliases that preserve original command behavior
    alias grep='nocorrect command grep'
    alias ls='command ls'
    alias git='command git'
    ```
- When writing shell scripts or functions:
  - Use `emulate -L zsh` to ensure consistent behavior.
  - Use `setopt LOCAL_OPTIONS` to limit option changes to the current scope.
  - Use `setopt PIPE_FAIL` to exit on pipe failures.
  - Use `setopt ERR_EXIT` to exit on errors.
- VS Code chat history is workspace-specific and does not sync across folders. To persist important context, copy summaries, solutions, or code from the chat into your Memory Bank (`~/Developer/dotfiles/memory-bank`). This makes it accessible from any folder.

## MCP CONTEXT RULES

- MCP context rules (e.g., `10-mcp-context.json`) can be structured to categorize available tools and define their priority. Example:
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
- Include relevant servers and an expanded set of trigger words for each category to improve tool activation.

## SHELL DEBUGGING

- To enable shell script debugging:
    ```bash
    # Debugging Configuration (Add near the top of the script)
    DEBUG=${DEBUG:-0}  # Default to off, can be enabled by setting DEBUG=1
    # Debug logging function
    debug() {
      [[ $DEBUG -eq 1 ]] && echo "[DEBUG] $*" >&2
    }
    ```
- To enable colorized debug output:
    ````bash
    # Debug configuration with color support
    DEBUG=${DEBUG:-0}  # Default to off, enable with DEBUG=1

    # ANSI color function for purple debug messages
    light_purple() {
        printf "\033[1;35m%s\033[0m" "$1"
    }

    # Enhanced debug function with color and stderr output
    debug() {
        if [[ $DEBUG -eq 1 ]]; then
            printf "%s %s\n" "$(light_purple '**DEBUG**')" "$*" >&2
        fi
    }
    ````
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

- To create a virtual environment with uv:
  ```zsh
  uv venv
  uv pip install pyyaml
  ```
- You can run `uv venv` in any directory where you want to create a virtual environment.
- **Best practice:** For project-specific dependencies, create a dedicated project folder, `cd` into it, and run `uv venv`.