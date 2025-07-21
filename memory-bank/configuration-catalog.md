+++
id = "dotfiles-configuration-catalog"
title = "Configuration Catalog: Managed Tools and Settings"
type = "catalog"
status = "complete"
created_date = "2025-01-28"
last_updated = "2025-01-28"
tags = ["catalog", "tools", "configuration", "xdg"]
+++

# Configuration Catalog: Managed Tools and Settings

## Overview

This document provides a comprehensive inventory of all tools, configurations, and settings managed by the dotfiles system. Tools are categorized by function and include their XDG-compliant locations and configuration details.

## Shell Environment

### ZSH Configuration
- **Location**: `~/.config/zsh/`
- **Files**: 
  - `.zshrc` - Main configuration loader
  - `.zshenv` - Environment variables
  - `.zprofile` - Login shell setup
  - `.zstyles` - Completion styles
  - `.zsh_plugins.txt` - Plugin definitions
- **Modules**: `zshrc.d/` with 10 modular configuration files
- **Plugin Manager**: Antidote
- **Features**: Profiling, conditional loading, modular architecture

### Shell Utilities
- **Location**: `~/.config/shell/`
- **Files**: `shellrc` - Shared shell configuration
- **Integration**: Cross-shell compatibility layer

## Development Tools

### Git Version Control
- **Location**: `~/.config/git/`
- **Files**: 
  - `config` - Global Git configuration
  - `ignore` - Global gitignore patterns
- **Special**: Dotfiles managed via bare repository pattern

### VS Code
- **Location**: `~/.config/vscode/`
- **Files**:
  - `dotfiles.code-workspace` - Workspace configuration
  - `profiles/` - User profiles (excluded from tracking)
- **Integration**: Deep configuration management

### Mise (Tool Manager)
- **Location**: `~/.config/mise/`
- **Files**: `config.toml` - Global tool versions and settings
- **Managed Tools**:
  - Node.js (latest)
  - npm tools: eslint, prettier, typescript, etc.
  - SOPS (3.10.2) for secret management
  - age (1.2.1) for encryption
  - Bun (latest)
- **Features**: UV integration, Python venv auto-activation

### Node.js/npm
- **Location**: `~/.config/npm/`
- **Integration**: Via mise tool manager
- **Tools**: Development utilities and linters

## Package Management

### Homebrew
- **Location**: `~/.config/homebrew/`
- **Status**: Brewfile currently deleted (pending restructure)
- **Integration**: Package management for macOS tools

## CLI Utilities

### File and Directory Tools

#### bat (Enhanced cat)
- **Location**: `~/.config/bat/`
- **Files**: `config` - Syntax highlighting and paging
- **Integration**: MANPAGER configuration

#### eza (Enhanced ls)
- **Location**: `~/.config/eza/`
- **Features**: Modern ls replacement with colors and icons

#### ripgrep (Enhanced grep)
- **Location**: `~/.config/ripgrep/`
- **Files**: `config` - Search configuration
- **Environment**: `RIPGREP_CONFIG_PATH` set

### Archive and Download Tools

#### gallery-dl
- **Location**: `~/.config/gallery-dl/`
- **Files**: `config.json` - Media downloading configuration

#### yt-dlp
- **Location**: `~/.config/yt-dlp/`
- **Purpose**: Video downloading configuration

#### wget
- **Location**: `~/.config/wget/`
- **Purpose**: Download utility configuration

### System and Productivity Tools

#### GitHub CLI (gh)
- **Location**: `~/.config/gh/`
- **Files**: 
  - `config.yml` - CLI configuration
  - `hosts.yml` - Authentication hosts

#### glow (Markdown viewer)
- **Location**: `~/.config/glow/`
- **Purpose**: Terminal markdown rendering

#### gomi (Safe rm)
- **Location**: `~/.config/gomi/`
- **Purpose**: Safe file deletion to trash

#### pw (Password manager)
- **Location**: `~/.config/pw/`
- **Files**: `pw.conf` - Password management configuration

#### superfile (File manager)
- **Location**: `~/.config/superfile/`
- **Files**: `*.toml` - Terminal file manager configuration

#### topgrade (System updater)
- **Location**: `~/.config/topgrade/`
- **Purpose**: Automated system and package updates

### macOS-Specific Tools

#### AutoRaise
- **Location**: `~/.config/AutoRaise/`
- **Purpose**: Window focus management

#### Karabiner-Elements
- **Location**: `~/.config/karabiner/`
- **Files**: `*.json` - Keyboard customization
- **Features**: Advanced key mapping and shortcuts

