# Set ZDOTDIR to XDG-compliant location
export ZDOTDIR="$HOME/.config/zsh"

# Check if `.zshenv` exists and is readable, and if so, source it using the `.` (dot) command.
[[ -r "$ZDOTDIR/.zshenv" ]] && . "$ZDOTDIR/.zshenv"