#!/bin/zsh
#
# .zprofile - Zsh file loaded on login.
#

#
# Browser
#

if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER="${BROWSER:-open}"
fi

#
# Editors
#

export EDITOR="${EDITOR:-code}"
export VISUAL="${VISUAL:-code}"
export PAGER="${PAGER:-less}"

#
# Regional Settings
#

export LANG="${LANG:-en_US.UTF-8}"

#
# Paths
#

# Ensure path arrays do not contain duplicates.
typeset -gU path fpath cdpath mailpath

# set the list of directories that `cd` searches
# cdpath=(
#   ~/Projects
#   $cdpath
# )

# Set the list of directories that zsh searches for commands.
path=(
  $HOME/{,s}bin(N)
  /opt/{homebrew,local}/{,s}bin(N)
  /usr/local/{,s}bin(N)
  $path
)

#
# Less
#

# Set default less options.
export LESS="${LESS:--g -i -M -R -S -w -z-4}"

# Set the less input preprocessor.
if [[ -z "$LESSOPEN" ]] && (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

#
# Misc
#

# Use `< file` to quickly view the contents of any file.
[[ -z "$READNULLCMD" ]] || READNULLCMD=$PAGER

# vim: ft=zsh sw=2 ts=2 et