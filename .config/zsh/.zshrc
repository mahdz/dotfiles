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
[[ ${ZPROFRC:-0} -eq 0 ]] || zmodload zsh/zprof
alias zprofrc="ZPROFRC=1 zsh"

# =============================================================================
# ENVIRONMENT VARIABLES & EXPORTS
# =============================================================================

# Security and privacy settings
export LESSHISTFILE=/dev/null           # Disable less history file
#umask 022                               # Set default file permissions
export SOPS_AGE_KEY_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/mise/age.txt"  # SOPS age key file

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

# =============================================================================
# ZSTYLES
# =============================================================================

[[ -r ${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}/.zstyles ]] && source ${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}/.zstyles

# =============================================================================
# THEME
# =============================================================================

#typeset -ga ZSH_THEME
# zstyle -a ':zephyr:plugin:prompt' theme ZSH_THEME # || ZSH_THEME=(starship)

# =============================================================================
# ZSH PLUGINS [ANTIDOTE]
# =============================================================================

# Set helpers for antidote.
function is-not-warpterm   { [[ "$TERM_PROGRAM" != Warp* ]] }
function is-theme-starship { [[ "$ZSH_THEME" == starship* ]] }

######

# Be sure to set any supplemental completions directories before compinit is run.
# fpath=(${__zsh_cache_dir}/completions(-/FN) $fpath) # Commented out due to shellcheck parsing issues with Zsh glob qualifiers
fpath=(${__zsh_cache_dir}/completions $fpath) # Alternative for shellcheck, might need adjustment if original behavior is critical

export ZSH_CUSTOM=${ZSH_CUSTOM:-$ZDOTDIR}

source ${HOMEBREW_PREFIX:-/opt/homebrew}/opt/antidote/share/antidote/antidote.zsh

antidote load

# =============================================================================
# PROMPT
# =============================================================================

# Uncomment to manually set your prompt, or let Zephyr do it automatically in the
# zshrc-post hook. Note that some prompts like powerlevel10k may not work well
# with post_zshrc.
#setopt prompt_subst transient_rprompt
#autoload -Uz promptinit && promptinit
#prompt "$ZSH_THEME[@]"

# =============================================================================
# WRAP UP
# =============================================================================

# Never start in the root file system. Looking at you, Zed.
[[ "$PWD" != "/" ]] || cd

# Manually call post_zshrc to bypass the hook
(( $+functions[run_post_zshrc] )) && run_post_zshrc

# remove empty components to avoid '::' ending up + resulting in './' being in $PATH, etc
path=( "${path[@]:#}" )
fpath=( "${fpath[@]:#}" )
#infopath=( "${infopath[@]:#}" )
manpath=( "${manpath[@]:#}" )

# remove duplicates from some env vars
typeset -gU cdpath CPPFLAGS cppflags FPATH fpath infopath LDFLAGS ldflags MANPATH manpath PATH path PKG_CONFIG_PATH

# export XDG_DATA_DIRS="$XDG_DATA_HOME:/opt/homebrew/share:$XDG_DATA_DIRS"

# Finish profiling by calling zprof.
[[ "$ZPROFRC" -eq 1 ]] && zprof
[[ -v ZPROFRC ]] && unset ZPROFRC

# Always return success
true
