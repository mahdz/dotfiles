# =============================================================================
# homebrew.zsh - Homebrew configuration
# =============================================================================
# This file is sourced by .zshrc and contains Homebrew related configurations.

# Check if brew is installed
command -v brew &> /dev/null || return

# =============================================================================
# ENVIRONMENT VARIABLES & EXPORTS
# =============================================================================

export HOMEBREW_NO_INSECURE_REDIRECT=1  # Prevent insecure redirects
export HOMEBREW_CASK_OPTS="--appdir=/Applications --no-quarantine"
export HOMEBREW_BUNDLE_FILE="${XDG_CONFIG_HOME}/homebrew/Brewfile"
export HOMEBREW_BUNDLE_DUMP_DESCRIBE=1
export HOMEBREW_BREWFILE="${XDG_CONFIG_HOME}/homebrew/Brewfile"
export HOMEBREW_BREWFILE_VSCODE=1

# =============================================================================
# GNU Utilities
# =============================================================================

prepend_to_manpath_if_dir_exists "${HOMEBREW_PREFIX}/share/man"

use_homebrew_installation_for() {
  ! is_directory "${1}" && return

  prepend_to_path_if_dir_exists "${1}/bin"
  prepend_to_path_if_dir_exists "${1}/libexec/bin"
  prepend_to_path_if_dir_exists "${1}/libexec/gnubin"
  # For compilers to find this installation you may need to set:
  prepend_to_ldflags_if_dir_exists "${1}/lib"
  prepend_to_cppflags_if_dir_exists "${1}/include"
  # For pkg-config to find this installation you may need to set:
  prepend_to_pkg_config_path_if_dir_exists "${1}/lib/pkgconfig"
  prepend_to_manpath_if_dir_exists "${1}/libexec/gnuman"
}

# override default curl and use from homebrew installation
use_homebrew_installation_for "${HOMEBREW_PREFIX}/opt/curl"

# zlib - required for installing python via mise
use_homebrew_installation_for "${HOMEBREW_PREFIX}/opt/zlib"

# override default Sqlite3 and use from homebrew installation
use_homebrew_installation_for "${HOMEBREW_PREFIX}/opt/sqlite"

# override default gnu-tar and use from homebrew installation
use_homebrew_installation_for "${HOMEBREW_PREFIX}/opt/gnu-tar"

# override default openssl and use from homebrew installation
local openssl_dir="${HOMEBREW_PREFIX}/opt/openssl@3"
is_directory "${openssl_dir}" && use_homebrew_installation_for "${openssl_dir}" && export RUBY_CONFIGURE_OPTS="--with-openssl-dir=${openssl_dir}"
unset openssl_dir

  # for gbin in "${HOMEBREW_PREFIX}"/opt/*/libexec/gnubin; do PATH=$gbin:$PATH; done
  # unset gbin
  # for gman in "${HOMEBREW_PREFIX}"/opt/*/libexec/gnuman; do MANPATH=$gman:$MANPATH; done
  # unset gman
  # for dir in ${HOMEBREW_PREFIX}/opt/{curl,ruby,readline}/bin; do PATH=$dir:$PATH; done
  # unset dir

  # LDFLAGS="-L${HOMEBREW_PREFIX}/opt/openssl/lib"
  # CPPFLAGS="-I${HOMEBREW_PREFIX}/opt/openssl/include"
  # export PKG_CONFIG_PATH="${HOMEBREW_PREFIX}/opt/openssl/lib/pkgconfig"
  # export HOMEBREW_GIT_PATH="${HOMEBREW_PREFIX}/bin/git"

  # export LDFLAGS="-L${HOMEBREW_PREFIX}/opt/ruby/lib $LDFLAGS"
  # export CPPFLAGS="-I${HOMEBREW_PREFIX}/opt/ruby/include $CPPFLAGS"

# # let zsh sort out formatting and deduplication
typeset -aU path manpath
export PATH MANPATH

# =============================================================================
# ALIAS & FUNCTIONS
# =============================================================================

alias brewup='brew cu --all --interactive --include-mas'
alias bfc='brew file casklist && o Caskfile'
alias brewinfo='brew leaves | xargs brew desc --eval-all'
alias brewg='brew graph --installed --highlight-leaves | fdp -T png -o ~/Desktop/graph.png && open ~/Desktop/graph.png'
alias bbd="brew bundle dump --force --no-upgrade --all --file=$HOME/.config/homebrew/Brewfile"

# Brew wrapper that updates Brewfile on each install/uninstall
if [ -f "${HOMEBREW_PREFIX}/etc/brew-wrap" ];then
  source "${HOMEBREW_PREFIX}/etc/brew-wrap"

  _post_brewfile_update () {
    echo "Brewfile was updated!"
    }
fi
