#!/bin/bash
# security-utils.sh: Reusable security functions for dotfiles scripts

# Input validation functions
validate_github_user() {
    local user="$1"
    [[ "$user" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$ ]] || {
        echo "Invalid GitHub username: $user" >&2
        return 1
    }
}

validate_path() {
    local path="$1"
    local base_dir="${2:-$HOME}"

    # Resolve path and check if it's within allowed directory
    local resolved_path
    resolved_path=$(realpath "$path" 2>/dev/null) || {
        echo "Invalid path: $path" >&2
        return 1
    }

    [[ "$resolved_path" == "$base_dir"* ]] || {
        echo "Path outside allowed directory: $resolved_path" >&2
        return 1
    }
}

# Secure temporary file creation
create_secure_temp() {
    local temp_file
    temp_file=$(mktemp -t "$(basename "$0").XXXXXX")
    chmod 600 "$temp_file"
    echo "$temp_file"
}

# Safe command execution
safe_exec() {
    local -a cmd=("$@")

    # Log command being executed (without sensitive data)
    echo "Executing: ${cmd[0]}" >&2

    # Execute with error handling
    if ! "${cmd[@]}"; then
        echo "Command failed: ${cmd[0]}" >&2
        return 1
    fi
}

# Sanitize user input
sanitize_input() {
    local input="$1"
    local allowed_chars="${2:-a-zA-Z0-9._-}"

    # Remove any characters not in allowed set
    echo "$input" | sed "s/[^$allowed_chars]//g"
}

# Check if running with unnecessary privileges
check_privileges() {
    if [[ $EUID -eq 0 ]]; then
        echo "WARNING: Running as root - this may not be necessary" >&2
        read -p "Continue? (y/N): " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] || exit 1
    fi
}
