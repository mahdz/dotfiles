#
# iterm2: 
#

# Installs Shell Integration for iTerm2.
# test -e "${XDG_CONFIG_HOME:-$HOME/.config}/iterm2/.iterm2_shell_integration.${SHELL##*/}" && source "${XDG_CONFIG_HOME:-$HOME/.config}/iterm2/.iterm2_shell_integration.${SHELL##*/}"

if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/iterm2/.iterm2_shell_integration.${SHELL##*/}" ]; then
source "${XDG_CONFIG_HOME:-$HOME/.config}/iterm2/.iterm2_shell_integration.${SHELL##*/}"

alias imgcat=${XDG_CONFIG_HOME:-$HOME/.config}/iterm2/imgcat
alias imgls=${XDG_CONFIG_HOME:-$HOME/.config}/iterm2/imgls
alias it2api=${XDG_CONFIG_HOME:-$HOME/.config}/iterm2/it2api
alias it2attention=${XDG_CONFIG_HOME:-$HOME/.config}/iterm2/it2attention
alias it2check=${XDG_CONFIG_HOME:-$HOME/.config}/iterm2/it2check
alias it2copy=${XDG_CONFIG_HOME:-$HOME/.config}/iterm2/it2copy
alias it2dl=${XDG_CONFIG_HOME:-$HOME/.config}/iterm2/it2dl
alias it2getvar=${XDG_CONFIG_HOME:-$HOME/.config}/iterm2/it2getvar
alias it2git=${XDG_CONFIG_HOME:-$HOME/.config}/iterm2/it2git
alias it2setcolor=${XDG_CONFIG_HOME:-$HOME/.config}/iterm2/it2setcolor
alias it2setkeylabel=${XDG_CONFIG_HOME:-$HOME/.config}/iterm2/it2setkeylabel
alias it2ul=${XDG_CONFIG_HOME:-$HOME/.config}/iterm2/it2ul
alias it2universion=${XDG_CONFIG_HOME:-$HOME/.config}/iterm2/it2universion
fi