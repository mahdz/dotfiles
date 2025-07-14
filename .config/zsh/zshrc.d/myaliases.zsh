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

# References
(( $+commands[br] )) && alias tree="${aliases[tree]:-tree} -Ch"
# - https://github.com/webpro/dotfiles/blob/master/system/.alias
# - https://github.com/mathiasbynens/dotfiles/blob/master/.aliases
# - https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/common-aliases/common-aliases.plugin.zsh
#

# single character shortcuts - be sparing!
alias l='ls'
alias g='git'

# mask built-ins with better defaults
alias ping='ping -c 5'
(( $+commands[bat] )) && alias cat='bat'
(( $+commands[br] )) && tree="${aliases[tree]:-tree} -Ch"
alias type='type -a'

# Verbosity and settings that you pretty much just always are going to want.
alias cp="\${aliases[cp]:-cp} -p"
alias mv='mv -iv'
alias bc='bc -ql'
alias mkdir='mkdir -pv'
alias ffmpeg='ffmpeg -hide_banner'

# more ways to ls
alias ll='ls -lh'
alias la='ls -lAh'
alias ldot='ls -ld .*'

# fix typos
#alias get=git
alias quit='exit'
alias cd..='cd ..'
alias zz='exit'

# editor
# Preferred editor for remote sessions
test -n "${SSH_CONNECTION}" && export EDITOR=nano
# Use code if it's installed (both Mac OSX and Linux)
(( $+commands[code] )) && export EDITOR=code
# If neither of the above works, then fall back to nano
(( $+commands[micro] )) && test -z "${EDITOR}" && export EDITOR=micro

# edit quicker with functions
ea() { ${EDITOR} "${ZDOTDIR:-$HOME}/zshrc.d/myaliases.zsh" & disown; }
ez() { ${EDITOR} "${ZDOTDIR:-$HOME}/.zshrc" >/dev/null & disown; }

# Find + manage aliases
alias al='alias | less'         # List all aliases
alias as='alias | command grep' # Search aliases
alias ar='unalias'              # Remove given alias

# find#aliaenlinks='find . -type l | (while read FN ; do test -e "$FN" || ls -ld "$FN"; done)'
#alias clea"logs='rm -r"v */log/*.log'
if (( ${+commands[fd]} )); then
  alias killds="fd -HI -t f '.DS_Store' -X rm"
else
  alias killds="sudo find . -type f -name .DS_Store -print -delete"
fi

# misc
alias zshrc='${EDITOR:-micro} "${ZDOTDIR:-$HOME/.config/zsh}"/.zshrc'
alias zbench='for i in {1..10}; do /usr/bin/time zsh -lic exit; done'
alias cls="clear && printf '\e[3J'"
alias mise-upgrade='fix-mise-python-cache && mise upgrade'
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
  print -l ${(k)functions[(I)[^_]*]} | grep -v -E '(omz|_prompt_|warp|zle|^\.)' | sort | fzf
}

# color
alias colormap='for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+"\n"}; done'


# =============================================================================
# Dotfiles
# =============================================================================

: ${DOTFILES:=$HOME/.dotfiles}

dot() {
  command git --git-dir="${DOTFILES}" --work-tree="$HOME" "$@"
}

dotcode() {
  emulate -L zsh
  setopt LOCAL_OPTIONS PIPE_FAIL ERR_EXIT
  # Launch VS Code with the workspace, passing GIT_WORK_TREE and GIT_DIR only for this process
  GIT_WORK_TREE="$HOME" GIT_DIR="${DOTFILES}" code "$HOME/.config/vscode/dotfiles.code-workspace"
}
alias zdot='cd "${ZDOTDIR:-$HOME/.config/zsh}"'


# =============================================================================
# Secrets
# =============================================================================

alias secrets='cd "${XDG_CONFIG_HOME:-$HOME/.config}/secrets"'

export GNUPGHOME=${GNUPGHOME:=${XDG_DATA_HOME:-$HOME/.local/share}/gnupg}
[[ -e $GNUPGHOME:h ]] || mkdir -p "$GNUPGHOME:h"
alias gpg='${aliases[gpg]:-gpg} --homedir "$GNUPGHOME"'

# iwd - initial working directory
: ${IWD:=$PWD}
alias iwd='cd "$IWD"'

# Command line history
alias h=' history' # Shows full history
alias h-search=' fc -El 0 | grep' # Searchses for a word in terminal history
alias histrg=' history -500 | rg' # Rip grep search recent history

# zsh suffix aliases
#alias -g H='| head'
#alias -g T='| tail'
alias -g G='| grep -E'
alias -g S='| sort'
alias -g L='| less'
alias -g M='| more'
alias -g Z='| fzf'
(( $+commands[bat] )) && alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
(( $+commands[bat] )) && alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'

# =============================================================================
# Basic Memory
# =============================================================================

alias note="basic-memory tools write-note"
alias notemv="basic-memory tools move-note"
alias search="basic-memory tools search-notes --query"
alias recent="basic-memory tools recent-activity"


# If an alias for the command just run exists, then show tip
preexec_alias-finder() {
  tip=$(alias | grep -E "=$1$" | head -1)
  if [ ! -z "$tip" ]; then
    echo -e "\033[0;90m\e[3mAlias Tip: \e[4m$tip\033[0m"
  fi
}

# Load add-zsh-hook
autoload -U add-zsh-hook

# Call function after command
# This allows the shell to display a tip if an alias exists for the command being run.
add-zsh-hook preexec preexec_alias-finder
