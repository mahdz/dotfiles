# .zshenv: Zsh environment file, loaded for all shells.
# Ref: http://zsh.sourceforge.net/Doc/Release/Files.html

[[ -z "$ZDOTDIR" ]] && export ZDOTDIR="$HOME/.config/zsh"

# Set XDG base dirs.
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

# Ensure they exist (lightweight, only runs once per session)
for dir in XDG_{CONFIG,CACHE,DATA}_HOME; do
  [[ -d ${(P)dir} ]] || mkdir -p ${(P)dir}
done
unset dir

# Load the .shellrc here - just to define some env vars that we need before zsh lifecycle kicks in
source "${HOME}/.shellrc"

# https://blog.patshead.com/2011/04/improve-your-oh-my-zsh-startup-time-maybe.html
skip_global_compinit=1
