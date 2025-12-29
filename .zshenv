export ZDOTDIR="${ZDOTDIR:-$HOME/.config/zsh}"

# Ensure ZDOTDIR exists
[[ -d "$ZDOTDIR" ]] || mkdir -p "$ZDOTDIR"

[[ -r "$ZDOTDIR/.zshenv" ]] && . "$ZDOTDIR/.zshenv"
