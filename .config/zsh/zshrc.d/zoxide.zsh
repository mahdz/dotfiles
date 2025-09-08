#
# zoxide: Configure zoxide.
#

command -v zoxide &> /dev/null || return

eval "$(zoxide init zsh)"

export _ZO_DATA_DIR="${XDG_DATA_HOME}/zoxide"
export _ZO_ECHO=1
export _ZO_RESOLVE_SYMLINKS=1

if (( $+commands[fzf] )); then
  export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS $fzf_preview"
  z() {
    local dir=$(
    zoxide query --list --score |
    fzf --height 40% --layout reverse --info inline \
    --nth 2.. --tac --no-sort --query "$*" \
    --bind 'enter:become:echo {2..}'
    ) && cd "$dir"
    }
fi
