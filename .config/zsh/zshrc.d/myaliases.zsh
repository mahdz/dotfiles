# =============================================================================
# myaliases.zsh
# =============================================================================
# Defines Zsh and Bash aliases, suffix aliases, and related helper functions
# for improved command-line productivity and consistency.
#
# Usage:
#   Source from your .zshrc or load automatically via ZDOTDIR:
#     source "${ZDOTDIR:-$HOME/.config/zsh}/zshrc.d/myaliases.zsh"
#
# This file is intended for Apple Silicon/macOS environments using XDG-compliant
# dotfiles and developer tooling.
#
# =============================================================================
# aliases - Zsh and bash aliases
#

# DUPLICATE! Copied over since we get an error if the .shellrc was not loaded
type command_exists &> /dev/null 2>&1 || source "${XDG_CONFIG_HOME}/shell/shellrc"

# add flags to existing aliases
alias less="${aliases[less]:-less} -RF"
alias cp="${aliases[cp]:-cp} -p"

# eza already defines 'll' - so skip if that's present
command_exists tree && alias tree="${aliases[tree]:-tree} -Ch"
command_exists bat && alias cat='bat'

alias zdot='cd "${ZDOTDIR:-$HOME/.config/zsh}"'

# ============================
# Pipe and Redirection Aliases
# ============================
# zsh suffix aliases
#alias -g G='| grep'
#alias -g H='| head'
#alias -g L='| less'
#alias -g M='| more'
#alias -g S='| sort'
#alias -g T='| tail'
#alias -g Z='| fzf'
(( $+commands[bat] )) && alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
(( $+commands[bat] )) && alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'

alias CA='2>&1 | cat -A'
alias LL='2>&1 | less'
alias NE='2> /dev/null'
alias NUL='> /dev/null 2>&1'

# ============================
# Alias Management
# ============================
# Find + manage aliases
alias al='alias | less'         # List all aliases
alias as='alias | command grep' # Search aliases
alias ar='unalias'              # Remove given alias

# ============================
# History and Search Aliases
# ============================
# mask built-ins with better defaults
alias ping='ping -c 5'
alias type='type -a'

# Verbosity and settings that you pretty much just always are going to want.
alias mv='mv -iv'
alias mkdir='mkdir -pv'
alias ffmpeg='ffmpeg -hide_banner'

# fix typos
alias get=git
alias quit='exit'
alias zz='exit'

# edit quicker with functions
ea() { ${EDITOR:-micro} "${ZSH_CUSTOM:-$ZDOTDIR/custom}/myaliases.zsh" & disown; }
ez() { ${EDITOR:-micro} "${ZDOTDIR:-$HOME/.config/zsh}/.zshrc" >/dev/null & disown; }
ep() { ${EDITOR:-micro} "${ZDOTDIR:-$HOME/.config/zsh}/.zsh_plugins.txt" >/dev/null & disown; }
es() { ${EDITOR:-micro} "${ZDOTDIR:-$HOME/.config/zsh}/.zstyles" >/dev/null & disown; }

# find#aliaenlinks='find . -type l | (while read FN ; do test -e "$FN" || ls -ld "$FN"; done)'
if (( ${+commands[fd]} )); then
  alias killds="fd -HI -t f '.DS_Store' -X rm"
else
  alias killds="sudo find . -type f -name .DS_Store -print -delete"
fi

# misc
alias zbench='for i in {1..10}; do /usr/bin/time zsh -lic exit; done'
alias cls="clear && printf '\e[3J'"
#alias mise-upgrade='fix-mise-python-cache && mise upgrade'
alias keka='/Applications/Keka.app/Contents/MacOS/Keka --cli'

# trash aliases
if (( ${+commands[gomi]} )); then
  alias rm='gomi'
else
  alias rm='rm -vI'
fi

# print things
alias print-fpath='for fp in $fpath; do echo $fp; done; unset fp'
alias print-path='echo $PATH | tr ":" "\n"'
print-functions() { # exclude oh-my-zsh, Warp, zle, and other misc functions
  print -l ${(k)functions[(I)[^_]*]} | command grep -v -E '(omz|_prompt_|warp|zle|^\.)' | sort | fzf
}

# color
alias colormap='for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+"\n"}; done'

# =============================================================================
# Dotfiles
# =============================================================================

: ${DOTFILES:=$HOME/.dotfiles}

# Make sure this alias has priority over binaries in /opt/homebrew/bin
alias -g dot='dots'

# Dotfiles shortcuts for Warp AI suggestions
alias ds='dots status'
alias da='dots add'
alias dan='dots add -n'  # dry-run first!
alias dc='dots commit'
alias dp='dots push'
alias dl='dots pull'
alias dd='dots diff'

# =============================================================================
# Git run_all
# =============================================================================

if command_exists 'run_all.sh'; then
  # shortcuts to handle multiple git repos bypassing the omz auto-correct prompt for 'git'
  alias rug='run_all.sh git'
  alias all="FOLDER='${HOME}' MAXDEPTH=6 rug"
fi

# =============================================================================
# macOS
# =============================================================================

_free_wifi() {
  local interface="${1}"
  (ifconfig "${interface}" | \grep ether) && \
  (openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//' | xargs sudo ifconfig "${interface}" ether) && \
  (ifconfig "${interface}" | \grep ether)
}
if is_macos; then alias free-wifi='_free_wifi en0'
  alias flush-dns="sudo killall -HUP mDNSResponder;sudo killall mDNSResponderHelper;sudo dscacheutil -flushcache;say MacOS DNS cache has been cleared"
fi

if is_macos; then
  # MacOS: Remove apps from quarantine
  alias unquarantine='sudo xattr -rd com.apple.quarantine'

  # MacOS: Clean up LaunchServices to remove duplicates in the "Open With" menu
  alias lscleanup='/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder'
fi

# =============================================================================
# Basic Memory
# =============================================================================

alias note-write="basic-memory tool write-note"
alias note-move="basic-memory tool move-note"
alias note-search="basic-memory tool search-notes --query"
alias note-recent="basic-memory tool recent-activity"
