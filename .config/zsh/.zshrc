#!/usr/bin/env zsh
# .zshrc - Interactive shell configuration

# ============================================================================
# PROFILING (optional)
# ============================================================================

[[ "$ZPROFRC" -ne 1 ]] || zmodload zsh/zprof
alias zprofrc="ZPROFRC=1 zsh"

# Set PATH and HOMEBREW_PREFIX
# source "$ZDOTDIR/lib/path.zsh"

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================
# Load .shellrc for utility functions (interactive shells only)
if [[ -r "$XDG_CONFIG_HOME/shell/shellrc" ]]; then
  source "$XDG_CONFIG_HOME/shell/shellrc"
fi

# Add custom completions
fpath=(${ZDOTDIR:-$HOME/.config/zsh}/completions $fpath)

# Lazy-load (autoload) Zsh function files from a directory.
ZFUNCDIR=${ZDOTDIR:-$HOME/.config/zsh}/functions
fpath=($ZFUNCDIR $fpath)
autoload -Uz $ZFUNCDIR/*(.:t)

# ============================================================================
# ZSH CUSTOM PLUGINS
# ============================================================================
# Set Zsh location vars.
ZSH_CONFIG_DIR="${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}"
ZSH_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh"
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p $ZSH_CONFIG_DIR $ZSH_DATA_DIR $ZSH_CACHE_DIR

export ZSH_CUSTOM="${ZSH_CUSTOM:-${ZDOTDIR}/custom}"

# Set essential options
setopt EXTENDED_GLOB INTERACTIVE_COMMENTS

# ============================================================================
# COMPLETIONS
# ============================================================================
# Add custom completions
fpath=($ZSH_CONFIG_DIR/completions $fpath)

# ============================================================================
# ANTIDOTE PLUGIN LOADING
# ============================================================================

# Set any zstyles you might use for configuration.
[[ -r $ZSH_CONFIG_DIR/.zstyles ]] && source $ZSH_CONFIG_DIR/.zstyles

# Load things from lib/
for _zlib in $ZDOTDIR/lib/*.zsh(N); do
  source "$_zlib"
done
unset _zlib

# ============================================================================
# WRAP UP
# ============================================================================
# Never start in the root file system.
[[ "$PWD" != "/" ]] || cd

# Finish profiling by calling zprof.
[[ "$ZPROFRC" -eq 1 ]] && zprof
[[ -v ZPROFRC ]] && unset ZPROFRC

# Always return success
true
