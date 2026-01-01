#
# Antidote
#

: ${ANTIDOTE_HOME:=${XDG_CACHE_HOME:-~/.cache}/repos}

# Detect correct Antidote installation path
if [[ -d "/opt/homebrew/opt/antidote/share/antidote" ]]; then
  # Apple Silicon Homebrew
  export ANTIDOTE_REPO="/opt/homebrew/opt/antidote/share/antidote"
elif [[ -d "$ANTIDOTE_HOME/mattmc3/antidote" ]]; then
  # User-cloned version
  export ANTIDOTE_REPO="$ANTIDOTE_HOME/mattmc3/antidote"
else
  # Auto-install if missing
  echo "⚠️  Antidote not found. Installing to $ANTIDOTE_HOME/mattmc3/antidote..."
  command git clone --depth=1 https://github.com/mattmc3/antidote.git "$ANTIDOTE_HOME/mattmc3/antidote"
  export ANTIDOTE_REPO="$ANTIDOTE_HOME/mattmc3/antidote"
fi

# Configure antidote behavior
zstyle ':antidote:bundle' use-friendly-names 'yes'
zstyle ':antidote:plugin:*' defer-options '-p'
zstyle ':antidote:plugin:*' zcompile 'no'

is-not-warpterm() {
  [[ $TERM_PROGRAM != WarpTerminal ]]
}
is-theme-starship() {
  [[ $ZSH_THEME == starship* ]]
}

# Source Antidote
if [[ -f "$ANTIDOTE_REPO/antidote.zsh" ]]; then
  source "$ANTIDOTE_REPO/antidote.zsh"
else
  echo "❌ ERROR: Could not find $ANTIDOTE_REPO/antidote.zsh"
  return 1
fi

antidote load