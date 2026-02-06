# history: Custom history features complementing Zephyr history plugin
# Provides: aliases, ignore patterns, and ShellHistory.app integration
# Note: Core history configuration is handled by Zephyr history plugin
#

# =============================================================================
# History Configuration Notes
# =============================================================================
# HISTFILE is set by Zephyr to: ${XDG_DATA_HOME}/zsh/zsh_history
# To check current value: echo $HISTFILE

setopt bang_hist               # Treat the '!' character specially during expansion.
setopt extended_history        # Write the history file in the ':start:elapsed;command' format.
setopt hist_expire_dups_first  # Expire a duplicate event first when trimming history.
setopt hist_find_no_dups       # Do not display a previously found event.
setopt hist_ignore_all_dups    # Delete an old recorded event if a new event is a duplicate.
setopt hist_ignore_dups        # Do not record an event that was just recorded again.
setopt hist_ignore_space       # Do not record an event starting with a space.
setopt hist_reduce_blanks      # Remove extra blanks from commands added to the history list.
setopt hist_save_no_dups       # Do not write a duplicate event to the history file.
setopt hist_verify             # Do not execute immediately upon history expansion.
setopt inc_append_history      # Write to the history file immediately, not when the shell exits.
setopt NO_hist_beep            # Don't beep when accessing non-existent history.
setopt NO_share_history        # Don't share history between all sessions.
unsetopt HIST_REDUCE_BLANKS

# $HISTFILE belongs in the data home, not with zsh configs
export HISTFILE="${XDG_DATA_HOME:=$HOME/.local/share}/zsh/zsh_history"
[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"

# $SAVEHIST and $HISTSIZE can be set to anything greater than the Zsh defaults,
# 1000 and 2000 respectively, but if not make them way bigger.
[[ $SAVEHIST -gt 1000 ]] || export SAVEHIST=10000
[[ $HISTSIZE -gt 2000 ]] || export HISTSIZE=10000

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
# ShellHistory.app Integration
# =============================================================================

[[ -d "/Applications/ShellHistory.app/Contents/Helpers" ]] || return

# adding shhist to PATH, so we can use it from Terminal
PATH="${PATH}:/Applications/ShellHistory.app/Contents/Helpers"

# creating an unique session id for each terminal session
__shhist_session="${RANDOM}"

# prompt function to record the history
__shhist_prompt() {
    local __exit_code="${?:-1}"
    \history -D -t "%s" -1 | sudo --preserve-env --user ${SUDO_USER:-${LOGNAME}} shhist insert --session ${TERM_SESSION_ID:-${__shhist_session}} --username ${LOGNAME} --hostname $(hostname) --exit-code ${__exit_code} --shell zsh
    return ${__exit_code}
}

# integrating prompt function in prompt
precmd_functions=(__shhist_prompt $precmd_functions)
