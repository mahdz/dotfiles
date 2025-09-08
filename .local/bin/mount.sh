#!/usr/bin/env bash
# mount.sh - Full-featured sparsebundle manager using macOS Keychain for password

set -euo pipefail

# --- Configuration ---
# Update this path to your actual sparsebundle location
SPARSEBUNDLE_PATH="${SPARSEBUNDLE_PATH:-/Volumes/SoMannyFiles/MAL.dmg.sparsebundle}"
MOUNT_POINT="/Volumes/MAL"
KEYCHAIN_SERVICE="ThiccBoi"
CONFIG_DIR="$HOME/.cache/mount"
LOG_FILE="$CONFIG_DIR/mount.log"

mkdir -p "$CONFIG_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

log_action() {
  local action="$1"; local status="$2"
  printf '%s - %s: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$action" "$status" >> "$LOG_FILE"
}

is_mounted() {
  mount | grep -q "${MOUNT_POINT}"
}

get_password_from_keychain() {
  security find-generic-password -a "$USER" -s "$KEYCHAIN_SERVICE" -w 2>/dev/null || true
}

prompt_for_password() {
  local pw
  read -r -s -p "Enter password for MAL: " pw
  echo
  echo "$pw"
}

mount_sparsebundle() {
  if is_mounted; then
    echo "✅ MAL is already mounted at $MOUNT_POINT"
    return 0
  fi

  if [[ ! -d "$SPARSEBUNDLE_PATH" ]]; then
    echo "❌ Sparsebundle not found: $SPARSEBUNDLE_PATH" >&2
    log_action "Mount" "BundleNotFound"
    exit 1
  fi

  # Retrieve password (Keychain -> prompt)
  local password
  password=$(get_password_from_keychain)

  if [[ -z "$password" ]]; then
    echo "ℹ️  Password not found in Keychain (service: $KEYCHAIN_SERVICE)."
    password=$(prompt_for_password)
    if [[ -z "$password" ]]; then
      echo "❌ No password provided" >&2
      log_action "Mount" "NoPasswordProvided"
      exit 1
    fi
    # Optionally save to Keychain if user consents
    read -r -p "Save password to Keychain for future use? (y/N): " save
    if [[ "$save" =~ ^[Yy]$ ]]; then
      if security add-generic-password -a "$USER" -s "$KEYCHAIN_SERVICE" -w "$password" -U >/dev/null 2>&1; then
        echo "🔐 Password saved to Keychain (service: $KEYCHAIN_SERVICE)"
      else
        echo "⚠️  Failed to save password to Keychain" >&2
      fi
    fi
  fi

  echo "🔄 Mounting MAL sparsebundle..."
  if hdiutil attach "$SPARSEBUNDLE_PATH" -stdinpass <<< "$password"; then
    echo "✅ Successfully mounted MAL at $MOUNT_POINT"
    log_action "Mount" "Success"
    [[ -d "$MOUNT_POINT" ]] && open "$MOUNT_POINT" || true
  else
    echo "⚠️  Authentication failed with Keychain password."
    # Fallback: prompt once more in case Keychain password is outdated
    password=$(prompt_for_password)
    if hdiutil attach "$SPARSEBUNDLE_PATH" -stdinpass <<< "$password"; then
      echo "✅ Successfully mounted MAL at $MOUNT_POINT"
      log_action "Mount" "SuccessAfterPrompt"
      [[ -d "$MOUNT_POINT" ]] && open "$MOUNT_POINT" || true
      # Offer to update Keychain with the working password
      read -r -p "Update Keychain with this password? (y/N): " update
      if [[ "$update" =~ ^[Yy]$ ]]; then
        if security add-generic-password -a "$USER" -s "$KEYCHAIN_SERVICE" -w "$password" -U >/dev/null 2>&1; then
          echo "🔐 Keychain updated (service: $KEYCHAIN_SERVICE)"
        else
          echo "⚠️  Failed to update Keychain" >&2
        fi
      fi
    else
      echo "❌ Failed to mount MAL (authentication error)" >&2
      log_action "Mount" "FailedAuth"
      exit 1
    fi
  fi
}

unmount_mal() {
  if is_mounted; then
    echo "🔄 Unmounting MAL..."
    if hdiutil detach "$MOUNT_POINT" -quiet; then
      echo "✅ MAL unmounted"
      log_action "Unmount" "Success"
    else
      echo "❌ Failed to unmount MAL" >&2
      log_action "Unmount" "Failed"
      exit 1
    fi
  else
    echo "ℹ️  MAL is not currently mounted"
  fi
}

show_status() {
  if is_mounted; then
    echo "✅ MAL is mounted at $MOUNT_POINT"
  else
    echo "❌ MAL is not mounted"
  fi
}

show_help() {
  cat <<EOF
Usage: $(basename "$0") [command]

Commands:
  mount     Mount the MAL sparsebundle (uses Keychain password)
  unmount   Unmount the MAL volume
  toggle    Toggle between mounted/unmounted
  status    Show current mount status
  logs      Tail the log file
  help      Show this help

Config via environment variables:
  SPARSEBUNDLE_PATH   Path to the .sparsebundle (default: $HOME/MAL.sparsebundle)
  KEYCHAIN_SERVICE    Keychain service name (default: MAL-sparsebundle)
EOF
}

main() {
  local cmd="${1:-mount}"
  case "$cmd" in
    mount)   mount_sparsebundle ;;
    unmount) unmount_mal ;;
    status)  show_status ;;
    toggle)  if is_mounted; then unmount_mal; else mount_sparsebundle; fi ;;
    logs)    tail -f "$LOG_FILE" ;;
    help|-h|--help) show_help ;;
    *) echo "Unknown command: $cmd" >&2; show_help; exit 1 ;;
  esac
}

main "$@"
