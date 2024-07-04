#
# zoxide: Configure zoxide.
#

# https://github.com/ajeetdsouza/zoxide
if (( $+commands[zoxide] )); then
  cached-eval 'zoxide-init-zsh' zoxide init zsh
  export _ZO_DATA_DIR=${XDG_DATA_HOME:-$HOME/.local/share}/zoxide
  export _ZO_ECHO='1'
  export _ZO_RESOLVE_SYMLINKS='1'
fi
