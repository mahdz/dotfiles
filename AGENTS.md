# AGENTS.md - Project Overview

This project manages personal dotfiles using a bare Git repository, allowing for version control and synchronization across different machines. It provides a structured way to manage configurations for various tools and applications, ensuring a consistent development environment.

## Project Type

This is a **configuration management project** (treated as a code project for documentation purposes), focused on maintaining a consistent personal computing environment through version-controlled dotfiles.

## Key Technologies and Tools

*   **Git:** For version control of dotfiles.
*   **Zsh:** The primary shell, with configurations managed in `~/.config/zsh/`.
*   **Homebrew:** For macOS package management.
*   **mise:** For managing development tools and their versions.
*   **uv:** For managing Python tools.

## Managing Dotfiles

The core of this project revolves around the `dots` function, which is a wrapper around `git` for managing the bare dotfiles repository.

### Core Commands

The `dots` function is defined as:
```zsh
# Located at: ~/.config/zsh/custom/plugins/dotfiles/dotfiles.zsh
command git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
```

**Daily Workflow:**

*   `dots status`: Check for changes in tracked dotfiles.
*   `dots add -n <filename>`: **DRY RUN FIRST** - preview what `add` would do.
*   `dots add <filename>`: Stage changes after a successful dry run.
*   `dots commit -m "simple message"`: Commit staged changes.
*   `dots push`: Synchronize local commits to the GitHub remote.
*   `dots pull`: Fetch and integrate changes from the remote repository.
*   `dots diff`: View changes in tracked files.

### Tool Management

*   `brew install <tool>`: Install macOS applications and utilities via Homebrew.
*   `mise install <tool>@latest`: Install development tools using `mise`.
*   `uv tool install <python-tool>`: Install Python-specific tools using `uv`.
*   `mise reshim`: Fix broken tool links after installation or updates.

## Key Locations

### Directories

*   `$HOME/.dotfiles`: The bare Git repository data.
*   `$HOME/.cache`: Cache files.
*   `$HOME/.config/`: Primary location for configuration files.
*   `$HOME/.local/bin/`: Location for personal scripts and executables.

### Files

*   `$HOME/.gitignore`: Global `.gitignore` for the dotfiles repository.
*   `$HOME/.config/zsh/`: Zsh configuration directory.
*   `AGENTS.md`: Essential commands reference (this file).

## Dotfiles Management Conventions

### Safety Rules

*   **ALWAYS test first:** Use `dots add -n <filename>` before `dots add <filename>`.
*   **NEVER track:**
    *   Cache files, logs, or temporary files.
    *   Secrets or sensitive data.

### Gitignore Strategy

The project employs a "deny-all" `.gitignore` strategy, ignoring everything by default and explicitly adding back desired files/directories.

Example:
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
!AGENTS.md
```

**Adding New Files:**

1.  Edit the file and ensure it works as expected.
2.  Add the appropriate pattern to `.gitignore`.
3.  Test with `dots add -n path/to/file` to verify the pattern.
4.  If the dry-run is successful, stage the file and the `.gitignore` changes: `dots add path/to/file .gitignore`.
5.  Commit and push the changes.

## New Machine Setup

To set up dotfiles on a new machine:

1.  **Clone the bare repository:**
    ```bash
    git clone --bare git@github.com:mahdz/dotfiles.git $HOME/.dotfiles
    ```
2.  **Set up the `dots` function:**
    ```bash
    dots() { git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"; }
    ```
3.  **Backup conflicting files:**
    ```bash
    mkdir -p ~/.dotfiles-backup
    # (handle any conflicting files by moving them to ~/.dotfiles-backup)
    ```
4.  **Apply dotfiles:**
    ```bash
    dots checkout
    dots config --local status.showUntrackedFiles no
    ```

## Troubleshooting

*   **Tool not found after install:**
    *   Run `mise reshim`.
    *   Check `echo $PATH`.
*   **File not tracking despite gitignore:**
    *   Review pattern order in `.gitignore` (later rules override earlier ones).
    *   Test with `dots add -n filename`.
*   **Something broke:**
    *   `dots status`: Identify recent changes.
    *   `dots diff`: Review the specific changes.
    *   `dots checkout HEAD -- filename`: Revert a specific file to its last committed state.
