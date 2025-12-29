#!/bin/zsh
# =============================================================================
# PATH Debug Diagnostics
# =============================================================================
# Source this file to diagnose PATH issues:
#   source ~/.config/zsh/lib/path-debug.zsh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BLUE}ZSH PATH DIAGNOSTICS${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# 1. Current PATH
echo "${YELLOW}1. Current PATH (in order):${NC}"
echo "$PATH" | tr ':' '\n' | nl
echo ""

# 2. PATH Entry Count & Duplicates
echo "${YELLOW}2. PATH Statistics:${NC}"
local path_count=$(echo "$PATH" | tr ':' '\n' | wc -l)
local unique_count=$(echo "$PATH" | tr ':' '\n' | sort -u | wc -l)
local duplicate_count=$((path_count - unique_count))
echo "   Total entries: $path_count"
echo "   Unique entries: $unique_count"
echo "   Duplicates: $duplicate_count"
[[ $duplicate_count -gt 0 ]] && echo "   ${RED}⚠️  WARNING: PATH contains duplicates!${NC}"
echo ""

# 3. Missing Directories in PATH
echo "${YELLOW}3. Missing Directories (not on filesystem):${NC}"
local missing=0
local -a missing_dirs
for dir in $(echo "$PATH" | tr ':' '\n'); do
    if [[ ! -d "$dir" ]]; then
        missing=$((missing + 1))
        missing_dirs+=("$dir")
    fi
done

if [[ $missing -eq 0 ]]; then
    echo "   ${GREEN}✅ All PATH entries exist${NC}"
else
    echo "   ${RED}❌ Found $missing missing entries:${NC}"
    for dir in "${missing_dirs[@]}"; do
        echo "      - $dir"
    done
fi
echo ""

# 4. Critical Tool Locations
echo "${YELLOW}4. Critical Tool Locations:${NC}"
local tools=("node" "npm" "python" "git" "mise")
for tool in "${tools[@]}"; do
    if command -v "$tool" &>/dev/null; then
        local location=$(command -v "$tool")
        echo "   ${GREEN}✅${NC} $tool: $location"
    else
        echo "   ${RED}❌${NC} $tool: NOT FOUND"
    fi
done
echo ""

# 5. Mise Shims
echo "${YELLOW}5. Mise Shims Configuration:${NC}"
local mise_shims="$HOME/.local/share/mise/shims"
if [[ -d "$mise_shims" ]]; then
    echo "   ${GREEN}✅${NC} Directory exists: $mise_shims"
    local shim_count=$(ls -1 "$mise_shims" 2>/dev/null | wc -l)
    echo "   Available shims: $shim_count"
    
    # Check if mise shims are in PATH
    if [[ ":$PATH:" == *":$mise_shims:"* ]]; then
        local position=$(echo "$PATH" | tr ':' '\n' | nl | grep "$mise_shims" | awk '{print $1}')
        echo "   ${GREEN}✅${NC} In PATH at position: $position"
    else
        echo "   ${RED}❌${NC} NOT in PATH - this is a problem!"
    fi
else
    echo "   ${RED}❌${NC} Directory NOT found: $mise_shims"
fi
echo ""

# 6. Homebrew Configuration
echo "${YELLOW}6. Homebrew Configuration:${NC}"
echo "   HOMEBREW_PREFIX: ${HOMEBREW_PREFIX:-not set}"
if [[ -x "${HOMEBREW_PREFIX:-/opt/homebrew}/bin/brew" ]]; then
    echo "   ${GREEN}✅${NC} Brew executable found"
    local brew_bin="${HOMEBREW_PREFIX:-/opt/homebrew}/bin"
    if [[ ":$PATH:" == *":$brew_bin:"* ]]; then
        echo "   ${GREEN}✅${NC} Brew bin in PATH"
    else
        echo "   ${RED}⚠️  WARNING: Brew bin NOT in PATH${NC}"
    fi
else
    echo "   ${RED}❌${NC} Brew executable not found"
fi
echo ""

# 7. XDG Compliance
echo "${YELLOW}7. XDG Directory Configuration:${NC}"
echo "   XDG_CONFIG_HOME: ${XDG_CONFIG_HOME:-not set}"
echo "   XDG_DATA_HOME: ${XDG_DATA_HOME:-not set}"
echo "   XDG_CACHE_HOME: ${XDG_CACHE_HOME:-not set}"
echo ""

# 8. Plugin Load Order Issue Detection
echo "${YELLOW}8. Plugin Configuration Check:${NC}"
if [[ -n "$_DOTFILES_PLUGIN_LOADED" ]]; then
    echo "   ${GREEN}✅${NC} Dotfiles plugin: LOADED"
else
    echo "   ⚠️  Dotfiles plugin: not loaded yet (may be deferred)"
fi

# Check for environment plugin
if (( $+functions[env] )); then
    echo "   ${GREEN}✅${NC} Environment functions: available"
else
    echo "   ⚠️  Environment functions: not yet available"
fi

# Check for homebrew plugin
if [[ -n "$HOMEBREW_PREFIX" ]]; then
    echo "   ${GREEN}✅${NC} Homebrew plugin: loaded"
else
    echo "   ⚠️  Homebrew plugin: may not be loaded"
fi
echo ""

# 9. Recommendations
echo "${YELLOW}9. Recommendations:${NC}"
if [[ $duplicate_count -gt 0 ]]; then
    echo "   ${YELLOW}⚠️  Remove duplicate PATH entries${NC}"
fi

if [[ $missing -gt 0 ]]; then
    echo "   ${YELLOW}⚠️  Remove non-existent directories from PATH${NC}"
fi

if [[ ! -d "$mise_shims" ]]; then
    echo "   ${YELLOW}⚠️  Install/configure mise shims${NC}"
fi

echo ""
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
