#!/usr/bin/env bash
#
# DRIVE AUDIT SCRIPT v2.1 (IMPROVED)
# Purpose: Generate a detailed tree of your Google Drive with shortcut mapping
# Usage: ./audit_gdrive.sh [--deep | --quick | --size-analysis | --full | --help]
#
# Author: Developer
# Version: 2.1
# Date: 2026-01-26
#

set -euo pipefail

###############################################################################
# GLOBAL CONFIGURATION
###############################################################################

declare -g SCRIPT_NAME="$(basename "$0")"
declare -g SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
declare -g SCRIPT_VERSION="2.1"

# Tree traversal settings
declare -g TREE_LEVEL=2
declare -g DISPLAY_LIMIT=15  # Number of top folders to show in size analysis

# File processing settings
declare -g FILELIMIT=20
declare -g CHARSET="utf8"
declare -g IGNORE_PATTERNS=".git|.obsidian|.DS_Store|node_modules|.trash"
declare -g SHORTCUT_EXT="*.gshortcut"

# Execution flags
declare -g FULL_AUDIT=false
declare -g VERBOSE=false
declare -g DRY_RUN=false

# Dependency cache (populated by check_dependencies)
declare -gA CMD_AVAILABLE=()

# Output formatting
declare -g SECTION_SEP="═════════════════════════════════════════"
declare -g SUBSECTION_SEP="─────────────────────────────────────────"
declare -g TIMESTAMP_FORMAT="%Y-%m-%d %H:%M:%S"

# Known folder IDs mapping
declare -gA KNOWN_IDS=(
    ["1YadA4n3u6C5rHx8dmZCVJM0hw4YX2n0W"]="00_VAULT"
    ["1rQ2yB5DPQt_oudB1mz3ERk1NQyY5FOBW"]="02_WORK"
    ["1mDH9eNmNuqvz8wMPkNy8NboRopu62Nd7"]="Sony Pictures Entertainment"
    ["1cgWJ_7Rq8lypXg4y8p093eIUB7vwoGHe"]="TBWA Media Arts Lab"
    ["1NhqmJ7i6FJm7fq_i-Ri4az_Z7tWr-2vj"]="TBWA NY"
    ["1nvw-Kjm05ymRhcjgKrQDcVFjvyTlaPOW"]="PortfolioReady_ALL"
)

# Execution metrics
declare -gi AUDIT_SHORTCUTS_FOUND=0
declare -gi AUDIT_START_TIME=0
declare -gi AUDIT_END_TIME=0

###############################################################################
# ERROR HANDLING & CLEANUP
###############################################################################

trap 'cleanup_on_exit' EXIT
trap 'error_handler $? $LINENO' ERR

cleanup_on_exit() {
    local exit_code=$?
    [[ $exit_code -eq 0 ]] && return 0
    log "ERROR" "Script failed with exit code $exit_code"
}

error_handler() {
    local exit_code=$1
    local line_number=$2
    log "ERROR" "Script error at line $line_number (exit code: $exit_code)"
}

###############################################################################
# LOGGING FUNCTIONS
###############################################################################

log() {
    local level="$1"
    shift
    local timestamp
    timestamp=$(date +"${TIMESTAMP_FORMAT}")
    
    case "$level" in
        DEBUG)
            [[ "$VERBOSE" == "true" ]] && echo "[${timestamp}] [DEBUG] $*" >&2
            ;;
        INFO)
            echo "[${timestamp}] [INFO] $*" >&2
            ;;
        WARN)
            echo "[${timestamp}] [WARN] $*" >&2
            ;;
        ERROR)
            echo "[${timestamp}] [ERROR] $*" >&2
            ;;
        *)
            echo "[${timestamp}] $*" >&2
            ;;
    esac
}

###############################################################################
# DEPENDENCY MANAGEMENT
###############################################################################

