# path-optimization.zsh - Comprehensive PATH management
# Based on ZSH Shell Fix notebook recommendations

# Function to optimize PATH with proper ordering and deduplication
optimize_path() {
    # Define the desired PATH order (highest priority first)
    local desired_paths=(
        # User tools (highest priority)
        "$HOME/.local/bin"
        
        # Mise version manager shims
        "$HOME/.local/share/mise/shims"
        
        # Homebrew paths (Apple Silicon)
        "/opt/homebrew/bin"
        "/opt/homebrew/sbin"
        
        # Specialized homebrew tools
        "/opt/homebrew/opt/openssl@3/bin"
        "/opt/homebrew/opt/gnu-tar/libexec/gnubin"
        "/opt/homebrew/opt/gnu-tar/bin"
        "/opt/homebrew/opt/sqlite/bin"
        "/opt/homebrew/opt/curl/bin"
        
        # Language-specific tool directories
        "$HOME/.local/share/npm/bin"
        "$HOME/bin"
        "$HOME/.config/vscode"
        
        # System paths (lower priority but still important)
        "/usr/local/bin"
        "/System/Cryptexes/App/usr/bin"
        "/usr/bin"
        "/bin"
        "/usr/sbin"
        "/sbin"
        
        # Development tool paths
        "$HOME/Developer/repos/id774/scripts"
        
        # Special application paths
        "/Applications/Privileges.app/Contents/MacOS"
        
        # System cryptex paths (usually at the end)
        "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin"
        "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin"
        "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin"
    )
    
    # Build new PATH by checking each directory exists
    local new_path=""
    local dir
    
    for dir in "${desired_paths[@]}"; do
        if [[ -d "$dir" ]]; then
            # Add to new_path if not already present
            if [[ ":$new_path:" != *":$dir:"* ]]; then
                new_path="${new_path:+$new_path:}$dir"
            fi
        fi
    done
    
    # Add any remaining directories from current PATH that we missed
    local current_dir
    IFS=':' read -A current_path_array <<< "$PATH"
    for current_dir in "${current_path_array[@]}"; do
        if [[ -d "$current_dir" && ":$new_path:" != *":$current_dir:"* ]]; then
            new_path="${new_path:+$new_path:}$current_dir"
        fi
    done
    
    # Export the optimized PATH
    export PATH="$new_path"
    
    # Use Zsh's typeset -U to deduplicate (belt and suspenders approach)
    typeset -gU path
}

# Function to display PATH analysis
path_analysis() {
    echo "🛤️  PATH Analysis:"
    echo "   Total entries: $(echo $PATH | tr ':' '\n' | wc -l | xargs)"
    
    echo -e "\n   📊 Path breakdown:"
    printf '%s\n' ${PATH//:/$'\n'} | nl | while read -r num dir; do
        if [[ -d "$dir" ]]; then
            printf "   %2d. ✅ %s\n" "$num" "$dir"
        else
            printf "   %2d. ❌ %s (missing)\n" "$num" "$dir"
        fi
    done
    
    # Check for duplicates
    local duplicates=$(printf '%s\n' ${PATH//:/$'\n'} | sort | uniq -d | wc -l | xargs)
    if [[ $duplicates -eq 0 ]]; then
        echo -e "\n   ✅ No duplicates found"
    else
        echo -e "\n   ⚠️  $duplicates duplicates found:"
        printf '%s\n' ${PATH//:/$'\n'} | sort | uniq -d | sed 's/^/      /'
    fi
}

# Function to benchmark PATH lookup performance
path_benchmark() {
    echo "⚡ PATH Performance Benchmark:"
    
    local test_commands=("python" "node" "git" "brew" "mise" "zsh")
    local cmd
    
    for cmd in "${test_commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            local timing=$(time (for i in {1..100}; do which "$cmd" >/dev/null 2>&1; done) 2>&1 | grep real | awk '{print $2}')
            printf "   %s: %s (100 lookups)\n" "$cmd" "${timing:-N/A}"
        else
            printf "   %s: not found\n" "$cmd"
        fi
    done
}

# Auto-optimize PATH when this file is sourced
# Only optimize if PATH has more than 15 entries or if FORCE_PATH_OPTIMIZATION is set
if [[ ${#${PATH//:/ }} -gt 15 || -n "$FORCE_PATH_OPTIMIZATION" ]]; then
    optimize_path
fi

# Make functions available globally in zsh
# Note: In zsh, functions are automatically available in the current shell
# For subshells, we can use 'typeset -f' or ensure they're defined in the right scope

# Create aliases for convenience
alias path-opt="optimize_path"
alias path-info="path_analysis"  
alias path-bench="path_benchmark"

# Debug function
path_debug() {
    echo "🔍 PATH Debug Information:"
    echo "   Current PATH entry count: $(echo $PATH | tr ':' '\n' | wc -l | xargs)"
    echo "   ZDOTDIR: $ZDOTDIR"
    echo "   mise shims directory: $HOME/.local/share/mise/shims"
    echo "   mise shims exists: $([[ -d "$HOME/.local/share/mise/shims" ]] && echo "yes" || echo "no")"
    echo "   Homebrew prefix: $(/opt/homebrew/bin/brew --prefix 2>/dev/null || echo "not found")"
    
    echo -e "\n   Priority paths check:"
    local priority_paths=("$HOME/.local/bin" "$HOME/.local/share/mise/shims" "/opt/homebrew/bin")
    local path_pos
    for priority_path in "${priority_paths[@]}"; do
        path_pos=$(printf '%s\n' ${PATH//:/$'\n'} | grep -n "^${priority_path}$" | cut -d: -f1)
        printf "   %s: position %s\n" "$priority_path" "${path_pos:-not found}"
    done
}

alias path-debug="path_debug"
