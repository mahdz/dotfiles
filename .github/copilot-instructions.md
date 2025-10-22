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

- **Git operations:**
  - `dots status` - check changes
  - `dots add -n <path>` - dry run first
  - `dots add <path>` - stage changes
  - `dots commit -m "msg"` - commit
  - `dots push` - sync to GitHub

- **Validation steps:**
  1. Run `dots add -n` (dry run)
  2. Run `dots add` if dry run passes
  3. Run `dots commit`
  4. For shell files, provide revert command (e.g., `dots checkout -- <file>`)

- **New machine setup:** See `AGENTS.md` for canonical steps. Do not suggest alternate bootstrap flows.

- **CI/automation:** Avoid adding CI unless clearly documented in `.github/workflows/`.

## Project-Specific Patterns

- **Memory Bank:** Documentation lives in `~/Developer/dotfiles/memory-bank/`
- **`.gitignore`:** Uses deny-all with explicit un-ignores. Include all directory levels when un-ignoring nested paths.
- **Aliases:** Use expansion-safe patterns (see `AGENTS.md` for examples)
- **Python:** Install via Mise, not Homebrew. Use UV for package management.
- **VS Code:** Use workspace file, pass Git env vars for correct bare repo integration

## Where to Look for Patterns

- **`AGENTS.md`** - Canonical workflow examples and patterns
- **`Vault/02-projects/dotfiles/memory-bank/`** - Setup and operational guides
- **`.github/prompts/`** - Generator blueprints and exemplars

## Quick PR Checklist

1. `dots add -n` (dry run) - verify changes
2. Update `.gitignore` if adding tracked files
3. Include validation steps in PR description
4. Never touch `~/.local/bin/` symlinks or secrets

---

*This guidance follows the format and examples in `AGENTS.md`. If any section needs clarification, please provide feedback for further refinement.*
