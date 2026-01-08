# =============================================================================
# aliases.zsh
# =============================================================================
# Defines Zsh and Bash aliases, suffix aliases, and related helper functions
# for improved command-line productivity and consistency.
#
# Usage:
#   Source from your .zshrc or load automatically via ZDOTDIR:
#     source "${ZDOTDIR:-$HOME/.config/zsh}/zshrc.d/aliases.zsh"
#
# This file is intended for Apple Silicon/macOS environments using XDG-compliant
# dotfiles and developer tooling.
#
# =============================================================================
# aliases - Zsh and bash aliases
#

# DUPLICATE! Copied over since we get an error if the .shellrc was not loaded
type command_exists &> /dev/null 2>&1 || source "${HOME}/.config/shell/shellrc"

# add flags to existing aliases
# alias less="${aliases[less]:-less} -RF"
# alias cp="${aliases[cp]:-cp} -p"

# eza already defines 'll' - so skip if that's present
command_exists tree && alias tree="${aliases[tree]:-tree} -Ch"
command_exists bat && alias cat='bat --paging never --style plain'

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
alias grep="command grep --exclude-dir={.git,.vscode}"
export GNUPGHOME=${XDG_DATA_HOME:=~/.local/share}/gnupg
alias gpg="command gpg --homedir \"\$GNUPGHOME\""
export GPG_TTY=$(tty)

# brew
alias brewup="brew update && brew upgrade && brew cleanup"

# directories
alias secrets="cd ${XDG_DATA_HOME:=~/.local/share}/secrets"

# more ways to ls
alias ll='ls -lh'
alias la='ls -lAh'
alias lsa="ls -aG"
alias ldot='ls -ld .*'

# Verbosity and settings that you pretty much just always are going to want.
alias mv='mv -iv'
alias mkdir='mkdir -pv'
alias ffmpeg='ffmpeg -hide_banner'

# edit quicker with functions
ea() { ${EDITOR:-micro} "${ZSH_CUSTOM:-$ZDOTDIR/custom}/plugins/aliases/aliases.plugin.zsh" & disown; }
ep() { ${EDITOR:-micro} "${ZDOTDIR:-$HOME/.config/zsh}/.zsh_plugins.txt" & disown; }
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

# set initial working directory
: ${IWD:=$PWD}
alias iwd='cd $IWD'

# color
alias colormap='for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+"\n"}; done'

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

# MacOS: Remove apps from quarantine
alias unquarantine='sudo xattr -rd com.apple.quarantine'

