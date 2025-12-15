# =============================================================================
# __init__.zsh
# =============================================================================
# This runs prior to any other conf.d contents.

# =============================================================================
# PATH Setup (Before Antidote)
# =============================================================================
# Ensure system paths are in PATH before plugins load
# This prevents "command not found" errors during plugin initialization
path=(
  $HOME/bin(N)
  $HOME/.local/bin(N)
  ${HOMEBREW_PREFIX:-/opt/homebrew}/{,s}bin(N)
  /usr/local/{,s}bin(N)
  /usr/bin
  /bin
  /usr/sbin
  /sbin
  $path
)
typeset -U path
export PATH

# =============================================================================
# ENVIRONMENT VARIABLES & EXPORTS
# =============================================================================

# Apps
# Preferred editor for remote sessions
if [[ -n "${SSH_CONNECTION}" ]]; then
  export EDITOR=nano
elif (( $+commands[code] )); then
  export EDITOR=code
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

export SCRIPTS='/Users/mh/Developer/repos/id774/scripts'

# =============================================================================
# SECRETS
# =============================================================================

export SOPS_EDITOR=nano
export SECRETS_FILE="${SECRETS_FILE:-$HOME/.local/share/secrets/.env}"

# =============================================================================
# GREP
# =============================================================================

# In your .zshrc
# export GREP_OPTIONS="-R"  # Recursive search by default
# export GREP_COMMAND="rg"  # Some tools respect this

# export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME}/ripgrep/config"
