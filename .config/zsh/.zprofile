# =============================================================================
# ~/.zprofile - Login Shell PATH Configuration for macOS
# =============================================================================
# This file is sourced only for login shells and handles PATH management
# Ensures development tools take priority over system versions

# =============================================================================
# PATH MANAGEMENT UTILITIES
# =============================================================================

# Append directory to PATH if it exists and isn't already present
# Only adds directories that actually exist on the filesystem
# Checks for duplicates using pattern matching to avoid PATH bloat
path_append() {
  if [[ -d "$1" && ":$PATH:" != *":$1:"* ]]; then
    export PATH="$PATH:$1"
  fi
}

# Prepend directory to PATH (highest priority)
# Only adds directories that actually exist on the filesystem
# Checks for duplicates using pattern matching to avoid PATH bloat
path_prepend() {
  if [[ -d "$1" && ":$PATH:" != *":$1:"* ]]; then
    export PATH="$1:$PATH"
  fi
}

# =============================================================================
# PATH INITIALIZATION
# =============================================================================

# Initialize Homebrew (Apple Silicon) - MUST be first for proper tool detection
if [[ -x "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# =============================================================================
# HIGH PRIORITY DEVELOPMENT TOOLS
# =============================================================================
# These tools should override system versions

# User-specific development tools (highest priority)
# Ensure mise shim directory is at the front of PATH
if [[ -d "$HOME/.local/share/mise/shims" ]]; then
  export PATH="$HOME/.local/share/mise/shims:$PATH"
fi

# npm global bin directory
path_prepend "$HOME/.local/share/npm/bin"

# Homebrew packages (high priority)
path_prepend "$(brew --prefix)/bin"
path_prepend "$(brew --prefix)/sbin"

# Force Homebrew Git to be first in PATH (takes precedence over standard Homebrew)
path_prepend "$(brew --prefix)/opt/git/bin"

# User-installed tools (high priority)
path_prepend "/usr/local/bin"

# =============================================================================
# DEVELOPMENT TOOLS AND LANGUAGES
# =============================================================================

# =============================================================================
# OPTIONAL TOOLS
# =============================================================================

# VS Code Scripts
path_append "${XDG_CONFIG_HOME}/vscode"

# GPG Suite
# path_append "/usr/local/MacGPG2/bin"

# id774/scripts.git
path_append "/Users/mh/Developer/repos/id774/scripts"

# =============================================================================
# STANDARD SYSTEM PATHS
# =============================================================================
# Core system paths - these should come before Apple-specific paths

path_append "/usr/bin"
path_append "/bin"
path_append "/usr/sbin"
path_append "/sbin"

# =============================================================================
# APPLE SYSTEM PATHS
# =============================================================================
# These have lowest priority

# Apple system paths (lowest priority)
path_append "/System/Cryptexes/App/usr/bin"
path_append "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin"
path_append "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin"
path_append "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin"
path_append "/Library/Apple/usr/bin"
