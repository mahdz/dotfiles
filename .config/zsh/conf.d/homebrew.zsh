(( $+commands[brew] )) || return 1

if [[ -z "$HOMEBREW_PREFIX" ]]; then
  source <(brew shellenv)
fi
brew_owner=$(stat -f "%Su" $HOMEBREW_PREFIX)
if [[ $(whoami) != $brew_owner ]]; then
  alias brew="sudo -Hu '$brew_owner' brew"
fi
unset brew_owner

# ╭──────────╮
# │ Brewfile │
# ╰──────────╯

export HOMEBREW_NO_AUTO_UPDATE='1'
export HOMEBREW_BUNDLE_FILE=${XDG_CONFIG_HOME:-$HOME/.config}/homebrew/init.brewfile
#export HOMEBREW_BUNDLE_DUMP_DESCRIBE='1'
export HOMEBREW_CLEANUP_MAX_AGE_DAYS='7'

#export HOMEBREW_BREWFILE_LEAVES='0'
#export HOMEBREW_BREWFILE_ON_REQUEST=1