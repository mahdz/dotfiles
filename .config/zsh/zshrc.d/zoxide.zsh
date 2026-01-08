#
# zoxide: Configure zoxide.
#

if ! (( $+commands[zoxide] )); then
  echo "zoxide not found" >&2
  return 1
fi

_zoxide_cache="$XDG_CACHE_HOME/zsh/zoxide_init.zsh"

# Rebuild cache if missing or zoxide binary is newer
if [[ ! -f "$_zoxide_cache" ]] || [[ "$_zoxide_cache" -ot =zoxide ]]; then
zoxide init zsh >| "$_zoxide_cache"
zcompile "$_zoxide_cache" # Compile for extra speed
fi

source "$_zoxide_cache"

# Keep your existing FZF integration...
export _ZO_DATA_DIR="${XDG_DATA_HOME}/zoxide"

eval "$(zoxide init zsh)"

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
