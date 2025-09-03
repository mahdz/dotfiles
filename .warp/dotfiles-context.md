# Dotfiles Management Rule for Warp Drive

**MANUAL SETUP REQUIRED**: Copy the content below and add it as a rule in Warp Drive (brain icon in Warp).

## Overview
I use a bare git repository setup for managing my dotfiles. When I'm in `/Users/mh`, `/Users/mh/.config`, or `/Users/mh/.local`, suggest `dot` commands instead of regular `git` commands.

## Key Commands

**Primary dotfiles command:**
- `dot` (alias for `dotgit` function) - Use instead of `git` for dotfiles operations

**Shortcut aliases:**
- `ds` → `dot status` - Check dotfiles status
- `da` → `dot add` - Stage dotfiles changes
- `dan` → `dot add -n` - Dry-run add (ALWAYS suggest this first!)
- `dc` → `dot commit` - Commit dotfiles changes
- `dp` → `dot push` - Push dotfiles to remote
- `dl` → `dot pull` - Pull dotfiles updates
- `dd` → `dot diff` - Show dotfiles diff

## Directory Context

**Use `dot` commands when in these directories:**
- `$HOME` (main dotfiles work tree)
- `$HOME/.config/*` (configuration files)
- `$HOME/.local/*` (local data/bin)
- `$HOME/.dotfiles/*` (bare repository)

**Use regular `git` commands in:**
- All other directories with `.git` folders
- Project repositories outside of home directory

## Essential Workflow Patterns

**Safe dotfiles workflow:**
1. `ds` - Check what changed
2. `dan filename` - Dry-run add (critical safety step!)
3. `da filename` - Stage after dry-run passes
4. `dc -m "message"` - Commit changes
5. `dp` - Push to GitHub

**Never suggest:**
- `git` commands when in dotfiles directories
- Staging files without dry-run testing first
- Adding cache files, logs, or UV symlinks

## Implementation Details

- Repository: `$HOME/.dotfiles` (bare git repo)
- Work tree: `$HOME`
- Uses deny-all gitignore strategy (`*` then `!patterns`)
- Environment variables: `WARP_GIT_CONTEXT=dotfiles` when in dotfiles directories
