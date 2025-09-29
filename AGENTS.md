# AGENTS.md - Project Overview and Management

This directory (`/Users/mh/`) serves as the user's personal home directory, meticulously managed as a dotfiles repository using a bare Git setup. It centralizes configurations, personal scripts, and development environment settings, ensuring consistency and easy synchronization across different machines.

## Directory Overview

This directory is the root of the user's personal environment. It contains:

* **Dotfiles:** Critical configuration files (e.g., `.zshenv`, `.editorconfig`) and directories (`.config/`, `.dotfiles/`) that define the user's shell, editor, and application behaviors.
* **Personal Scripts:** The `bin/` directory houses custom scripts for various tasks.
* **Documentation:** This `AGENTS.md` provides essential commands and guidelines for managing this dotfiles setup.
* **Application Configurations:** The `.config/` directory contains configurations for numerous applications, including `git`, `zsh`, `raycast`, `mise`, `uv`, and more.

## Key Files and Directories

* **`.zshenv`**: Sets up the Zsh environment, including `ZDOTDIR` to an XDG-compliant location (`$HOME/.config/zsh`).
* **`.editorconfig`**: Defines universal coding style and formatting rules (e.g., `indent_style`, `indent_size`, `max_line_length`) for various file types, ensuring consistent code style across projects.
* **`AGENTS.md`**: This document is a comprehensive guide to managing the dotfiles, including Git commands, safety rules, and key locations.
* **`.config/`**: Contains the bulk of application-specific configurations, organized according to the XDG Base Directory Specification.
* **`.dotfiles/`**: The bare Git repository that tracks all managed dotfiles.
* **`bin/`**: A collection of personal executable scripts.
* **`$HOME/.dotfiles`**: (git repo data)
* **`$HOME/.cache`**: (cache)
* **`$HOME/.local/bin/`**: (your scripts)
* **`$HOME/.config/raycast/extensions/`**: (Raycast extensions)
* **`$HOME/.gitignore`**: (deny-all strategy)
* **`$HOME/.config/zsh/`**: (ZDOTDIR - zsh configs)

## Usage and Management

This directory is managed as a bare Git repository, allowing for version control and synchronization of dotfiles. The primary interaction is through a custom `dots` function (aliased to `git --git-dir="${DOTFILES:-$HOME/.dotfiles}" --work-tree="$HOME"`), as detailed below.

### Core Commands

**Main function:**

```zsh
# Located at: ~/.config/zsh/functions/dots
command git --git-dir="${DOTFILES:-$HOME/.dotfiles}" --work-tree="$HOME" "$@"
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

```zsh
brew install tool                   # Try Homebrew first
mise install tool@latest            # Dev tools via mise
uv tool install python-tool        # Python tools via uv
mise reshim                         # Fix broken tool links
```

## Safety Rules

**ALWAYS test first:**

* `dots add -n filename` before `dots add filename`
* New gitignore patterns can break existing ones

**NEVER track:**

* UV symlinks in `$HOME/.local/bin/` (change frequently)
* Cache files, logs, or temporary files
* Secrets or sensitive data

## Gitignore Strategy

**Deny-all approach:**

```gitignore
# Ignore everything by default
*

# Add back items as needed
!.config/
!.config/*
!.editorconfig
!.gitignore
!.github/
!.github/**
!.config/git/
!.config/git/*
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

## Documentation

For setup guides and maintenance info:

**Obsidian:** `${VAULT_PATH:-$HOME/Vault}/02-projects/dotfiles/`

**Key notes:**

* [Dotfiles Setup Guide](Vault/02-projects/dotfiles/memory-bank/dotfiles-setup-guide.md) - How the system works
* [Simple Dotfiles Maintenance](Vault/02-projects/dotfiles/memory-bank/simple-dotfiles-maintenance.md) - When to update things
* [Simple Dotfiles Version Tracking](Vault/02-projects/dotfiles/memory-bank/dotfiles-documentation-version-tracking-system.md) - Basic git workflow
* [Task Management System README](02-projects/tasks/docs/readme) - Task integration
