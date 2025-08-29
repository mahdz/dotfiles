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

# Legacy secrets.zsh (will be removed after migration)
[ -f ${XDG_DATA_HOME}/secrets/secrets.zsh ] && source ${XDG_DATA_HOME}/secrets/secrets.zsh

# =============================================================================
# GREP
# =============================================================================

# In your .zshrc
#export GREP_OPTIONS="-R"  # Recursive search by default
#export GREP_COMMAND="rg"  # Some tools respect this

export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME}/ripgrep/config"

# -----------------------------------------------------
# ╭─────────╮
# │ VS Code │
# ╰─────────╯
#if type code >/dev/null 2>&1; then
# VSCODE_PORTABLE: Stores all VS Code data including settings, keybindings, and snippets
#  export VSCODE_PORTABLE="~/Applications/code-portable-data/user-data"

# VSCODE_EXTENSIONS: Specifies custom extensions directory
#  export VSCODE_EXTENSIONS="${XDG_DATA_HOME:-~/.local/share}/vscode/extensions"
#fi

# -----------------------------------------------------
# ╭─────────────────╮
# │ Shell Utilities │
# ╰─────────────────╯

# tldr (tlrc)
[[ $(command -v tldr) ]] && export TLRC_CONFIG="${XDG_CONFIG_HOME}/tlrc/config.toml"

# bat
[[ $(command -v bat) ]] && export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# bat-extras
[[ $(command -v batman) ]] && eval "$(batman --export-env)"

# batpipe
[[ $(command -v batpipe) ]] && eval "$(batpipe)"

[[ $(command -v broot) ]] && source "${XDG_CONFIG_HOME}/broot/launcher/bash/br"

# fastfetch
#[[ $(command -v fastfetch) ]] && fastfetch --config $(printf "%s\n" examples/{12,13} | gshuf -n 1)

# navi
#[[ $(command -v navi) ]] && eval "$(navi widget zsh)"
