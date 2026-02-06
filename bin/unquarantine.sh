#!/usr/bin/env bash
set -euo pipefail

# macOS Application Unquarantine Script
# Removes com.apple.quarantine attributes from applications in /Applications
# Features: Dry-run mode, auto-quit running apps, retry logic, detailed error reporting
# Note: To use with sudo, provide full path: sudo /Users/mh/bin/unquarantine.sh

readonly QUARANTINE_ATTR="com.apple.quarantine"
readonly TARGET_DIR="/Applications"
readonly MAX_RETRIES=3
readonly RETRY_DELAY=1

DRY_RUN=false
VERBOSE=true
failed_apps=()
success_count=0
skipped_count=0

# Display usage information
show_usage() {
  cat << 'EOF'
Usage: unquarantine.sh [OPTIONS]

Remove macOS quarantine attributes from /Applications

OPTIONS:
  --dry-run             Show what would be done without making changes
  -v, --verbose         Show detailed progress information
  -h, --help            Display this help message

EXAMPLES:
  unquarantine.sh --dry-run --verbose
  unquarantine.sh

REQUIREMENTS:
  - macOS system with xattr and mdfind commands
  - Write access to /Applications or use sudo

EOF
}

# Parse arguments
while (($#)); do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    -v|--verbose) VERBOSE=true ;;
    -h|--help) show_usage; exit 0 ;;
    *) { printf 'Unknown option: %s\n' "$1"; exit 1; } >&2 ;;
  esac
  shift
done

# Check dependencies
for cmd in mdfind xattr; do
  command -v "$cmd" >/dev/null 2>&1 || { printf '%s not found\n' "$cmd"; exit 1; } >&2
done

[[ -d $TARGET_DIR ]] || { printf 'Target directory not found: %s\n' "$TARGET_DIR"; exit 1; } >&2

[[ $DRY_RUN == true ]] && printf '[DRY RUN] No changes will be made\n\n'

# Function to quit running app
quit_running_app() {
  local app="$1"
  local app_name
  app_name="${app##*/}"    # Extract basename
  app_name="${app_name%.app}"  # Remove .app extension for process matching
  
  # Use -x for exact match to avoid matching unrelated processes
  if pgrep -x "$app_name" >/dev/null 2>&1; then
    [[ $VERBOSE == true ]] && printf '[*] Quitting running app: %s\n' "$app_name"
    killall "$app_name" 2>/dev/null || true
    sleep "$RETRY_DELAY"
  fi
}

# Function to remove quarantine attribute with retry logic
remove_quarantine() {
  local app="$1"
  local attempt=1
  local error_msg=""
  
  while [[ $attempt -le $MAX_RETRIES ]]; do
    # Attempt removal and capture any error message
    if error_msg=$(xattr -d "$QUARANTINE_ATTR" "$app" 2>&1); then
      return 0
    fi
    
    if [[ $attempt -lt $MAX_RETRIES ]]; then
      [[ $VERBOSE == true ]] && printf '  [retry %d/%d] %s\n' "$attempt" "$MAX_RETRIES" "$app"
      sleep "$RETRY_DELAY"
    fi
    ((attempt++))
  done
  
  # Report failure with captured error message
  printf '[!] FAILED: %s\n' "$app" >&2
  [[ -n "$error_msg" ]] && printf '    Error: %s\n' "$error_msg" >&2
  return 1
}

# Process quarantined apps
while IFS= read -r -d '' app; do
  [[ $VERBOSE == true ]] && printf 'Processing: %s\n' "$app"
  
  # Check if quarantine attribute exists
  if ! xattr -p "$QUARANTINE_ATTR" "$app" >/dev/null 2>&1; then
    [[ $VERBOSE == true ]] && printf '  [skip] Attribute not set\n'
    ((skipped_count++))
    continue
  fi
  
  if [[ $DRY_RUN == true ]]; then
    printf '[dry-run] Would remove quarantine from: %s\n' "$app"
    ((success_count++))
  else
    # Try to quit the app if it's running
    quit_running_app "$app"
    
    # Attempt to remove quarantine with retries
    if remove_quarantine "$app"; then
      [[ $VERBOSE == true ]] && printf '  [ok] Removed quarantine\n'
      ((success_count++))
    else
      failed_apps+=("$app")
    fi
  fi
done < <(mdfind -onlyin "$TARGET_DIR" 'kMDItemWhereFroms != ""' -0)

# Report results
printf '\n%s\n' "$(printf '=%.0s' {1..50})"
printf 'Processed: %d apps\n' "$success_count"
if [[ $skipped_count -gt 0 ]]; then
  printf 'Skipped: %d apps (no quarantine attribute)\n' "$skipped_count"
fi

if [[ $success_count -eq 0 && $skipped_count -eq 0 ]]; then
  printf '[info] No quarantined apps found in %s\n' "$TARGET_DIR"
fi

if ((${#failed_apps[@]})); then
  printf '\n[!] FAILED: %d apps\n' "${#failed_apps[@]}" >&2
  printf '%s\n' "${failed_apps[@]}" >&2
  printf '%s\n' "$(printf '=%.0s' {1..50})" >&2
  exit 1
fi

printf '%s\n' "$(printf '=%.0s' {1..50})"
printf '[ok] All apps processed successfully!\n'
