#!/usr/bin/env zsh
# Custom mise plugin that properly handles shims
# Overrides the OMZ mise plugin

if (( ! $+commands[mise] )); then
  return
fi

# Remove mise shims from PATH (they're added in .zprofile for non-interactive shells)
# In interactive shells, we want mise activate to add real tool paths instead
path=("${(@)path:#*mise/shims}")

# Load mise hooks (adds real tool paths dynamically)
eval "$(mise activate zsh)"

# If the completion file doesn't exist yet, we need to autoload it and
# bind it to `mise`. Otherwise, compinit will have already done that.
if [[ ! -f "$ZSH_CACHE_DIR/completions/_mise" ]]; then
  typeset -g -A _comps
  autoload -Uz _mise
  _comps[mise]=_mise
fi

# Generate and load mise completion (synchronous to avoid race conditions)
mise completion zsh >| "$ZSH_CACHE_DIR/completions/_mise"
