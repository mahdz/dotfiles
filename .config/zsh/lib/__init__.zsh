# =============================================================================
# __init__.zsh
# =============================================================================
# This runs prior to any other conf.d contents.

# =============================================================================
# ENVIRONMENT VARIABLES & EXPORTS
# =============================================================================

# Apps
# Preferred editor for remote sessions
if [[ -n "${SSH_CONNECTION}" ]]; then
  export EDITOR=nano
elif (( $+commands[code] )); then
  export EDITOR="code --wait"
elif (( $+commands[micro] )); then
  export EDITOR=micro
else
  export EDITOR=nano
fi

# Align VISUAL with EDITOR if not set
export VISUAL=${VISUAL:-$EDITOR}

# Set pager and options
export PAGER=less
export LESS='-iRFXMx4 --incsearch --use-color --mouse'

# =============================================================================
# GREP
# =============================================================================

# In your .zshrc
# export GREP_OPTIONS="-R"  # Recursive search by default
# export GREP_COMMAND="rg"  # Some tools respect this

# export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME}/ripgrep/config"
