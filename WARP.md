# WARP.md - Essential Dotfiles Commands

*Quick reference for managing personal dotfiles with bare git repo*

## Core Commands

**Main alias:**
```bash
alias dot="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
```

**Daily workflow:**
```bash
dot status                          # Check what changed
dot add -n path                     # DRY RUN first - critical!
dot add path                        # Stage after dry run passes
dot commit -m "simple message"      # Commit changes
dot push                            # Sync to GitHub
```

**Warp AI shortcuts:**
```bash
ds                                  # dot status
dan filename                        # dot add -n (dry-run first!)
da filename                         # dot add (after dry-run passes)
dc -m "message"                     # dot commit
dp                                  # dot push
dl                                  # dot pull
dd                                  # dot diff
```

**Tool management:**
```bash
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
- `~/.config/raycast/extensions/` (Raycast extensions)

**Files:**
- `$HOME/.gitignore` (deny-all strategy)
- `$HOME/.config/zsh/` (ZDOTDIR - zsh configs)
- This file: Essential commands reference

## Safety Rules

**ALWAYS test first:**
- `dot add -n filename` before `dot add filename`
- New gitignore patterns can break existing ones

**NEVER track:**
- UV symlinks in `~/.local/bin/` (change frequently)
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
3. Test: `dot add -n path/to/file`
4. If dry-run works: `dot add path/to/file .gitignore`
5. Commit and push

## New Machine Setup

```bash
# Clone dotfiles
git clone --bare git@github.com:mahdz/dotfiles.git $HOME/.dotfiles

# Set up alias
alias dot="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"

# Backup conflicts
mkdir -p ~/.dotfiles-backup
# (handle any conflicting files)

# Apply dotfiles
dot checkout
dot config --local status.showUntrackedFiles no
```

## Troubleshooting

**Tool not found after install:**
- Run `mise reshim`
- Check `echo $PATH`

**File not tracking despite gitignore:**
- Check pattern order (later rules override earlier ones)
- Test with `dot add -n filename`

**Something broke:**
- `dot status` - what changed?
- `dot diff` - see the changes
- `dot checkout HEAD -- filename` - revert a file

## Documentation

For setup guides and maintenance info:

**Obsidian:** `/Users/mh/Library/Mobile Documents/iCloud~md~obsidian/Documents/Vault/02-Projects/Dotfiles/memory-bank/`

**Key notes:**
- [[Dotfiles Setup Guide]] - How the system works
- [[Simple Dotfiles Maintenance]] - When to update things
- [[Simple Dotfiles Version Tracking]] - Basic git workflow
