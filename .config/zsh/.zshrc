#!/usr/bin/env zsh
# =============================================================================
# ~/.zshrc - Interactive shell configuration
# =============================================================================

# -----------------------------
# Profiling (optional)
# -----------------------------

# Load zprof first if we need to profile.
[[ "$ZPROFRC" -ne 1 ]] || zmodload zsh/zprof
alias zprofrc="ZPROFRC=1 zsh"

# Security and privacy settings
#umask 022                               # Set default file permissions


# -----------------------------
# Mise initialization
# -----------------------------
# Initialize mise for full functionality (shell hooks, auto-switching, etc.)
# This supersedes the shim-only approach and enables advanced features
# if command -v mise >/dev/null 2>&1; then
#   eval "$(mise activate zsh)"
# else
#  export PATH="$HOME/.local/share/mise/shims:$PATH"
# fi

# -----------------------------
# Cache directories
# -----------------------------
__zsh_data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh"
__zsh_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p "$__zsh_data_dir" "$__zsh_cache_dir"

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

# Path to your Oh My Zsh installation.
export ZSH_CUSTOM=${ZDOTDIR:-$HOME/.config/zsh}/custom
export DISABLE_AUTO_TITLE=true

# Create an amazing Zsh config using antidote plugins.# Load things from lib.
for zlib in $ZDOTDIR/lib/*.zsh; do
  source $zlib
done
unset zlib

# Aliases
# [[ -r ${ZDOTDIR:-$HOME}/.zaliases ]] && source ${ZDOTDIR:-$HOME}/.zaliases

# =============================================================================
# WRAP UP
# =============================================================================

# Disable fancy prompts for VSCode
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    export TERM=xterm-256color
    export PAGER="/bin/cat"
    PS1="%n@%m %1~ %# "
fi

# Never start in the root file system.
[[ "$PWD" != "/" ]] || cd

# remove empty components to avoid '::' ending up + resulting in './' being in $PATH, etc
path=( "${path[@]:#}" )
fpath=( "${fpath[@]:#}" )
manpath=( "${manpath[@]:#}" )

# remove duplicates from some env vars
typeset -gU cdpath CPPFLAGS cppflags FPATH fpath infopath LDFLAGS ldflags MANPATH manpath PATH path PKG_CONFIG_PAT

# Finish profiling by calling zprof.
[[ "$ZPROFRC" -eq 1 ]] && zprof
[[ -v ZPROFRC ]] && unset ZPROFRC

# Always return success
true
