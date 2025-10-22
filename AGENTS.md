# AGENTS.md - Project Overview and Management

*Last updated: 2025-10-22*

This directory (`/Users/mh/`) serves as the user's personal home directory, meticulously managed as a dotfiles repository using a bare Git setup. It centralizes configurations, personal scripts, and development environment settings, ensuring consistency and easy synchronization across different machines.

## Directory Overview

This directory is the root of the user's personal environment. It contains:

* **Dotfiles:** Critical configuration files (e.g., `.zshenv`, `.editorconfig`) and directories (`.config/`, `.dotfiles/`) that define the user's shell, editor, and application behaviors.
* **Personal Scripts:** Both `bin/` directory (4 scripts) and `.local/bin/` directory (54+ tools and scripts) house custom scripts and UV-managed tool symlinks.
* **Documentation:** This `AGENTS.md` provides essential commands and guidelines for managing this dotfiles setup.
* **Application Configurations:** The `.config/` directory contains configurations for numerous applications, including `git`, `zsh`, `raycast`, `mise`, `uv`, and more.

## Key Files and Directories

* **`.zshenv`**: Sets up the Zsh environment, including `ZDOTDIR` to an XDG-compliant location (`$HOME/.config/zsh`).
* **`.editorconfig`**: Defines universal coding style and formatting rules (e.g., `indent_style`, `indent_size`, `max_line_length`) for various file types, ensuring consistent code style across projects.
* **`AGENTS.md`**: This document is a comprehensive guide to managing the dotfiles, including Git commands, safety rules, and key locations.
* **`.config/`**: Contains the bulk of application-specific configurations, organized according to the XDG Base Directory Specification.
* **`.dotfiles/`**: The bare Git repository that tracks all managed dotfiles.
* **`bin/`**: A collection of personal executable scripts with comprehensive inline documentation:
  - **`migrate-tasks`**: Task migration script for unified task management system
  - **`rotate-logs`**: Smart log rotation and archival tool with compression
  - **`task`**: Unified task management CLI with project-specific directory detection
  - **`unquarantine_apps.sh`**: macOS application unquarantine utility
* **`$HOME/.cache`**: Application cache directory.
* **`$HOME/.local/bin/`**: Primary scripts directory (54+ tools including UV-managed Python tools).
* **`$HOME/.config/raycast/extensions/`**: Raycast extensions directory (249+ extensions).
* **`$HOME/.gitignore`**: Comprehensive deny-all strategy (200+ lines with detailed patterns).
* **`$HOME/.config/zsh/`**: ZDOTDIR - ZSH configurations and custom plugins.

## Usage and Management

This directory is managed as a bare Git repository, allowing for version control and synchronization of dotfiles. The primary interaction is through a custom `dots` function (aliased to `git --git-dir="${DOTFILES:-$HOME/.dotfiles}" --work-tree="$HOME"`), as detailed below.

### Core Commands

**Main function:**

```zsh
# Located at: ~/.config/zsh/custom/plugins/dotfiles/dotfiles.plugin.zsh
# Enhanced dots function with usage help, explicit git mode, and implicit command detection
dots() {
    # Shows usage if no arguments provided
    # Supports both 'dots status' and 'dots git status' syntax
    # Includes comprehensive git command recognition
    command git --git-dir="${DOTFILES:-$HOME/.dotfiles}" --work-tree="$HOME" "$@"
}
```

**Daily workflow:**

```zsh
dots status                          # Check what changed
dots add -n path                     # DRY RUN first - critical!
dots add path                        # Stage after dry run passes
dots commit -m "simple message"      # Commit changes
dots push                            # Sync to GitHub
```

**Warp AI shortcuts:**

```zsh
ds                                  # dots status
dan filename                        # dots add -n (dry-run first!)
da filename                         # dots add (after dry-run passes)
dc -m "message"                     # dots commit
dp                                  # dots push
dl                                  # dots pull
dd                                  # dots diff
```

### Tool Management

**Python Environment (Configured: 2025-10-22):**

```zsh
# Python versions: managed by mise with uv backend (2-way sync)
python --version                    # Currently: Python 3.14.0
mise sync python --uv              # Sync Python versions between mise and uv
mise reshim                        # Update shims after changes

# Project dependencies: use uv pip in project venvs
uv pip install -r requirements.txt  # Install in active .venv (auto-created by mise)
uv pip install package             # Add package to project

# Global Python CLI tools: declared in ~/.config/mise/config.toml
# Tools are managed via mise's pipx backend (using uvx internally)
mise install                       # Install all tools from config
mise list | grep pipx              # List installed pipx tools
```

**Current Python CLI Tools (via mise pipx):**
- basic-memory, black, gallery-dl, khard, mac-cleanup, osxmetadata, rich-cli, ruff, speedtest-cli, yt-dlp
- *Pending Python 3.14 compatibility*: aider-chat (tiktoken), markitdown-mcp (onnxruntime)

**Other Tools:**

```zsh
brew install tool                   # Try Homebrew first
mise install tool@latest            # Dev tools via mise
```

### Log Management

```zsh
# Rotate and compress old log files
rotate-logs --dry-run                # Preview log rotation actions
rotate-logs --days 7 --keep 5       # Rotate logs older than 7 days, keep 5 archives
rotate-logs                          # Use default settings (7 days, 5 archives)

# Check archived logs
ls -la ~/.basic-memory/archives/     # View compressed log archives
zcat ~/.basic-memory/archives/name.log.gz | less  # View archived log content
```

