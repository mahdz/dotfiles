# =============================================================================
# utilities.zsh -
# =============================================================================

# =============================================================================
# GREP
# =============================================================================

# In your .zshrc
# export GREP_OPTIONS="-R"  # Recursive search by default
export GREP_COMMAND="rg"  # Some tools respect this

export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME}/ripgrep/config"

# =============================================================================
# OPTIONAL TOOLS
# =============================================================================

# ShellHistory.app - macOS shell history management
path+=("/Applications/ShellHistory.app/Contents/Helpers")

# VS Code Scripts
path+=("${XDG_CONFIG_HOME:-$HOME/.config}/vscode")

# id774/scripts.git
path+=("$HOME/Developer/repos/id774/scripts")

export SCRIPTS='/Users/mh/Developer/repos/id774/scripts'

# tldr (tlrc)
command_exists tldr && export TLRC_CONFIG="${XDG_CONFIG_HOME}/tlrc/config.toml"

# bat

# Use bat to colorize man pages
command_exists bat && export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# bat-extras
command_exists batman && eval "$(batman --export-env)"

# batpipe
command_exists batpipe && eval "$(batpipe 2>/dev/null)"

command_exists broot && source "${XDG_CONFIG_HOME}/broot/launcher/bash/br"


# fastfetch
#[[ $(command -v fastfetch) ]] && fastfetch --config $(printf "%s\n" examples/{12,13} | gshuf -n 1)

# navi
if (( $+commands[navi] )); then
  navi() {
    unfunction navi  # Remove stub
    eval "$(command navi widget zsh)"
    navi "$@"  # Execute original command
  }
fi
