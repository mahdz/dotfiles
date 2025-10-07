# =============================================================================
# LESS ALIASES AND FUNCTIONS
# =============================================================================

# Less environment variables - remove -X to allow alternate screen buffer
export LESS="-iR --incsearch --use-color --mouse"
export LESSFLAGS="-iR --incsearch --use-color --mouse"

# Configure bat to not leave output on screen
if command -v bat >/dev/null 2>&1; then
    export BAT_PAGER="less -R"
fi

# Useful less aliases
alias -g L='| less'                    # Pipe to less
alias -g LL='2>&1 | less'             # Pipe stdout and stderr to less

# Less with different options
alias lessc='less -S'                  # Don't wrap long lines (chop)
alias lessn='less -N'                  # Show line numbers
alias lesss='less -S -N'               # Both chop and line numbers

# Quick file viewing with syntax highlighting (if bat is available)
if command -v bat >/dev/null 2>&1; then
    alias cless='bat --paging=always'   # Colorized less
    alias preview='bat --paging=always --style=header,grid'
fi

# Less for specific file types
alias jsonless='jq . | less'           # Pretty print JSON and page
alias yamlless='bat -l yaml --paging=always'

# Function to view files with automatic syntax detection
lessview() {
    if command -v bat >/dev/null 2>&1; then
        bat --paging=always "$@"
    else
        less "$@"
    fi
}

# View git log with better formatting in less
alias gitlog='git log --oneline --graph --decorate --color=always | less'
alias gitlogfull='git log --graph --pretty=format:"%C(auto)%h%d %s %C(cyan)(%cr) %C(blue)<%an>%C(reset)" --color=always | less'

# Search through command history and page results
alias histgrep='history | command grep -i'
alias histless='history | less'

# Directory listing with less
alias lsl='ls -la | less'
alias treeless='tree -C | less'        # If you have tree installed
