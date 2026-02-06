#!/bin/zsh
# =============================================================================
# PATH Debug Diagnostics (Refactored)
# =============================================================================
# Uses utilities from ~/.shellrc for consistency and maintainability

# =============================================================================
# SETUP
# =============================================================================

# Store PATH entries once to avoid repeated processing
path_entries=($(echo "$PATH" | tr ':' '\n'))

# =============================================================================
# DIAGNOSTICS
# =============================================================================

echo ""
echo "$(blue "═══════════════════════════════════════════════════════════════")"
echo "$(blue "ZSH PATH DIAGNOSTICS")"
echo "$(blue "═══════════════════════════════════════════════════════════════")"
echo ""

# 1. Current PATH
section_header "Current PATH (in order)"
echo "$PATH" | tr ':' '\n' | nl
echo ""

# 1. Current PATH
echo "${YELLOW}1. Current PATH (in order):${NC}"
echo "$PATH" | tr ':' '\n' | nl
echo ""


# 2. PATH Entry Count & Duplicates
section_header "PATH Statistics"
local path_count=${#path_entries[@]}
local unique_entries=($(printf '%s\n' "${path_entries[@]}" | sort -u))
local unique_count=${#unique_entries[@]}
local duplicate_count=$((path_count - unique_count))

echo "   Total entries: $path_count"
echo "   Unique entries: $unique_count"
echo "   Duplicates: $duplicate_count"

if [[ $duplicate_count -gt 0 ]]; then
    warn "PATH contains duplicates!"
else
    success "No duplicate PATH entries"
fi
echo ""

# 3. Missing Directories in PATH
section_header "Missing Directories (not on filesystem)"
local missing=0
local missing_dirs=()

for dir in "${path_entries[@]}"; do
    if ! is_directory "$dir"; then
        missing=$((missing + 1))
        missing_dirs+=("$dir")
    fi
done

if [[ $missing -eq 0 ]]; then
    success "All PATH entries exist"
else
    warn "Found $missing missing entries:"
    for dir in "${missing_dirs[@]}"; do
        echo "      - $dir"
    done
fi
echo ""

# 4. Critical Tool Locations
section_header "Critical Tool Locations"
local tools=("node" "npm" "python" "git" "mise")
local missing_tools=0

for tool in "${tools[@]}"; do
    if have "$tool"; then
        local location=$(command -v "$tool")
        echo "   $(green "✅") $tool: $location"
    else
        echo "   $(red "❌") $tool: NOT FOUND"
        missing_tools=$((missing_tools + 1))
    fi
done
echo ""

# 5. Mise Shims
section_header "Mise Shims Configuration"
local mise_shims="$HOME/.local/share/mise/shims"

if is_directory "$mise_shims"; then
    echo "   $(green "✅") Directory exists: $mise_shims"
    local shim_count=$(ls -1 "$mise_shims" 2>/dev/null | wc -l)
    echo "   Available shims: $shim_count"

    # Check if mise shims are in PATH
    if [[ ":$PATH:" == *":$mise_shims:"* ]]; then
        local position=$(echo "$PATH" | tr ':' '\n' | nl | grep "$mise_shims" | awk '{print $1}')
        echo "   $(green "✅") In PATH at position: $position"
    else
        warn "Mise shims NOT in PATH - this is a problem!"
    fi
else
    warn "Mise shims directory NOT found: $mise_shims"
fi
echo ""

# 6. Homebrew Configuration
section_header "Homebrew Configuration"
local brew_prefix="${HOMEBREW_PREFIX:-/opt/homebrew}"
local brew_bin="$brew_prefix/bin"

echo "   HOMEBREW_PREFIX: ${HOMEBREW_PREFIX:-not set}"

if is_executable "$brew_prefix/bin/brew"; then
    echo "   $(green "✅") Brew executable found"
    if [[ ":$PATH:" == *":$brew_bin:"* ]]; then
        echo "   $(green "✅") Brew bin in PATH"
    else
        warn "Brew bin NOT in PATH"
    fi
else
    warn "Brew executable not found at $brew_prefix/bin/brew"
fi
echo ""

# 7. XDG Compliance
section_header "XDG Directory Configuration"
echo "   XDG_CONFIG_HOME: ${XDG_CONFIG_HOME:-not set}"
echo "   XDG_DATA_HOME: ${XDG_DATA_HOME:-not set}"
echo "   XDG_CACHE_HOME: ${XDG_CACHE_HOME:-not set}"

# Validate XDG directories exist
if is_non_zero_string "$XDG_CONFIG_HOME" && ! is_directory "$XDG_CONFIG_HOME"; then
    warn "XDG_CONFIG_HOME is set but directory doesn't exist: $XDG_CONFIG_HOME"
fi
if is_non_zero_string "$XDG_DATA_HOME" && ! is_directory "$XDG_DATA_HOME"; then
    warn "XDG_DATA_HOME is set but directory doesn't exist: $XDG_DATA_HOME"
fi
echo ""

# 8. Plugin Load Order Issue Detection
section_header "Plugin Configuration Check"

if is_non_zero_string "$_DOTFILES_PLUGIN_LOADED"; then
    echo "   $(green "✅") Dotfiles plugin: LOADED"
else
    warn "Dotfiles plugin: not loaded yet (may be deferred)"
fi

# Check for environment functions
if (( $+functions[env] )); then
    echo "   $(green "✅") Environment functions: available"
else
    warn "Environment functions: not yet available"
fi

# Check for homebrew plugin
if is_non_zero_string "$HOMEBREW_PREFIX"; then
    echo "   $(green "✅") Homebrew plugin: loaded"
else
    warn "Homebrew plugin: may not be loaded"
fi
echo ""

# 9. Recommendations
section_header "Recommendations"
local has_recommendations=0

if [[ $duplicate_count -gt 0 ]]; then
    warn "Remove duplicate PATH entries"
    has_recommendations=1
fi

if [[ $missing -gt 0 ]]; then
    warn "Remove non-existent directories from PATH"
    has_recommendations=1
fi

if ! is_directory "$mise_shims"; then
    warn "Install/configure mise shims"
    has_recommendations=1
fi

if [[ $missing_tools -gt 0 ]]; then
    warn "$missing_tools critical tool(s) not found"
    has_recommendations=1
fi

if [[ $has_recommendations -eq 0 ]]; then
    success "No issues detected!"
fi

echo ""
blue "═══════════════════════════════════════════════════════════════"
