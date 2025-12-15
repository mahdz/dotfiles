#!/bin/zsh
#
# .zshenv: Zsh environment file, loaded always.
#

export ZDOTDIR="${ZDOTDIR:-$HOME/.config/zsh}"

# XDG
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Fish-like dirs
#: ${__zsh_config_dir:=${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}}
#: ${__zsh_user_data_dir:=${XDG_DATA_HOME:-$HOME/.local/share}/zsh}
#: ${__zsh_cache_dir:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh}

export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"

# Make Apple Terminal behave.
if [[ "$OSTYPE" == darwin* ]]; then
  export SHELL_SESSIONS_DISABLE="${SHELL_SESSIONS_DISABLE:-1}"
fi

# Security and privacy settings
umask 022                               # Set default file permissions

# =============================================================================
# PATH Initialization
# =============================================================================
# Set PATH in .zshenv to ensure system commands + Homebrew are available
# during early shell initialization (before plugins load)
# Plugins like use-omz and ssh-agent need mkdir, git, ln to be findable

# Homebrew location (architecture-specific)
if [[ "$(uname -m)" == "arm64" ]]; then
  export HOMEBREW_PREFIX="/opt/homebrew"
else
  export HOMEBREW_PREFIX="/usr/local"
fi

# Set PATH with Homebrew + system paths
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Add user binaries
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"

# =============================================================================
# Load shellrc for utility functions
# =============================================================================
# shellrc defines functions used by plugins (is_directory, command_exists, etc.)
# Load it here AFTER PATH is set so commands like 'uname' work
source "$HOME/.config/shell/shellrc"
