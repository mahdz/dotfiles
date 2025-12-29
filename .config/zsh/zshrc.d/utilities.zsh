# =============================================================================
# utilities.zsh -
# =============================================================================
#

export SCRIPTS='/Users/mh/Developer/repos/id774/scripts'

# tldr (tlrc)
command_exists tldr && export TLRC_CONFIG="${XDG_CONFIG_HOME}/tlrc/config.toml"

# bat

# Use bat to colorize man pages
command_exists bat && export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# bat-extras
command_exists batman && eval "$(batman --export-env)"

# batpipe
command_exists batpipe && eval "$(batpipe)"

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
