#!/bin/zsh
# =============================================================================
# LESS AND PAGER CONFIGURATION
# =============================================================================
# ZSH-specific configuration for enhanced file viewing
# Features: syntax highlighting (bat), pagination (less), git integration
#
# Source this file in your .zshrc:
#   source ~/.zsh/less.zsh

# PAGER CONFIGURATION
# =============================================================================
# Configure LESS for improved readability and interaction
# Flags: -iR (ignore case, raw), -F (quit if one screen), --incsearch (search as type)
#        --use-color (colored output), --mouse (mouse support), -x4 (tab width),
#        --status-column (show search status)
#
export LESS_FLAGS="-iR --incsearch --use-color --mouse --quit-if-one-screen -x4 --status-column --wheel-lines=3"
export LESS="$LESS_FLAGS"

# SYNTAX HIGHLIGHTING WITH BAT
# =============================================================================
if command -v bat >/dev/null 2>&1; then
    export BAT_PAGER="less -R"
    alias cless='bat --paging=always'
    alias cpreview='bat --paging=always --style=header,grid'
fi

# PAGER FUNCTIONS
# =============================================================================
# View files with automatic syntax highlighting
# Usage: lessview file.txt
lessview() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: lessview <file> [file2 ...]" >&2
        return 1
    fi

    if command -v bat >/dev/null 2>&1; then
        bat --paging=always "$@"
    else
        less "$@"
    fi
}

# GLOBAL PIPE ALIASES (ZSH)
# =============================================================================
# These global aliases work anywhere in a ZSH command line
alias -g L='| less'                    # Pipe to less
alias -g LL='2>&1 | less'             # Pipe stdout and stderr to less

# LESS VARIANT ALIASES
# =============================================================================
alias less_chop='less -S'              # Don't wrap long lines (chop mode)
alias less_num='less -N'           # Show line numbers
alias less_numchop='less -S -N'           # Both chop and line numbers

# GIT LOG VIEWING
# =============================================================================
if command -v git >/dev/null 2>&1; then
    alias gitlog='git log --oneline --graph --decorate --color=always | less'
    alias gitlog_full='git log --graph --pretty=format:"%C(auto)%h%d %s %C(cyan)(%cr) %C(blue)<%an>%C(reset)" --color=always | less'
fi

# HISTORY AND LISTING ALIASES
# =============================================================================
alias hist_search='history | grep -i'
alias hist_less='history | less'
alias list_less='ls -la | less'

if command -v tree >/dev/null 2>&1; then
    alias tree_less='tree -C | less'
fi

# FILE FORMAT-SPECIFIC VIEWERS
# =============================================================================
if command -v jq >/dev/null 2>&1; then
    alias json_less='jq . | less'
fi

if command -v bat >/dev/null 2>&1; then
    alias yaml_less='bat -l yaml --paging=always'
fi
