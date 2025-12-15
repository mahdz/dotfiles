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

# -----------------------------
# Completions
# -----------------------------
typeset -U fpath
fpath=(${ZDOTDIR:-$HOME/.config/zsh}/completions $fpath)

# =============================================================================
# PATH Setup Before Plugins
# =============================================================================
# Ensure path array includes all necessary directories before plugins load
# The zephyr environment plugin will rebuild this, but it needs a complete
# starting point so that /bin and /usr/bin aren't lost
typeset -gU path
path=(
  $HOME/bin(N)
  $HOME/.local/bin(N)
  ${HOMEBREW_PREFIX:-/opt/homebrew}/bin(N)
  ${HOMEBREW_PREFIX:-/opt/homebrew}/sbin(N)
  /usr/local/bin
  /usr/local/sbin
  /usr/bin
  /bin
  /usr/sbin
  /sbin
  $path
)

# -----------------------------
# Antidote plugin loading
# -----------------------------

# Set any zstyles you might use for configuration.
[[ ! -f ${ZDOTDIR:-$HOME}/.zstyles ]] || source ${ZDOTDIR:-$HOME}/.zstyles

# Force rehash so commands are found from PATH
rehash

# # Path to your Oh My Zsh installation.
export ZSH_CUSTOM=${ZDOTDIR:-$HOME/.config/zsh}/custom
export DISABLE_AUTO_TITLE=true

# Create an amazing Zsh config using antidote plugins.# Load things from lib.
for zlib in $ZDOTDIR/lib/*.zsh; do
  source $zlib
done
unset zlib

# Note: antidote is already sourced and loaded by lib/antidote.zsh

# Aliases
# [[ -r ${ZDOTDIR:-$HOME}/.zaliases ]] && source ${ZDOTDIR:-$HOME}/.zaliases

# =============================================================================
# WRAP UP
# =============================================================================

# Never start in the root file system.
[[ "$PWD" != "/" ]] || cd

# remove empty components to avoid '::' ending up + resulting in './' being in $PATH, etc
path=( "${path[@]:#}" )
fpath=( "${fpath[@]:#}" )
manpath=( "${manpath[@]:#}" )

# System paths should already be in PATH from .zshenv
# This is just a safety check in case something removed them

# remove duplicates from some env vars
typeset -gU cdpath CPPFLAGS cppflags FPATH fpath infopath LDFLAGS ldflags MANPATH manpath PATH path PKG_CONFIG_PAT

# Finish profiling by calling zprof.
[[ "$ZPROFRC" -eq 1 ]] && zprof
[[ -v ZPROFRC ]] && unset ZPROFRC

# Always return success
true

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/mh/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/mh/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/mh/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/mh/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

