#!/bin/bash

set -euo pipefail  # Exit on error, undefined vars, pipe failures
IFS=$'\n\t'        # Safer word splitting

# Script metadata
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Configuration
readonly VIDEO_DIR="
${1:?Error: VIDEO_DIR argument required}"
readonly THRESHOLD="
${2:-75}"
readonly TEMP_DIR="
${TMPDIR:-/tmp}/$(basename "$SCRIPT_NAME")_$$"
readonly EXACT_DUPS_FILE="
${TEMP_DIR}/exact_dups.json"
readonly SIMILAR_VIDS_FILE="
${TEMP_DIR}/similar_vids.json"

# Logging functions
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$SCRIPT_NAME] INFO: $*" >&2
}

error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$SCRIPT_NAME] ERROR: $*" >&2
    return 1
}

# Cleanup on exit
cleanup() {
    local exit_code=$?
    if [[ -d "$TEMP_DIR" ]]; then
        log "Cleaning up temporary directory: $TEMP_DIR"
        rm -rf "$TEMP_DIR"
    fi
    return "$exit_code"
}
trap cleanup EXIT

# Usage function
usage() {
    echo "Usage: $SCRIPT_NAME VIDEO_DIR [THRESHOLD]"
    echo "  VIDEO_DIR: Directory to scan for videos"
    echo "  THRESHOLD: Similarity threshold (default: 75)"
    exit 1
}

# Validation
validate_input() {
    # Check if directory exists
    if [[ ! -d "$VIDEO_DIR" ]]; then
        error "Directory not found: $VIDEO_DIR"
        return 1
    fi

    # Check if readable
    if [[ ! -r "$VIDEO_DIR" ]]; then
        error "Directory not readable: $VIDEO_DIR"
        return 1
    fi

    # Validate threshold is numeric and in reasonable range
    if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]] || (( THRESHOLD < 0 || THRESHOLD > 100 )); then
        error "THRESHOLD must be numeric between 0-100, got: $THRESHOLD"
        return 1
    fi

    # Check if czkawka_cli is available
    if ! command -v czkawka_cli &> /dev/null; then
        error "czkawka_cli not found. Install from: https://github.com/qarmin/czkawka"
        return 1
    fi
}

# Main execution
main() {
    validate_input || exit 1

    mkdir -p "$TEMP_DIR"
    log "Scanning for duplicate videos in: $VIDEO_DIR"
    log "Similarity threshold: $THRESHOLD%"

    if [[ -e "$EXACT_DUPS_FILE" || -e "$SIMILAR_VIDS_FILE" ]]; then
        read -p "Output files exist. Overwrite? (y/n): " choice
        [[ "$choice" != [Yy] ]] && exit 1
    fi

    log "Finding exact duplicates using BLAKE3 hash..."
    if ! czkawka_cli duplicate-files -d "$VIDEO_DIR" \
        --hash blake3 \
        -o "$EXACT_DUPS_FILE"; then
        error "Failed to scan for exact duplicates"
        return 1
    fi

    log "Finding similar videos with $THRESHOLD% similarity threshold..."
    if ! czkawka_cli similar-videos -d "$VIDEO_DIR" \
        --similarity "$THRESHOLD" \
        -o "$SIMILAR_VIDS_FILE"; then
        error "Failed to scan for similar videos"
        return 1
    fi

    # Report results
    log "Scan completed successfully!"
    log "Exact duplicates: $EXACT_DUPS_FILE"
    log "Similar videos: $SIMILAR_VIDS_FILE"
    
    # Show summary if files have content
    if [[ -s "$EXACT_DUPS_FILE" ]]; then
        local count
        count=$(jq '. | length' "$EXACT_DUPS_FILE" 2>/dev/null || echo "?")
        log "Found duplicate groups in exact matches: $count"
    else
        log "No exact duplicates found"
    fi

    if [[ -s "$SIMILAR_VIDS_FILE" ]]; then
        local count
        count=$(jq '. | length' "$SIMILAR_VIDS_FILE" 2>/dev/null || echo "?")
        log "Found similar video groups: $count"
    else
        log "No similar videos found"
    fi

    echo ""
    echo "⚠️  Review results before deleting:"
    echo "   cat '$EXACT_DUPS_FILE'"
    echo "   cat '$SIMILAR_VIDS_FILE'"
    echo ""
    echo "Note: Results will be deleted when this script exits."
}

main "$@"
