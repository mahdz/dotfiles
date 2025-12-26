#!/usr/bin/env zsh
# =============================================================================
# ~/.zshrc - Interactive shell configuration
# =============================================================================

# -----------------------------
# Profiling (optional)
# -----------------------------

# Load zprof first if we need to profile.
[[ "$ZPROFRC" -eq 1 ]] && zmodload zsh/zprof
alias zprofrc="ZPROFRC=1 zsh"

# Ensure utility functions are available
[[ -r "${HOME}/.shellrc" ]] && source "${HOME}/.shellrc"

# Path to your Oh My Zsh installation.
export ZSH_CUSTOM="${ZSH_CUSTOM:-"${ZDOTDIR}/custom"}"

# -----------------------------
# Cache directories
# -----------------------------
__zsh_data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh"
__zsh_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
/bin/mkdir -p "$__zsh_data_dir" "$__zsh_cache_dir"

export ZSH_CACHE_DIR="$__zsh_cache_dir"
export ZSH_COMPDUMP="$__zsh_cache_dir/.zcompdump"
export ZSH_COMPCACHE="$__zsh_cache_dir/.zcompcache"

# -----------------------------
# Completions
# -----------------------------
typeset -U fpath
fpath=(${ZDOTDIR:-$HOME/.config/zsh}/completions $fpath)

# -----------------------------
# Antidote plugin loading
# -----------------------------

# Set any zstyles you might use for configuration.
[[ ! -f ${ZDOTDIR:-$HOME}/.zstyles ]] || source ${ZDOTDIR:-$HOME}/.zstyles

if [[ -d ${ZDOTDIR:-$HOME/.config/zsh}/functions ]]; then
  fpath=( ${ZDOTDIR:-$HOME/.config/zsh}/functions $fpath )
  autoload -Uz load-secrets edit-secrets
fi

# Force rehash so commands are found from PATH
rehash

# Load things from lib.
for zlib in ${ZDOTDIR}/lib/*.zsh(N); do
  source "$zlib"
done
unset zlib

# =============================================================================
# WRAP UP
# =============================================================================

# Never start in the root file system.
[[ "$PWD" != "/" ]] || cd "$HOME"

# remove empty components to avoid '::' ending up + resulting in './' being in $PATH, etc
path=( "${path[@]:#}" )
fpath=( "${fpath[@]:#}" )
manpath=( "${manpath[@]:#}" )

# System paths should already be in PATH from .zshenv
# This is just a safety check in case something removed them

# remove duplicates from some env vars
typeset -gU cdpath CPPFLAGS cppflags FPATH fpath infopath LDFLAGS ldflags MANPATH manpath PATH path PKG_CONFIG_PATH

# Finish profiling by calling zprof.
[[ "$ZPROFRC" -eq 1 ]] && zprof
[[ -v ZPROFRC ]] && unset ZPROFRC

# Always return success
true
