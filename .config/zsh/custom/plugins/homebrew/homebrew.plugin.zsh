# =============================================================================
# homebrew.zsh - Merged Homebrew Configuration
# =============================================================================
# This file is sourced by .zshrc and contains Homebrew related configurations.
# Merged from personal config and mattmc3/zephyr/plugins/homebrew.

# =============================================================================
# CORE SETUP (from Zephyr Plugin)
# =============================================================================
# Use the official 'brew shellenv' to set up the environment.
# Guard against PATH issues - only call if brew is available
# if (( $+commands[brew] )); then
#   eval "$(brew shellenv)"
# else
#   # Fallback: manually add Homebrew to PATH if brew command not found
#   # This handles cases where plugins load before PATH is fully initialized
#   if [[ "$(uname -m)" == "arm64" ]] && [[ -x "/opt/homebrew/bin/brew" ]]; then
#     eval "$(/opt/homebrew/bin/brew shellenv)"
#   elif [[ -x "/usr/local/bin/brew" ]]; then
#     eval "$(/usr/local/bin/brew shellenv)"
#   fi
# fi

# =============================================================================
# CUSTOM ENVIRONMENT VARIABLES & EXPORTS
# =============================================================================

export HOMEBREW_NO_ANALYTICS=1          # Default to no tracking (from plugin)
export HOMEBREW_BUNDLE_DUMP_DESCRIBE=1  # (user config)
export HOMEBREW_CLEANUP_MAX_AGE_DAYS=3
export HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS=3
export HOMEBREW_VERBOSE_USING_DOTS=1
export HOMEBREW_BUNDLE_FILE="${XDG_CONFIG_HOME}/homebrew/Brewfile"
export HOMEBREW_BREWFILE="${XDG_CONFIG_HOME}/homebrew/Brewfile"
export HOMEBREW_BREWFILE_VSCODE=1       # (user config)

# =============================================================================
# ZSH COMPLETIONS (from Zephyr Plugin)
# =============================================================================

# Add brewed Zsh to fpath
if [[ -d "$HOMEBREW_PREFIX/share/zsh/site-functions" ]]; then
  fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
fi

# Add keg-only completions to fpath for commonly used tools
local kegs_for_completion=(curl ruby sqlite)
for keg in $kegs_for_completion; do
  fpath=($HOMEBREW_PREFIX/opt/${keg}/share/zsh/site-functions(/N) $fpath)
done
unset keg kegs_for_completion

# =============================================================================
# GNU UTILITIES & PATH OVERRIDES (from User Config)
# =============================================================================
# Function to prepend paths for specific Homebrew installations to ensure
# they are used over system defaults.

if command_exists brew; then
  prepend_to_manpath_if_dir_exists "${HOMEBREW_PREFIX}/share/man"

  use_homebrew_installation_for() {
    ! is_directory "${1}" && return

    prepend_to_path_if_dir_exists "${1}/bin"
    prepend_to_path_if_dir_exists "${1}/libexec/bin"
    prepend_to_path_if_dir_exists "${1}/libexec/gnubin"
    prepend_to_ldflags_if_dir_exists "${1}/lib"
    prepend_to_cppflags_if_dir_exists "${1}/include"
    prepend_to_pkg_config_path_if_dir_exists "${1}/lib/pkgconfig"
    prepend_to_manpath_if_dir_exists "${1}/libexec/gnuman"
  }

  # Override default utilities with Homebrew versions
  use_homebrew_installation_for "${HOMEBREW_PREFIX}/opt/curl"
  use_homebrew_installation_for "${HOMEBREW_PREFIX}/opt/zlib"
  use_homebrew_installation_for "${HOMEBREW_PREFIX}/opt/sqlite"
  use_homebrew_installation_for "${HOMEBREW_PREFIX}/opt/gnu-tar"

  # Override default openssl and set RUBY_CONFIGURE_OPTS
  local openssl_dir="${HOMEBREW_PREFIX}/opt/openssl@3"
  is_directory "${openssl_dir}" && use_homebrew_installation_for "${openssl_dir}" && export RUBY_CONFIGURE_OPTS="--with-openssl-dir=${openssl_dir}"
  unset openssl_dir
fi

# Let zsh sort out formatting and deduplication
typeset -gU PATH MANPATH

# =============================================================================
# ALIAS & FUNCTIONS
# =============================================================================

# Your custom aliases (take precedence)
alias brewup='brew update && brew upgrade --fetch-HEAD && brew cleanup -s && brew cu --all --interactive --include-mas'
alias bfc='brew file casklist && open Caskfile'
bbd() {
  brew bundle dump --force --no-upgrade --all --file="$HOME/.config/homebrew/Brewfile" "$@"
}

# Common alias from both files
alias brewinfo='brew leaves | xargs brew desc --eval-all'

# Function from Zephyr plugin
brewdeps() {
  emulate -L zsh; setopt local_options
  local bluify_deps='
    BEGIN { blue = "\033[34m"; reset = "\033[0m" }
          { leaf = $1; $1 = ""; printf "%s%s%s%s\n", leaf, blue, $0, reset}
  '
  brew leaves | xargs brew deps --installed --for-each | awk "$bluify_deps"
}

# Function from your custom file
brewg() {
  local output_file="$HOME/Desktop/brew_dependency_graph.png"
  echo "Generating Homebrew dependency graph..."

  if brew graph --installed --highlight-leaves | fdp -T png -o "$output_file"; then
    echo "Graph saved to: $output_file"
    open "$output_file"
  else
    echo "Error: Failed to generate graph" >&2
    return 1
  fi
}

# =============================================================================
# WRAPPERS & GUARDS
# =============================================================================

# Brew wrapper that updates Brewfile on each install/uninstall (from user config)
if (( $+commands[brew] )); then
  local brew_wrap_file="$(brew --prefix)/etc/brew-wrap"
  if [[ -f "$brew_wrap_file" ]]; then
    source "$brew_wrap_file"

    _post_brewfile_update () {
      echo "Brewfile was updated!"
    }
  fi
  unset brew_wrap_file
fi

# Handle brew on multi-user Apple silicon (from Zephyr plugin)
if [[ "$HOMEBREW_PREFIX" == /opt/homebrew ]]; then
  local _brew_owner
  # Check for GNU coreutils stat vs. BSD stat
  if stat --version &>/dev/null; then
    _brew_owner="$(stat -c "%U" "$HOMEBREW_PREFIX" 2>/dev/null)"
  else
    _brew_owner="$(stat -f "%Su" "$HOMEBREW_PREFIX" 2>/dev/null)"
  fi
  if [[ -n "$_brew_owner" ]] && [[ "$(whoami)" != "$_brew_owner" ]]; then
    alias brew="sudo -Hu '$_brew_owner' brew"
  fi
  unset _brew_owner
fi
