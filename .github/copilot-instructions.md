---
description: AI rules derived by SpecStory from the project AI interaction history
globs: *
---

# GitHub Copilot Instructions

Last updated: 2025-10-18

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
- **Respect deny-all `.gitignore` strategy:** Always update `.gitignore` when adding tracked files, then test with `dots add -n`.
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

---

*This guidance follows the format and examples in `AGENTS.md`. If any section needs clarification, please provide feedback for further refinement.*
