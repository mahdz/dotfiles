# dotfiles
: ${DOTFILES:=$HOME/.dotfiles}
alias dotdir='cd "$DOTFILES"'
alias dotcode='GIT_WORK_TREE="$HOME" && cd "$DOTFILES" && code .'
# alias dotfl="cd \$DOTFILES/local"
# alias fdot='cd ${XDG_CONFIG_HOME:-~/.config}/fish'
# alias fconf=fdot
alias zdot='cd $ZDOTDIR'

hash -d vault="$VAULT_PATH"

# Mark the plugin as loaded
zstyle ':zsh_custom:plugin:dotfiles' loaded 'yes'
