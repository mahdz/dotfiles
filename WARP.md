# WARP.md - Essential Dotfiles Commands

*Quick reference for managing personal dotfiles with bare git repo*

## Core Commands

**Main function:**

```zsh
dots() { git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"; }
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

**Tool management:**

```zsh
brew install tool                   # Try Homebrew first
mise install tool@latest            # Dev tools via mise
uv tool install python-tool        # Python tools via uv
mise reshim                         # Fix broken tool links
```

## Key Locations

**Directories:**

- `$HOME/.dotfiles` (git repo data)
- `$HOME/.cache` (cache)
- `$HOME/.config/` (your configs)
- `$HOME/.local/bin/` (your scripts)
- `$HOME/.config/raycast/extensions/` (Raycast extensions)

**Files:**

- `$HOME/.gitignore` (deny-all strategy)
- `$HOME/.config/zsh/` (ZDOTDIR - zsh configs)
- This file: Essential commands reference

## Safety Rules

**ALWAYS test first:**

- `dots add -n filename` before `dots add filename`
- New gitignore patterns can break existing ones

**NEVER track:**

- UV symlinks in `$HOME/.local/bin/` (change frequently)
- Cache files, logs, or temporary files
- Secrets or sensitive data

## Gitignore Strategy

**Deny-all approach:**

```gitignore
# Block everything
*

# Allow specific files
!.gitignore
!.config/git/
!.config/git/**
!WARP.md
```

**Adding new files:**

1. Edit the file, make sure it works
2. Add pattern to `.gitignore`
3. Test: `dots add -n path/to/file`
4. If dry-run works: `dots add path/to/file .gitignore`
5. Commit and push

## New Machine Setup

```bash
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

- Run `mise reshim`
- Check `echo $PATH`

**File not tracking despite gitignore:**

- Check pattern order (later rules override earlier ones)
- Test with `dots add -n filename`

**Something broke:**

- `dots status` - what changed?
- `dots diff` - see the changes
- `dots checkout HEAD -- filename` - revert a file

## Documentation

For setup guides and maintenance info:

**Obsidian:** `$VAULT_PATH/02-projects/dotfiles/`

**Key notes:**

- [[Dotfiles Setup Guide]] - How the system works
- [[Simple Dotfiles Maintenance]] - When to update things
- [[Simple Dotfiles Version Tracking]] - Basic git workflow
