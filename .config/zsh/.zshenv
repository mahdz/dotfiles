# XDG
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}
/bin/mkdir -p $XDG_CONFIG_HOME $XDG_CACHE_HOME $XDG_DATA_HOME $XDG_STATE_HOME

# CRITICAL: Set HISTFILE early to prevent deletion by plugins or scripts
# This MUST be set before .zshrc loads to ensure all shells know where history lives
# Fixed 2025-10-28: History was being deleted because HISTFILE wasn't set early enough
export HISTFILE="${XDG_DATA_HOME}/zsh/zsh_history"

export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"

# Make Apple Terminal behave.
if [[ "$OSTYPE" == darwin* ]]; then
  export SHELL_SESSIONS_DISABLE=${SHELL_SESSIONS_DISABLE:-1}
fi

# You can use .zprofile to set environment vars for non-login, non-interactive shells.
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

# Load the .shellrc here - just to define some env vars that we need before zsh lifecycle kicks in
source "$HOME/.config/shell/shellrc"
