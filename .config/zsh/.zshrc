#!/usr/bin/env zsh
# =============================================================================
# ~/.zshrc - Interactive Zsh Shell Configuration
# =============================================================================
# This file is sourced for interactive shells (including login shells after ~/.zprofile)
# Configures interactive shell features: completions, aliases, prompt, and tool integrations

# =============================================================================
# PROFILING
# =============================================================================

# Load zprof first if we need to profile.
[[ "$ZPROFRC" -ne 1 ]] || zmodload zsh/zprof
alias zprofrc="ZPROFRC=1 zsh"

# =============================================================================
# ENVIRONMENT VARIABLES & EXPORTS
# =============================================================================

# Security and privacy settings
#umask 022                               # Set default file permissions

# Ensure mise shim directory is at the front of PATH
if [[ -d "$HOME/.local/share/mise/shims" && ":$PATH:" != *":$HOME/.local/share/mise/shims:"* ]]; then
  export PATH="$HOME/.local/share/mise/shims:$PATH"
fi

# =============================================================================
# DIRS
# =============================================================================

# ZSH Directories
__zsh_config_dir="${ZDOTDIR:-$HOME/.config/zsh}"
__zsh_data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh"
__zsh_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
for zdir in $__zsh_data_dir $__zsh_cache_dir; do
  if [[ ! -d "$zdir" ]]; then
    mkdir -p "$zdir"
  fi
done
unset zdir

# Path to your Oh My Zsh installation.
ZSH_CUSTOM=${ZDOTDIR:-$HOME/.config/zsh}/custom
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"

# =============================================================================
# COMPLETIONS
# =============================================================================

ZSH_COMPDUMP="$ZSH_CACHE_DIR/.zcompdump"
ZSH_COMPCACHE="$__zsh_cache_dir/.zcompcache"
#DISABLE_AUTO_UPDATE=true
#DISABLE_UPDATE_PROMPT=true
#DISABLE_LS_COLORS=true
#DISABLE_AUTO_TITLE=true
#ENABLE_CORRECTION=true

# Create cache directories if they don't exist
for _cache_dir in "${ZSH_COMPDUMP:h}" "$ZSH_COMPCACHE"; do
  [[ -d "$_cache_dir" ]] || mkdir -p "$_cache_dir"
done
unset _cache_dir

# Add custom completions
#fpath=("$ZSH_CACHE_DIR/completions" $fpath)
fpath=(${ZDOTDIR:-$HOME/.config/zsh}/completions $fpath)

# =============================================================================
# ZSH PLUGINS [ANTIDOTE]
# =============================================================================

# Lazy-load (autoload) Zsh function files from a directory.
# ZFUNCDIR=${ZDOTDIR:-$HOME/.config/zsh}/functions
# fpath=($ZFUNCDIR $fpath)
# autoload -Uz $ZFUNCDIR/*(.:t)

# Set any zstyles you might use for configuration.
[[ ! -f ${ZDOTDIR:-$HOME}/.zstyles ]] || source ${ZDOTDIR:-$HOME}/.zstyles

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
    export PAGER=cat
    PS1="%n@%m %1~ %# "
fi

# Never start in the root file system. Looking at you, Zed.
[[ "$PWD" != "/" ]] || cd

# remove empty components to avoid '::' ending up + resulting in './' being in $PATH, etc
path=( "${path[@]:#}" )
fpath=( "${fpath[@]:#}" )
#infopath=( "${infopath[@]:#}" )
manpath=( "${manpath[@]:#}" )

# remove duplicates from some env vars
typeset -gU cdpath CPPFLAGS cppflags FPATH fpath infopath LDFLAGS ldflags MANPATH manpath PATH path PKG_CONFIG_PAT

# Finish profiling by calling zprof.
[[ "$ZPROFRC" -eq 1 ]] && zprof
[[ -v ZPROFRC ]] && unset ZPROFRC

# Always return success
true
