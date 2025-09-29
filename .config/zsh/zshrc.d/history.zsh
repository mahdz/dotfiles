# history: Custom history features complementing Zephyr history plugin
# Provides: aliases, ignore patterns, and ShellHistory.app integration
# Note: Core history configuration is handled by Zephyr history plugin
#

# =============================================================================
# History Configuration Notes
# =============================================================================
# HISTFILE is set by Zephyr to: ${XDG_DATA_HOME}/zsh/zsh_history
# To check current value: echo $HISTFILE
#

unsetopt HIST_REDUCE_BLANKS

# Zephyr defaults: HISTSIZE=20000, SAVEHIST=100000
# We override them here for more history:
export HISTSIZE=120000    # Number of commands stored in memory during session
export SAVEHIST=100000    # Number of commands saved to HISTFILE

# =============================================================================
# History and Search Aliases
# =============================================================================
#unalias hist 2>/dev/null    # Remove any existing hist alias to avoid conflicts
alias h=' hist'             # Lists recent history (Zephyr history plugin)
alias hf=' hist fix -1'     # Fixes last history entry (Zephyr history plugin)
alias h-search=' fc -El 0 | grep' # Searches for a word in terminal history
alias histrg=' history -500 | rg' # Rip grep search recent history
alias hgrep=' fc -El 0 | grep'

# =============================================================================
# History Ignore Configuration
# =============================================================================

IGNORE_COMMANDS=(
  # Directory listing
  #    "ls" "exa" "eza" "lsd" "l" "ll" "la"
  # Directory navigation
  #    "pwd" "cd" "pushd" "popd" "dirs"
  # File operations
  # "cp" "mv" "rm" "touch" "mkdir" "rmdir"
  # Text viewing
  "cat" "less" "more" "head" "tail"
  # System info
  "uname" "hostname" "whoami" "id"
  # Process management
  "ps" "top" "htop"
  # Network
  #    "ping" "ifconfig" "ip" "netstat" "ss"
  # Package management
  #    "brew"
  # Version control
  # "git"
  # Shell built-ins
  "echo" "printf" "true" "false"
  # History commands
  "history" "fc"
  # Other common utilities
  "clear" "exit" "which" "whereis" "whatis"
  "man" "info" "help"
  # Time and date
  "date" "time"
  # File permissions
  # "chmod" "chown" "chgrp"
  # Compression
  #    "tar" "gzip" "gunzip" "zip" "unzip"
  # Disk usage
  "df" "du" "dust"
  # Text processing
  # "grep" "sed" "awk" "cut" "sort" "uniq" "wc"
  # macOS specific
  # "open" "pbcopy" "pbpaste"
  )

# Parameter expansion breakdown:
# - ${(j:|:)IGNORE_COMMANDS} - Joins array elements with | as separator
# - ( .*)? - Optionally matches space and any following arguments
# - The ^ and $ anchor the pattern to match the entire command line
HISTORY_IGNORE="^(${(j:|:)IGNORE_COMMANDS})( .*)?$"

#Function: _history-ignore()
#
#Brief: Hook function to filter shell history based on the HISTORY_IGNORE pattern.
#
_history-ignore() {
  emulate -L zsh

  # Check if HISTORY_IGNORE is set
  [[ -z "$HISTORY_IGNORE" ]] && return 0  # Save all commands if no ignore pattern

  local cmd="${1%%$'\n'}"

  # Check if command matches ignore pattern using regex
  if [[ $cmd =~ $HISTORY_IGNORE ]]; then
    [[ -n "$HISTORY_DEBUG" ]] && echo "Ignoring command: $cmd"
    return 1  # Return 1 to prevent adding to history
  else
    [[ -n "$HISTORY_DEBUG" ]] && echo "Recording command: $cmd"
    return 0  # Return 0 to add to history
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook zshaddhistory _history-ignore

# =============================================================================
# ShellHistory.app Integration - TEMPORARILY DISABLED
# Issue: shhist binary is causing trace traps on this system
# TODO: Investigate ShellHistory.app version compatibility
# =============================================================================

# [[ -d "/Applications/ShellHistory.app/Contents/Helpers" ]] || return

# Add shhist to PATH
PATH="${PATH}:/Applications/ShellHistory.app/Contents/Helpers"

# Create unique session ID for each terminal session
__shhist_session="${RANDOM}"

# Prompt function to record command history in ShellHistory database
__shhist_prompt() {
    local __exit_code="${?:-1}"
    # The sudo --user call is intentional and safe per ShellHistory documentation:
    \history -D -t "%s" -1 | sudo --user ${SUDO_USER:-${LOGNAME}} shhist insert \
        --session ${TERM_SESSION_ID:-${__shhist_session}} \
        --username ${LOGNAME} \
        --hostname $(hostname) \
        --exit-code ${__exit_code} \
        --shell zsh
    return ${__exit_code}
}

# integrating prompt function in prompt
# precmd_functions=(__shhist_prompt $precmd_functions)
