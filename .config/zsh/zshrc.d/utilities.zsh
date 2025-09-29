# =============================================================================
# utilities.zsh -
# =============================================================================
#

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
[[ $(command -v navi) ]] && eval "$(navi widget zsh)"
