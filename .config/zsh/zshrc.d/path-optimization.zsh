# path-optimization.zsh - Comprehensive PATH management
# Ensures mise shims and user tools take priority over system paths
# Features: auto-optimization, caching, verification, and debugging

return  # Skip sourcing if already loaded

# ============================================================================
# PATH OPTIMIZATION FUNCTION
# ============================================================================

# Optimize PATH with proper ordering and deduplication
# Runs on every shell startup to ensure consistent priority
optimize_path() {
    # Define the desired PATH order (highest priority first)
    # This ensures mise shims and user tools are found before system paths
    local desired_paths=(
        # User tools (highest priority)
        "$HOME/bin"
        "$HOME/.local/bin"

        # Mise version manager shims - must come early
        "$HOME/.local/share/mise/shims"

        # Homebrew paths (Apple Silicon)
        "/opt/homebrew/bin"
        "/opt/homebrew/sbin"

        # Language-specific tool directories
        "$HOME/.config/vscode"

        # System paths (lower priority)
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

    local new_path="" dir

    # Add desired paths that exist and aren't duplicates
    for dir in "${desired_paths[@]}"; do
        [[ -d "$dir" && ":$new_path:" != *":$dir:"* ]] && new_path="${new_path:+$new_path:}$dir"
    done

    # Add any remaining paths from current PATH that weren't in desired list
    # This preserves any custom paths added by other tools
    IFS=':' read -A current_paths <<< "$PATH"
    for dir in "${current_paths[@]}"; do
        [[ -d "$dir" && ":$new_path:" != *":$dir:"* ]] && new_path="${new_path:+$new_path:}$dir"
    done

    # Export the optimized PATH
    export PATH="$new_path"
}

# ============================================================================
# PATH CACHING (Optional optimization to skip recalculation)
# ============================================================================

# Cache file location for PATH optimization
_PATH_CACHE_FILE="$HOME/.cache/zsh/path_cache"

# Check if PATH has changed since last optimization
# Uses simple file comparison instead of hashing for reliability
_should_optimize_path() {
    local cached_path

    # Check if cache exists and matches current PATH
    if [[ -f "$_PATH_CACHE_FILE" ]]; then
        cached_path=$(cat "$_PATH_CACHE_FILE" 2>/dev/null)
        [[ "$PATH" == "$cached_path" ]] && return 1  # No need to optimize
    fi

    return 0  # Need to optimize
}

# Update PATH cache after optimization
# Stores the current PATH for comparison on next startup
_update_path_cache() {
    local cache_dir="${_PATH_CACHE_FILE%/*}"
    mkdir -p "$cache_dir" 2>/dev/null
    echo "$PATH" >> "$_PATH_CACHE_FILE" 2>/dev/null
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Display comprehensive PATH analysis with statistics
# Shows entry count, missing directories, and duplicates
path_analysis() {
    local total=0 missing=0 dupes=0 dir
    local -a path_array

    # Count entries and missing directories
    IFS=':' read -A path_array <<< "$PATH"
    total=${#path_array[@]}

    for dir in "${path_array[@]}"; do
        [[ ! -d "$dir" ]] && ((missing++))
    done

    # Count duplicates
    dupes=$(printf '%s\n' "${path_array[@]}" | sort | uniq -d | wc -l)

    echo "🛤️  PATH Analysis: $total entries, $missing missing, $dupes duplicates"
    echo ""

    # Display each PATH entry with status
    local num=1
    for dir in "${path_array[@]}"; do
        [[ -d "$dir" ]] && echo "   $num. ✅ $dir" || echo "   $num. ❌ $dir"
        ((num++))
    done
}

# Show which version of a command is being used
# Useful for debugging when multiple versions exist (e.g., mise vs Homebrew)
path_which() {
    [[ $# -eq 0 ]] && { echo "Usage: path_which <command>"; return 1 }

    local result=$(command -v "$1" 2>/dev/null)
    [[ -n "$result" ]] && echo "✅ $1: $result" || { echo "❌ $1: not found"; return 1 }
}

# Verify all critical tools are accessible
# Checks for node, npx, npm, and mise specifically
path_verify() {
    echo "🔧 Verifying critical tools:"

    local critical_tools=("node" "npx" "npm" "mise")
    local all_found=true cmd

    for cmd in "${critical_tools[@]}"; do
        if command -v "$cmd" > /dev/null 2>&1; then
            echo "   ✅ $cmd"
        else
            echo "   ❌ $cmd missing"
            all_found=false
        fi
    done

    # Return success only if all tools found
    [[ "$all_found" == true ]] && return 0 || return 1
}

# Debug PATH issues and show current configuration
# Displays entry count, tool availability, and priority order
path_debug() {
    local pos=1 target_pos=0 dir
    local -a path_array

    echo "🔍 PATH Debug Information:"
    echo "   Entries: $(echo "$PATH" | tr ':' '\n' | wc -l)"
    echo "   ZDOTDIR: $ZDOTDIR"
    echo "   Mise shims: $([[ -d "$HOME/.local/share/mise/shims" ]] && echo "✅ exists" || echo "❌ missing")"
    echo "   Homebrew: $([[ -x /opt/homebrew/bin/brew ]] && echo "✅ available" || echo "❌ missing")"
    echo "   Cache file: $([[ -f "$_PATH_CACHE_FILE" ]] && echo "✅ exists" || echo "❌ missing")"

    echo ""
    echo "   Priority order (should be 1, 2, 3):"

    # Parse PATH and find positions of critical paths
    IFS=':' read -A path_array <<< "$PATH"

    local critical_paths=(
        "$HOME/.local/bin"
        "$HOME/.local/share/mise/shims"
        "/opt/homebrew/bin"
    )

    for target in "${critical_paths[@]}"; do
        target_pos=0
        pos=1
        for dir in "${path_array[@]}"; do
            [[ "$dir" == "$target" ]] && { target_pos=$pos; break; }
            ((pos++))
        done

        local name="${target##*/}"
        [[ $target_pos -eq 0 ]] && echo "   ⚠️  $name: not found" || echo "   ✅ $name: position $target_pos"
    done
}

# ============================================================================
# COMMAND ALIASES
# ============================================================================

# Convenient aliases for all PATH management functions
alias path-opt="optimize_path"        # Manually re-optimize PATH
alias path-info="path_analysis"       # Show PATH analysis
alias path-which="path_which"         # Show which version of a command is used
alias path-verify="path_verify"       # Verify critical tools are available
alias path-debug="path_debug"         # Debug PATH issues

# ============================================================================
# INITIALIZATION
# ============================================================================

# Auto-optimize PATH on shell startup
# This ensures mise shims and user tools always take priority
if _should_optimize_path; then
    optimize_path
    _update_path_cache
fi

# Clean up temporary variables
unset _PATH_CACHE_FILE
