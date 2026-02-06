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
export GNUPGHOME="${XDG_DATA_HOME:=$HOME/.local/share}/gnupg"
alias gpg="command gpg --homedir \"\$GNUPGHOME\""
export GPG_TTY=$(tty)

# brew
alias brewup="brew update && brew upgrade --fetch-HEAD && brew cleanup -s"

# directories
alias secrets="cd ${XDG_DATA_HOME:=$HOME/.local/share}/secrets"

# more ways to ls
alias ll='ls -lh'
alias la='ls -lAh'
alias lsa="ls -aG"
alias ldot='ls -ld .*'

# Verbosity and settings that you pretty much just always are going to want.
alias mv='mv -iv'
alias mkdir='mkdir -pv'
alias ffmpeg='ffmpeg -hide_banner'

# ============================
# Helper Functions (DRY)
# ============================
# Generic editor launcher for config files
_edit_config() { ${EDITOR:-micro} "$1" & disown; }
ea() { _edit_config "${ZSH_CUSTOM:-$ZDOTDIR/custom}/plugins/aliases/aliases.plugin.zsh"; }
ep() { _edit_config "${ZDOTDIR:-$HOME/.config/zsh}/.zsh_plugins.txt"; }
es() { _edit_config "${ZDOTDIR:-$HOME/.config/zsh}/.zstyles"; }

# Generic file finder + cleaner (with dry-run safety)
_find_and_clean() {
  local pattern="$1"
  local target="${2:-.}"
  local dry_run="${3:-false}"
  
  if (( ${+commands[fd]} )); then
    local cmd="fd -HI -t f '$pattern' '$target'"
    if [[ "$dry_run" == "true" ]]; then
      echo "🔍 Preview: $(eval $cmd | wc -l) file(s) matching '$pattern'"
      eval $cmd
    else
      eval $cmd --delete && echo "✅ Deleted files matching '$pattern'"
    fi
  else
    local cmd="find '$target' -type f -name '$pattern'"
    if [[ "$dry_run" == "true" ]]; then
      echo "🔍 Preview: $(eval $cmd | wc -l) file(s) matching '$pattern'"
      eval $cmd
    else
      eval "$cmd -delete" && echo "✅ Deleted files matching '$pattern'"
    fi
  fi
}

# .DS_Store cleanup (safe with preview)
killds() {
  local mode="${1:-interactive}"
  local target="${2:-.}"
  
  case "$mode" in
    preview|dry-run)
      _find_and_clean '.DS_Store' "$target" true
      ;;
    *)
      _find_and_clean '.DS_Store' "$target" true
      read -q "?Delete these files? (y/n) " || return 1
      echo
      _find_and_clean '.DS_Store' "$target" false
      ;;
  esac
}

alias killds-preview='killds preview'

# misc
alias zbench='for i in {1..10}; do /usr/bin/time zsh -lic exit; done'
alias cls="clear && printf '\e[3J'"
alias keka='/Applications/Keka.app/Contents/MacOS/Keka --cli'
alias stash='stash --config ~/.config/stash/config.yml'

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