# Check if all required commands are available
# Usage: check_dependencies
# Returns: 0 if critical deps available, 1 if too many missing
check_dependencies() {
    log "DEBUG" "Checking dependencies..."
    
    local missing_count=0
    local critical_missing=0
    
    # Critical: must have at least grep and find
    local critical_commands=("find" "grep")
    local optional_commands=("eza" "du" "sort")
    
    # Check critical commands
    for cmd in "${critical_commands[@]}"; do
        if command -v "$cmd" &> /dev/null; then
            CMD_AVAILABLE[$cmd]=true
            log "DEBUG" "✓ Found: $cmd"
        else
            CMD_AVAILABLE[$cmd]=false
            log "WARN" "Critical command not found: $cmd"
            ((critical_missing++))
        fi
    done
    
    # Check optional commands
    for cmd in "${optional_commands[@]}"; do
        if command -v "$cmd" &> /dev/null; then
            CMD_AVAILABLE[$cmd]=true
            log "DEBUG" "✓ Found: $cmd"
        else
            CMD_AVAILABLE[$cmd]=false
            log "WARN" "Optional command not found: $cmd (some features disabled)"
            ((missing_count++))
        fi
    done
    
    # Fail if critical commands missing
    if (( critical_missing > 0 )); then
        log "ERROR" "Missing $critical_missing critical command(s)"
        return 1
    fi
    
    return 0
}

# Check if a specific command is available
# Usage: has_command "eza"
# Returns: 0 if available, 1 otherwise
has_command() {
    local cmd="$1"
    [[ "${CMD_AVAILABLE[$cmd]:-false}" == "true" ]]
}

###############################################################################
# OUTPUT FORMATTING FUNCTIONS
###############################################################################

# Print major section header
# Usage: print_header "DIRECTORY STRUCTURE"
print_header() {
    echo ""
    echo "$SECTION_SEP"
    echo "  $1"
    echo "$SECTION_SEP"
}

# Print subsection header
# Usage: print_subheader "Contents & Structure"
print_subheader() {
    echo ""
    echo "$SUBSECTION_SEP"
    echo "  $1"
    echo "$SUBSECTION_SEP"
}

# Print informational message
# Usage: print_info "Processing completed"
print_info() {
    echo "ℹ $1"
}

# Print success message
# Usage: print_success "Found 42 shortcuts"
print_success() {
    echo "✓ $1"
}

# Print error message (non-fatal)
# Usage: print_error "Feature unavailable"
print_error() {
    echo "✗ $1" >&2
}

###############################################################################
# SHORTCUT HANDLING FUNCTIONS
###############################################################################

# Extract Google Drive ID from a .gshortcut file
# Usage: extract_gdrive_id "/path/to/file.gshortcut"
# Returns: Drive ID or "UNKNOWN"
extract_gdrive_id() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        log "WARN" "Shortcut file not found: $file"
        echo "UNKNOWN"
        return 1
    fi
    
    # grep pattern: id=<alphanumeric,underscore,hyphen>
    local drive_id
    drive_id=$(grep -o 'id=[a-zA-Z0-9_-]*' "$file" 2>/dev/null | sed 's/id=//' || echo "UNKNOWN")
    
    echo "$drive_id"
}

# Resolve shortcut target name from Drive ID
# Usage: resolve_shortcut_target "1YadA4n3u6C5rHx8dmZCVJM0hw4YX2n0W"
# Returns: Human-readable folder name or the Drive ID if unknown
resolve_shortcut_target() {
    local file_id="$1"
    
    # Return known name or fallback to ID
    echo "${KNOWN_IDS[$file_id]:-$file_id}"
}

###############################################################################
# AUDIT FUNCTIONS
###############################################################################

# Audit directory structure using tree view
# Usage: audit_directory_structure
audit_directory_structure() {
    print_header "DIRECTORY STRUCTURE (Level $TREE_LEVEL)"
    
    if has_command "eza"; then
        log "DEBUG" "Using eza for tree view"
        if [[ "$DRY_RUN" == "true" ]]; then
            echo "[DRY RUN] Would execute: eza --tree --level $TREE_LEVEL --icons --long --total-size --group-directories-first --ignore-glob $IGNORE_PATTERNS"
        else
            eza --tree --level "$TREE_LEVEL" --icons --long \
                --total-size --group-directories-first \
                --ignore-glob "$IGNORE_PATTERNS" 2>/dev/null || {
                log "WARN" "eza command failed, falling back to find"
                audit_directory_structure_fallback
            }
        fi
    else
        log "DEBUG" "eza not available, using find fallback"
        audit_directory_structure_fallback
    fi
}

# Fallback directory structure view using find
audit_directory_structure_fallback() {
    # Use find to display directory structure
    if has_command "find"; then
        find . -maxdepth "$TREE_LEVEL" -type f ! -path '*/.*' 2>/dev/null | \
            head -50 | \
            sort
    else
        print_error "No suitable tree command available (eza/find)"
    fi
}

