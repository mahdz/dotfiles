# Set the ZDOTDIR environment variable to specify the location of Zsh configuration files.
# By default, Zsh looks for configuration files in $HOME, but this allows us to use a dedicated directory.
export ZDOTDIR="$HOME/.config/zsh"

# Check if the .zshenv file exists and is readable in the specified ZDOTDIR directory.
# The .zshenv file is sourced for every new Zsh instance, even non-interactive ones.
# If the file exists and is readable, source it (execute its contents) using the '.' (dot) command.
[[ -r "$ZDOTDIR/.zshenv" ]] && . "$ZDOTDIR/.zshenv"