#!/usr/bin/env bash
set -euo pipefail

# macOS Application Unquarantine Script
# Usage: ./unquarantine_apps.sh [--dry-run] [-v|--verbose]

readonly QUARANTINE_ATTR="com.apple.quarantine"
readonly TARGET_DIR="/Applications"

DRY_RUN=false
VERBOSE=false
failed_apps=()
success_count=0

# Parse arguments
while (($#)); do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    -v|--verbose) VERBOSE=true ;;
    *) { printf 'Unknown option: %s\n' "$1"; exit 1; } >&2 ;;
  esac
  shift
done

# Check dependencies
for cmd in mdfind xattr; do
  command -v "$cmd" >/dev/null 2>&1 || { printf '%s not found\n' "$cmd"; exit 1; } >&2
done

[[ -d $TARGET_DIR ]] || { printf 'Target directory not found: %s\n' "$TARGET_DIR"; exit 1; } >&2

[[ $DRY_RUN == true ]] && printf '==> DRY RUN MODE\n\n'

# Process quarantined apps
while IFS= read -r -d '' app; do
  [[ $VERBOSE == true ]] && printf 'Processing: %s\n' "$app"
  
  if ! xattr -p "$QUARANTINE_ATTR" "$app" >/dev/null 2>&1; then
    [[ $VERBOSE == true ]] && printf 'Attribute not set; skipping\n'
    continue
  fi
  
  if [[ $DRY_RUN == true ]]; then
    printf 'Would remove %s\n' "$app"
  elif xattr -d "$QUARANTINE_ATTR" "$app" 2>/dev/null; then
    [[ $VERBOSE == true ]] && printf 'Removed\n'
  else
    printf '\n⚠️  FAILED: %s\n' "$app" >&2
    failed_apps+=("$app")
    continue
  fi
  
  ((success_count++))
done < <(mdfind -onlyin "$TARGET_DIR" 'kMDItemWhereFroms != ""' -0)

# Report results
printf '\n%s\n' "$(printf '=%.0s' {1..50})"
printf 'Processed: %d apps\n' "$success_count"
if ((${#failed_apps[@]})); then
  printf '\n⚠️  FAILED: %d apps\n' "${#failed_apps[@]}" >&2
  printf '%s\n' "${failed_apps[@]}" >&2
  printf '%s\n' "$(printf '=%.0s' {1..50})"
  exit 1
fi
printf '%s\n' "$(printf '=%.0s' {1..50})"