# Audit Google Drive shortcuts and their targets
# Usage: audit_shortcuts
audit_shortcuts() {
    print_header "GOOGLE SHORTCUT MAPPING"
    
    if ! has_command "find"; then
        print_error "find command required for shortcut audit"
        return 1
    fi
    
    local shortcut_count=0
    local shortcut_file
    
    log "DEBUG" "Searching for shortcut files matching: $SHORTCUT_EXT"
    
    # Use -print0 to handle filenames with special characters safely
    while IFS= read -r -d '' shortcut_file; do
        ((shortcut_count++))
        
        local gdrive_id
        gdrive_id=$(extract_gdrive_id "$shortcut_file")
        
        local target
        target=$(resolve_shortcut_target "$gdrive_id")
        
        echo ""
        echo "  [$shortcut_count] Shortcut: $(basename "$shortcut_file")"
        echo "      Path: $shortcut_file"
        echo "      Target ID: $gdrive_id"
        echo "      Target Name: $target"
        
        # Limit output for verbosity
        if (( shortcut_count >= FILELIMIT )); then
            log "DEBUG" "Reached file limit ($FILELIMIT), stopping shortcut enumeration"
            break
        fi
        
    done < <(find . -name "$SHORTCUT_EXT" -not -path '*/.*' -print0 2>/dev/null)
    
    # Store metrics
    AUDIT_SHORTCUTS_FOUND=$shortcut_count
    
    echo ""
    if (( shortcut_count == 0 )); then
        print_info "No shortcuts found"
    else
        print_success "Total shortcuts found: $shortcut_count"
    fi
}

# Audit storage distribution across top-level folders
# Usage: audit_size_distribution
audit_size_distribution() {
    print_header "STORAGE ANALYSIS (Top $DISPLAY_LIMIT Folders by Size)"
    
    if ! has_command "du"; then
        print_error "du command required for size analysis"
        return 1
    fi
    
    if ! has_command "sort"; then
        print_error "sort command required for size analysis"
        return 1
    fi
    
    log "DEBUG" "Analyzing directory sizes..."
    
    echo ""
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would execute: du -sh * | sort -hr | head -$DISPLAY_LIMIT"
    else
        # Safely handle du output with error checking
        local output
        output=$(du -sh * 2>/dev/null | sort -hr | head -"$DISPLAY_LIMIT") || {
            log "WARN" "Size analysis encountered errors"
            return 1
        }
        
        echo "$output" | awk '{printf "  %8s  %s\n", $1, $2}'
        
        echo ""
        echo "  Total Drive Usage:"
        du -sh . 2>/dev/null | awk '{print "    " $1}'
    fi
}

# Deep dive into 02_WORK folder structure
# Usage: audit_02_work
audit_02_work() {
    print_header "02_WORK FOLDER DEEP DIVE"
    print_subheader "Contents & Structure"
    
    if ! has_command "eza"; then
        print_error "eza command required for this view"
        return 1
    fi
    
    if [[ ! -d "./02_WORK" ]]; then
        print_error "Folder not found: ./02_WORK"
        return 1
    fi
    
    log "DEBUG" "Analyzing 02_WORK structure..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would execute: eza --tree --level 2 --icons --long --group-directories-first ./02_WORK"
    else
        eza --tree --level 2 --icons --long --group-directories-first \
            --ignore-glob "$IGNORE_PATTERNS" ./02_WORK 2>/dev/null || {
            print_error "Failed to analyze 02_WORK folder"
            return 1
        }
    fi
}

# Deep dive into 00_VAULT folder structure
# Usage: audit_00_vault
audit_00_vault() {
    print_header "00_VAULT FOLDER DEEP DIVE"
    print_subheader "System Architecture & Organization"
    
    if ! has_command "eza"; then
        print_error "eza command required for this view"
        return 1
    fi
    
    if [[ ! -d "./00_VAULT" ]]; then
        print_error "Folder not found: ./00_VAULT"
        return 1
    fi
    
    log "DEBUG" "Analyzing 00_VAULT structure..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would execute: eza --tree --level 2 --icons --long --group-directories-first ./00_VAULT"
    else
        eza --tree --level 2 --icons --long --group-directories-first \
            --ignore-glob "$IGNORE_PATTERNS" ./00_VAULT 2>/dev/null || {
            print_error "Failed to analyze 00_VAULT folder"
            return 1
        }
    fi
}

###############################################################################
# REPORTING FUNCTIONS
###############################################################################

