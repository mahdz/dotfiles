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

# Start with essential system paths to ensure basic commands are available
# This prevents "command not found" errors during shell initialization
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Initialize Homebrew - prepends to PATH for proper tool detection
# Add to PATH unconditionally so subsequent tools (mise, etc.) can be found
if [[ "$(uname -m)" == "arm64" ]]; then
  # Apple Silicon
  path_prepend "/opt/homebrew/opt/git/bin"
  path_prepend "/opt/homebrew/sbin"
  path_prepend "/opt/homebrew/bin"
else
  # Intel
  path_prepend "/usr/local/opt/git/bin"
  path_prepend "/usr/local/sbin"
  path_prepend "/usr/local/bin"
fi

# =============================================================================
# HIGH PRIORITY DEVELOPMENT TOOLS
# =============================================================================
# These tools should override system versions

# User-specific development tools (highest priority)
# Ensure mise shim directory is at the front of PATH
# -----------------------------
# Mise initialization
# -----------------------------
# Initialize mise for full functionality (shell hooks, auto-switching, etc.)
# This supersedes the shim-only approach and enables advanced features
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
else
  export PATH="$HOME/.local/share/mise/shims:$PATH"
fi

# npm global bin directory (for mise integration)
path_prepend "$HOME/.local/share/npm-global/bin"
# path_prepend "${XDG_DATA_HOME:-$HOME/.local/share}/npm/bin"

# User-installed tools (high priority)
path_prepend "/usr/local/bin"
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"

# =============================================================================
# DEVELOPMENT TOOLS AND LANGUAGES
# =============================================================================

# =============================================================================
# OPTIONAL TOOLS
# =============================================================================

# ShellHistory.app
path_append "/Applications/ShellHistory.app/Contents/Helpers"

# Added by LM Studio CLI (lms)
path_append "$HOME/.lmstudio/bin"
# End of LM Studio CLI section

# VS Code Scripts
path_append "${XDG_CONFIG_HOME:-$HOME/.config}/vscode"

# GPG Suite
# path_append "/usr/local/MacGPG2/bin"

# id774/scripts.git
path_append "/Users/mh/Developer/repos/id774/scripts"

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

# -----------------------------
# Cache directories
# -----------------------------
__zsh_data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh"
__zsh_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
/bin/mkdir -p "$__zsh_data_dir" "$__zsh_cache_dir"

# -----------------------------
# Create XDG directories if they don't exist
# -----------------------------
/bin/mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}" \
            "${XDG_CACHE_HOME:-$HOME/.cache}" \
            "${XDG_DATA_HOME:-$HOME/.local/share}" \
            "${XDG_STATE_HOME:-$HOME/.local/state}"

export ZSH_CACHE_DIR="$__zsh_cache_dir"
export ZSH_COMPDUMP="$__zsh_cache_dir/.zcompdump"
export ZSH_COMPCACHE="$__zsh_cache_dir/.zcompcache"
