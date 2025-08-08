# WARP.md

This file provides guidance to [WARP](https://warp.dev) when working with code in this repository.

## Repository Configuration

*   **Bare Git repo:** `$HOME/.dotfiles` with `$HOME` as work tree
    *   **Use alias:** `alias dot="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"`
    *   **Untracked noise:** `dot config --local status.showUntrackedFiles no`
    *   **Gitignore strategy:** deny-all with selective whitelisting. Always verify inclusions with dry-runs before committing.

## Commands You'll Use Often

### Inspect and Stage Safely

*   `dot status`
*   `dot diff`
*   `dot add -n path` # dry-run to check what would be staged
*   `dot restore --staged path` # unstage if needed

### Commit and Sync

*   `dot commit -S -s -m "message"` # signed + signoff per Manny’s preference
*   `dot push origin main`
*   `dot pull --ff-only origin main`
*   `dot log --oneline --graph --decorate -n 30`

### Whitelist Under Deny-All

*   Edit `~/.gitignore` and add a negation pattern, e.g., `!.config/zsh/.zshrc`
*   Test inclusion: `dot add -n .config/zsh/.zshrc`

### Handle Checkout Conflicts (New Machine)

```bash
mkdir -p ~/.dotfiles-backup
dot checkout 2>&1 | grep -E "^\s" | awk '{print $1}' | xargs -I{} sh -c 'mkdir -p ~/.dotfiles-backup/$(dirname "{}"); mv "{}" ~/.dotfiles-backup/"{}"'
dot checkout
```

### Branch Hygiene (Main-Focused)

*   `dot fetch --all --prune`
*   `dot branch | grep -v 'main' | xargs -n1 dot branch -D`

## High-Level Architecture and Conventions

### Bare Repo Model

*   **GIT_DIR:** `$HOME/.dotfiles` stores repo metadata
*   **GIT_WORK_TREE:** `$HOME` is the working tree; files live in place (no `.git` in `$HOME`)
*   **Implication:** every path you track is a real file in `$HOME`; prefer XDG locations to avoid scattering

### Deny-All .gitignore

*   Root ignore blocks everything (`*`) and selectively re-includes with `!patterns`
*   Additions must be made thoughtfully—new `!rules` can be shadowed by later rules
*   Always validate with `dot add -n path` to ensure your pattern works

### XDG-Aligned Layout

*   **Zsh:** `ZDOTDIR=$HOME/.config/zsh` (primary zsh configs live here)
*   Other tool configs prefer `$XDG_CONFIG_HOME` (`$HOME/.config`), data to `$XDG_DATA_HOME`, caches to `$XDG_CACHE_HOME`

### Zsh

*   Primary entry points typically include `~/.zshenv` and `$ZDOTDIR/.zshrc`
*   Modularization via `$ZDOTDIR/zshrc.d/*` when present

### Tooling Policy (Per Manny’s Rules)

*   Check `mise` first; install via `brew` first and then via `mise` when available; run `mise reshim` if a tool fails to appear
*   Python via Homebrew; install Python tools with Homebrew’s `uv`
*   `uv` creates symlinks in `~/.local/bin` pointing to `~/.local/share/uv/tools`
    *   Do not track these symlinks; prefer a whitelist approach in `.gitignore` for `~/.local/bin` only when needed and avoid including `uv`-managed links
    *   `uv tool sync` can recreate symlinks if needed

### Notable Locations

*   Raycast extensions: `~/.config/raycast/extensions/`
*   `git-extras`: `/opt/homebrew/Cellar/git-extras/7.4.0`
*   `ollama` installed via Homebrew Cask

### Warp Workflows in This Environment

*   **Pack Dotfile Repo for LLM:** generates a consolidated dotfiles summary at `~/Desktop/dotfiles_settings_summary.txt` (captures git configs, ignore files, ZSH configs)
*   **Clone a GitHub repository and manage dotfiles:** clones as bare, sets alias, performs conflict backup + checkout, configures untracked files visibility
*   Use when bootstrapping a new machine or packaging the environment for analysis

## Working Effectively in This Repo

### Add a New File to Tracking

1.  Edit `~/.gitignore`: add a negation for the file or directory you want to include (e.g., `!.config/app/config.toml`)
2.  `dot add -n the/path` to confirm inclusion
3.  `dot add the/path && dot commit -S -s -m "track app config"`

### Avoid Tracking Generated or Volatile Files

*   `uv`-created symlinks, caches, logs—ensure your `.gitignore` blocks them.

### When Tool Shims Don’t Resolve

*   `mise reshim`, verify `PATH` and shims, then retry.

### Keep $HOME Clean

*   Prefer `$XDG_CONFIG_HOME` and `$XDG_DATA_HOME` so tracked files stay organized and easy to whitelist.

## If This File Is Newly Added

Because of the deny-all gitignore, whitelist it explicitly:

*   Append to `~/.gitignore`: `!WARP.md`
*   Verify with `dot add -n WARP.md`

## Shell Steps to Create and Commit WARP.md (Do Not Run Automatically)

Ensure alias and untracked settings exist.

```bash
alias dot="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
dot config --local status.showUntrackedFiles no
```
