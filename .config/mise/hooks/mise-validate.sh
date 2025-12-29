#!/usr/bin/env bash
set -euo pipefail

# mise-validate.sh
# Basic post-install validation for mise-managed toolchain.
# Exits non-zero on failures so mise can surface errors.
#
# Usage: mise runs this after installs; you can also run it manually:
#    ~/.config/mise/hooks/mise-validate.sh

# Helpers
info()  { printf '\033[1;34m[info]\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m[warn]\033[0m %s\n' "$*"; }
error() { printf '\033[1;31m[error]\033[0m %s\n' "$*"; }

# Time-limited command wrapper
run_with_timeout() {
    local timeout_secs=$1; shift
    if command -v timeout >/dev/null 2>&1; then
        timeout "${timeout_secs}s" "$@"
    else
        # fallback: run command without timeout if coreutils timeout not present
        "$@"
    fi
}

info "Validating core runtime versions and key CLIs..."

# Core runtimes
run_with_timeout 10 node --version >/dev/null 2>&1 || { error "node not found or not executable"; exit 2; }
info "node: $(node --version)"

run_with_timeout 10 npm --version >/dev/null 2>&1 || { error "npm not found or not executable"; exit 3; }
info "npm: $(npm --version)"

run_with_timeout 10 python --version >/dev/null 2>&1 || { error "python not found or not executable"; exit 4; }
info "python: $(python --version 2>&1)"

# pipx (if configured/expected)
if command -v pipx >/dev/null 2>&1; then
    info "pipx detected: $(pipx --version 2>/dev/null || echo 'version unknown')"
else
    warn "pipx not found; pipx-managed tools may be unavailable"
fi

# Check core CLIs — fail on missing critical ones
critical_clis=(pre-commit rg shellcheck)
for cmd in "${critical_clis[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        info "$cmd: $( "$cmd" --version 2>&1 | head -n 1 )"
    else
        error "Critical CLI missing: $cmd"
        exit 5
    fi
done

# Check selected pipx-installed tools (non-fatal warnings if missing)
pipx_tools=(black ruff yt-dlp)
for pkg in "${pipx_tools[@]}"; do
    if command -v pipx >/dev/null 2>&1 && pipx list | grep -q "$pkg" 2>/dev/null; then
        info "pipx: $pkg installed"
    else
        warn "pipx: $pkg not found (may be optional or pending install)"
    fi
done

# Quick smoke tests for Node & npm packages (best-effort, non-fatal)
if command -v npx >/dev/null 2>&1; then
    info "npx available"
else
    warn "npx not found; some node package checks will be skipped"
fi

# Verify Antidote presence (if you use it for plugin management)
if command -v antidote >/dev/null 2>&1; then
    info "antidote: $(antidote --version 2>/dev/null || echo 'version unknown')"
else
    warn "antidote not found; Zsh plugin management via Antidote may not be available"
fi

# Validate mise-specific expectations (files/dirs)
CONFIG_FILE="${HOME}/.config/mise/config.toml"
if [ -f "$CONFIG_FILE" ]; then
    info "Found mise config: $CONFIG_FILE"
else
    warn "Mise config not found at $CONFIG_FILE"
fi

# Optional: check secrets dir presence and permissions (non-fatal)
if [ -d "${SECRETS_DIR:=$HOME/.config/security}" ]; then
    info "Secrets dir exists: $SECRETS_DIR"
    # Check restrictive permissions
    perms=$(stat -f "%A" "${SECRETS_DIR:=$HOME/.config/security}" 2>/dev/null || stat -c "%a" "${SECRETS_DIR:=$HOME/.config/security}" 2>/dev/null || echo "unknown")
    info "Secrets dir perms: $perms"
else
    warn "Secrets dir not present: $SECRETS_DIR"
fi

info "Running lightweight CLI smoke checks..."

# Example smoke: check that pre-commit runs --version without prompting
if pre-commit --version >/dev/null 2>&1; then
    info "pre-commit ok"
else
    warn "pre-commit --version failed; may still be functional but verify manually"
fi

# ripgrep smoke
if rg --version >/dev/null 2>&1; then
    info "ripgrep (rg) ok"
else
    warn "rg --version failed"
fi

# shellcheck smoke
if shellcheck --version >/dev/null 2>&1; then
    info "shellcheck ok"
else
    warn "shellcheck --version failed"
fi

info "All checks completed."

# Exit 0 for success; the script already exits non-zero on critical failures above
exit 0