## Safety Rules

**ALWAYS test first:**

* `dots add -n filename` before `dots add filename`
* New gitignore patterns can break existing ones

**NEVER track:**

* mise-managed tool installations in `~/.local/share/mise/installs/pipx-*/` (managed by config)
* Cache files, logs, or temporary files
* Secrets or sensitive data

## Gitignore Strategy

**Deny-all approach (200+ lines):**

The `.gitignore` file uses a comprehensive deny-all strategy with detailed patterns for:
- Core configuration files (`.editorconfig`, `.zshenv`, etc.)
- Application-specific configs (VSCode, Raycast, mise, uv, etc.)
- Tool configurations (bat, eza, gh, glow, karabiner, ollama, etc.)
- Complex UV tool symlink handling in `.local/bin/`
- ZSH configurations with selective exclusions
- Script directories with specific inclusions

```gitignore
# Basic structure (simplified - actual file is much more detailed)
*                    # Ignore everything by default
!.config/           # Add back config directory
!.editorconfig      # Essential files
!AGENTS.md          # This documentation
# ... 200+ more specific patterns
```

**Adding new files:**

1. Edit the file, make sure it works
2. Add pattern to `.gitignore`
3. Test: `dots add -n path/to/file`
4. If dry-run works: `dots add path/to/file .gitignore`
5. Commit and push

## New Machine Setup

```zsh
# Clone dotfiles
git clone --bare git@github.com:mahdz/dotfiles.git $HOME/.dotfiles

# Set up function
dots() { git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"; }

# Backup conflicts
mkdir -p ~/.dotfiles-backup
# (handle any conflicting files)

# Apply dotfiles
dots checkout
dots config --local status.showUntrackedFiles no
```

## Troubleshooting

**Tool not found after install:**

* Run `mise reshim`
* Check `echo $PATH`

**File not tracking despite gitignore:**

* Check pattern order (later rules override earlier ones)
* Test with `dots add -n filename`

**Something broke:**

* `dots status` - what changed?
* `dots diff` - see the changes
* `dots checkout HEAD -- filename` - revert a file

## Python Configuration

**Last configured: 2025-10-22** - Mise + uv integration with 2-way sync

### Configuration Details
- **Python versions**: Managed by mise, backed by uv's pre-built binaries
- **Python 3.14.0**: Symlinked from `~/.local/share/uv/python/cpython-3.14.0-macos-aarch64-none`
- **Virtual environments**: Auto-created per-project in `.venv` folders (via `python.uv_venv_auto = true`)
- **Project dependencies**: Installed with `uv pip install` inside project venvs
- **Global CLI tools**: Declared in `~/.config/mise/config.toml` as `"pipx:tool" = "version"`
- **Tool backend**: mise's pipx backend with `uvx = true` (uses `uv tool install` internally)

### Key Configuration Files
- **`~/.config/mise/config.toml`**: Single source of truth for all tools (Python versions, CLI tools)
- **`~/.config/uv/uv.toml`**: UV settings (`python-preference = "system"` for mise compatibility)
- **`~/.config/mise/.default-python-packages`**: Default packages for new Python installs

### Sync and Maintenance
```zsh
mise sync python --uv              # 2-way sync Python versions between mise and uv
mise reshim                        # Update shims after installing new tools
mise install                       # Install all tools from config (idempotent)
```

### Backup
- **Pre-migration backup**: `~/mise-python-3.14.0-backup-20251022.tar.gz` (16MB)
- Contains old core:python@3.14.0 installation before switching to uv backend

## Recent Cleanup and Maintenance

**Last cleanup: 2025-10-07** - Comprehensive technical debt elimination

### Cleanup Results
- **Space saved**: ~16MB+ through systematic cleanup
- **Files removed**: Technical debt including .DS_Store files, empty configs, old backups
- **Tools added**: Smart log rotation system with compression and archival
- **Scripts enhanced**: All bin scripts now include comprehensive inline documentation
- **Configurations optimized**: Removed orphaned configs, validated XDG compliance

### New Tools Available
- **`rotate-logs`**: Automated log management with configurable retention policies
- **Enhanced scripts**: All scripts now self-documenting per user preference

### Maintenance Guidelines
- **Quarterly cleanup**: Run configuration audits to identify orphaned configs
- **Log rotation**: `rotate-logs` available for managing growing log files
- **Documentation**: All scripts contain comprehensive usage information inline

## Documentation

For setup guides and maintenance info:

**Obsidian:** `${VAULT_PATH:-$HOME/Vault}/02-projects/dotfiles/`

**Key notes:**

* [Dotfiles Setup Guide](Vault/02-projects/dotfiles/memory-bank/dotfiles-setup-guide.md) - How the system works
* [Simple Dotfiles Maintenance](Vault/02-projects/dotfiles/memory-bank/simple-dotfiles-maintenance.md) - When to update things
* [Simple Dotfiles Version Tracking](Vault/02-projects/dotfiles/memory-bank/dotfiles-documentation-version-tracking-system.md) - Basic git workflow
* [Task Management System README](02-projects/tasks/docs/readme) - Task integration

**Cleanup Documentation:**

* [Configuration Analysis](Documents/cleanup-config-analysis.md) - Configuration consolidation review
* [Migration Analysis](Documents/migrate-tasks-analysis.md) - Task migration assessment