# Generate execution summary
# Usage: audit_summary
audit_summary() {
    print_header "AUDIT SUMMARY"
    
    local execution_time=0
    if (( AUDIT_END_TIME > AUDIT_START_TIME )); then
        execution_time=$(( AUDIT_END_TIME - AUDIT_START_TIME ))
    fi
    
    echo ""
    echo "  Execution Details:"
    echo "    • Start Time: $(date -d @"$AUDIT_START_TIME" +"${TIMESTAMP_FORMAT}" 2>/dev/null || echo "N/A")"
    echo "    • End Time: $(date -d @"$AUDIT_END_TIME" +"${TIMESTAMP_FORMAT}" 2>/dev/null || echo "N/A")"
    echo "    • Duration: ${execution_time}s ($(( execution_time / 60 ))m $(( execution_time % 60 ))s)"
    echo ""
    echo "  Audit Results:"
    echo "    • Shortcuts Found: $AUDIT_SHORTCUTS_FOUND"
    echo "    • Tree Depth Analyzed: $TREE_LEVEL levels"
    echo ""
    echo "  System Information:"
    echo "    • Bash Version: $BASH_VERSION"
    echo "    • Script Version: $SCRIPT_VERSION"
    echo ""
}

# Display usage information
# Usage: show_help
show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

DESCRIPTION:
  Generate a detailed tree of your Google Drive with shortcut mapping,
  storage analysis, and folder structure audits.

OPTIONS:
  --deep              Increase tree depth to level 3 (default: level 2)
  --quick             Quick scan with level 1 tree only
  --size-analysis     Show storage distribution (top $DISPLAY_LIMIT folders only)
  --full              Run all available audits (comprehensive)
  --verbose           Enable verbose logging (debug output)
  --dry-run           Simulate execution without making changes
  --help, -h          Display this help message

EXAMPLES:
  # Standard audit (directory structure + shortcuts)
  $SCRIPT_NAME

  # Deep audit with folder analysis
  $SCRIPT_NAME --deep

  # Size analysis only
  $SCRIPT_NAME --size-analysis

  # Comprehensive audit with all features
  $SCRIPT_NAME --full --verbose

  # Dry run to see what would happen
  $SCRIPT_NAME --full --dry-run

ENVIRONMENT VARIABLES:
  VERBOSE=1           Enable verbose mode
  DRY_RUN=1           Enable dry-run mode

REQUIREMENTS:
  Critical: find, grep
  Optional: eza (for enhanced tree output), du, sort (for size analysis)

EOF
}

###############################################################################
# ARGUMENT PARSING
###############################################################################

# Parse command-line arguments
# Usage: parse_arguments "$@"
parse_arguments() {
    while (( $# > 0 )); do
        case "$1" in
            --deep)
                TREE_LEVEL=3
                log "DEBUG" "Tree level set to 3 (deep)"
                shift
                ;;
            --quick)
                TREE_LEVEL=1
                log "DEBUG" "Tree level set to 1 (quick)"
                shift
                ;;
            --size-analysis)
                FULL_AUDIT=false
                audit_size_distribution
                exit 0
                ;;
            --full)
                FULL_AUDIT=true
                log "DEBUG" "Full audit mode enabled"
                shift
                ;;
            --verbose|-v)
                VERBOSE=true
                log "DEBUG" "Verbose mode enabled"
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                log "DEBUG" "Dry-run mode enabled"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log "ERROR" "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

###############################################################################
# MAIN EXECUTION
###############################################################################

main() {
    # Initialize
    AUDIT_START_TIME=$(date +%s)
    
    echo ""
    echo "🔍 Google Drive Audit Script v${SCRIPT_VERSION}"
    echo "📅 Generated: $(date +"${TIMESTAMP_FORMAT}")"
    echo ""
    
    # Validate environment
    if ! check_dependencies; then
        log "ERROR" "Critical dependencies missing. Exiting."
        exit 1
    fi
    
    # Parse arguments
    parse_arguments "$@"
    
    # Run standard audits
    audit_directory_structure
    audit_shortcuts
    
    # Run extended audits if requested
    if [[ "$FULL_AUDIT" == "true" ]]; then
        log "DEBUG" "Running full audit suite..."
        audit_size_distribution
        audit_02_work
        audit_00_vault
    fi
    
    # Finalize
    AUDIT_END_TIME=$(date +%s)
    audit_summary
    
    print_header "AUDIT COMPLETE"
    echo ""
    echo "  For detailed help: $SCRIPT_NAME --help"
    echo "  For comprehensive audit: $SCRIPT_NAME --full"
    echo ""
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