#### keyboardcowboy
- **Location**: `~/.config/keyboardcowboy/`
- **Files**: `*.json` - Keyboard automation
- **Features**: Backup system included

### Additional CLI Tools

#### AdGuard
- **Location**: `~/.config/adguard/`
- **Purpose**: DNS-level ad blocking

#### aria2
- **Location**: `~/.config/aria2/`
- **Purpose**: Multi-protocol download utility

#### broot (Tree navigation)
- **Location**: `~/.config/broot/`
- **Features**: Interactive directory navigation
- **Includes**: Custom skins and launcher

#### fastfetch
- **Location**: `~/.config/fastfetch/`
- **Purpose**: System information display

#### micro (Text editor)
- **Location**: `~/.config/micro/`
- **Features**: Modern terminal text editor
- **Includes**: Backups, buffers, colorschemes, plugins

#### navi (Cheat sheets)
- **Location**: `~/.config/navi/`
- **Purpose**: Interactive command-line cheatsheet

#### rclone (Cloud storage)
- **Location**: `~/.config/rclone/`
- **Purpose**: Cloud storage synchronization

#### readline
- **Location**: `~/.config/readline/`
- **Purpose**: Line editing library configuration

#### repomix
- **Location**: `~/.config/repomix/`
- **Purpose**: Repository packing utility

#### shellcheck
- **Location**: `~/.config/shellcheck/`
- **Purpose**: Shell script linting

#### starship (Prompt)
- **Location**: `~/.config/starship/`
- **Purpose**: Cross-shell prompt customization

#### tldr (Help pages)
- **Location**: `~/.config/tldr/`
- **Purpose**: Simplified man pages
- **Environment**: `TEALDEER_CONFIG_DIR` configured

#### tmux (Terminal multiplexer)
- **Location**: `~/.config/tmux/`
- **Purpose**: Terminal session management

## Local Binaries

### User Scripts
- **Location**: `~/.local/bin/`
- **Management**: Explicit whitelist approach
- **Categories**:
  - **AI Tools**: `ai-*` - AI-related utilities
  - **Automation**: `auto_*` - Automated tasks
  - **Backup**: `backup` - Backup utilities
  - **Homebrew**: `brew-*` - Homebrew helpers
  - **System**: Various system utilities (clean*, compress*, disk-*, etc.)
  - **Git**: `git-*` - Git extensions
  - **Development**: Repository and project management tools

### UV Tool Integration
- **Symlink Management**: Automatic symlink creation to `~/.local/share/uv/tools/`
- **Recovery**: `uv tool sync` recreates all managed symlinks
- **Tracking Strategy**: Exclude dynamic symlinks, track specific tools

## Browser Configuration

### Safari Exports
- **Location**: `~/.config/browser/`
- **Contents**: 
  - Safari Export_Personal_2025-05-10
  - Safari Export_Play_2025-05-10
- **Purpose**: Browser bookmark and settings backups

## System Integration

### macOS Setup
- **Location**: `~/.config/macos/`
- **Structure**:
  - `setup/` - System configuration scripts
  - `ref/` - Reference documentation
- **Purpose**: Automated macOS system configuration

### Setup Scripts
- **Location**: `~/.config/setup/`
- **Contents**:
  - `data/` - Setup data files
  - `macos-setup/` - macOS-specific setup scripts
- **Purpose**: System bootstrapping and configuration

## Configuration Patterns

### XDG Compliance
- **Config**: `~/.config/` for configuration files
- **Data**: `~/.local/share/` for user data
- **Cache**: `~/.cache/` for temporary files (not tracked)
- **Binaries**: `~/.local/bin/` for user executables

### Security Patterns
- **Secrets**: Stored in `~/.local/share/secrets/`
- **Environment**: Loaded via mise from JSON file
- **History**: Disabled for security-sensitive tools
- **GPG/SOPS**: Integrated encryption for sensitive data

### Tool Integration Patterns
- **Environment Variables**: Proper XDG variable usage
- **Configuration Files**: Centralized in tool-specific directories
- **Plugin Systems**: Managed where available (ZSH, VS Code)
- **Version Management**: Centralized via mise

## Summary Statistics

- **Total Tracked Configurations**: 41+ tools
- **XDG-Compliant Directories**: 100% of managed tools
- **Configuration Files**: 100+ individual configuration files
- **User Scripts**: 50+ custom scripts in `.local/bin/`
- **Shell Modules**: 10 modular ZSH configuration files
- **Tool Categories**: 8 major categories (Shell, Development, CLI, System, etc.)

This catalog represents a comprehensive, well-organized system that prioritizes security, maintainability, and modern development workflows while adhering to established directory standards.
