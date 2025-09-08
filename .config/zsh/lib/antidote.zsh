#
# Antidote
#

: ${ANTIDOTE_HOME:=${XDG_CACHE_HOME:-~/.cache}/repos}

# ZSH="${ANTIDOTE_HOME}/ohmyzsh/ohmyzsh"

# Keep all 3 for different test scenarios.
# ANTIDOTE_REPO=$ANTIDOTE_HOME/mattmc3/antidote
# ANTIDOTE_REPO=~/Projects/mattmc3/antidote
ANTIDOTE_REPO=${HOMEBREW_PREFIX:-/opt/homebrew}/opt/antidote/share/antidote

zstyle ':antidote:home' path $ANTIDOTE_HOME
zstyle ':antidote:repo' path $ANTIDOTE_REPO
zstyle ':antidote:bundle' use-friendly-names 'yes'
zstyle ':antidote:plugin:*' defer-options '-p'
zstyle ':antidote:*' zcompile 'yes'

# Defensive: ensure ANTIDOTE_REPO is not empty
if [[ -z "$ANTIDOTE_REPO" ]]; then
  echo "ERROR: ANTIDOTE_REPO is not set!"
  return 1
fi

# Clone if missing
if [[ ! -d "$ANTIDOTE_REPO" ]]; then
  git clone https://github.com/mattmc3/antidote "$ANTIDOTE_REPO"
fi

# Source Antidote (must be before any `antidote` command is used)
source "$ANTIDOTE_REPO/antidote.zsh"

antidote load
