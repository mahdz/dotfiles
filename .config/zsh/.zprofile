# =============================================================================
# ~/.zprofile - Login Shell PATH Configuration for macOS
# =============================================================================
# This file is sourced only for login shells and handles PATH management
# Ensures development tools take priority over system versions

# Set XDG base dirs.
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}

# Ensure XDG dirs exist.
for xdgdir in XDG_{CONFIG,CACHE,DATA,STATE}_HOME; do
  [[ -e ${(P)xdgdir} ]] || mkdir -p ${(P)xdgdir}
done

# OS specific
if [[ "$OSTYPE" == darwin* ]]; then
  export XDG_DESKTOP_DIR=${XDG_DESKTOP_DIR:-$HOME/Desktop}
  export XDG_DOCUMENTS_DIR=${XDG_DOCUMENTS_DIR:-$HOME/Documents}
  export XDG_DOWNLOAD_DIR=${XDG_DOWNLOAD_DIR:-$HOME/Downloads}
  export XDG_MUSIC_DIR=${XDG_MUSIC_DIR:-$HOME/Music}
  export XDG_PICTURES_DIR=${XDG_PICTURES_DIR:-$HOME/Pictures}
  export XDG_VIDEOS_DIR=${XDG_VIDEOS_DIR:-$HOME/Videos}
  export XDG_PROJECTS_DIR=${XDG_PROJECTS_DIR:-$HOME/Developer}
fi

# =============================================================================
# PATH MANAGEMENT UTILITIES
# =============================================================================

# Append directory to PATH if it exists and isn't already present
# Only adds directories that actually exist on the filesystem
# Checks for duplicates using pattern matching to avoid PATH bloat
path_prepend() {
  if [[ -d "$1" ]] && (( ! ${path[(I)$1]} )); then
    path=("$1" $path)
  fi
}

path_append() {
  if [[ -d "$1" ]] && (( ! ${path[(I)$1]} )); then
    path+=("$1")
  fi
}

# =============================================================================
# PATH INITIALIZATION
# =============================================================================

# Ensure path arrays do not contain duplicates.
typeset -gU fpath path cdpath

# Set the list of directories that cd searches.
cdpath=(
  $XDG_PROJECTS_DIR(N/)
  $cdpath
)

# Set the list of directories that Zsh searches for programs.
path=(
  # core
  $HOME/{,s}bin(N)
  $HOME/brew/{,s}bin(N)
  /opt/{homebrew,local}/{,s}bin(N)
  /usr/local/{,s}bin(N)

  # apps
  /{usr/local,opt/homebrew}/opt/curl/bin(N)

  # path
  ${path[@]}
)

# =============================================================================
# DEVELOPMENT TOOLS AND LANGUAGES
# =============================================================================

path_prepend "$HOME/.local/share/mise/shims"

# =============================================================================
# OPTIONAL TOOLS
# =============================================================================

# ShellHistory.app
path_append "/Applications/ShellHistory.app/Contents/Helpers"

# Added by LM Studio CLI (lms)
path_append "$HOME/.lmstudio/bin"
# End of LM Studio CLI section

# VS Code Scripts
path_append "${XDG_CONFIG_HOME:-$HOME/.config}/vscode"

# GPG Suite
# path_append "/usr/local/MacGPG2/bin"

# id774/scripts.git
path_append "$HOME/Developer/repos/id774/scripts"

# =============================================================================
# APPLE SYSTEM PATHS
# =============================================================================
# These have lowest priority

# Apple system paths (lowest priority)
path_append "/System/Cryptexes/App/usr/bin"
path_append "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin"
path_append "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin"
path_append "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin"
path_append "/Library/Apple/usr/bin"
