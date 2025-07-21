# history: Set history options and define history aliases.
#

## History command configuration
# OMZ settings:
# setopt extended_history       # record timestamp of command in HISTFILE
# setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
# setopt hist_ignore_dups       # ignore duplicated commands history list
# setopt hist_ignore_space      # ignore commands that start with space
# setopt hist_verify            # show command with history expansion to user before running it
# setopt share_history          # share command history data

# Overwrite
unsetopt hist_reduce_blanks      # Remove extra blanks from commands added to the history list.
unsetopt NO_share_history        # Don't share history between all sessions.

IGNORE_COMMANDS=(
  # Directory listing
  #    "ls" "exa" "eza" "lsd" "l" "ll" "la"
  # Directory navigation
  #    "pwd" "cd" "pushd" "popd" "dirs"
  # File operations
  # "cp" "mv" "rm" "touch" "mkdir" "rmdir"
  # Text viewing
  #    "cat" "less" "more" "head" "tail"
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
  #    "grep" "sed" "awk" "cut" "sort" "uniq" "wc"
  # macOS specific
  #"open" "pbcopy" "pbpaste"
  )

# Parameter expansion breakdown:
# - ${(j:|:)IGNORE_COMMANDS} - Joins array elements with | as separator
# - [[:space:]]* - Matches any trailing whitespace
# - The parentheses create a capture group for the entire pattern
export HISTORY_IGNORE="(${(j:|:)IGNORE_COMMANDS})[[:space:]]*"

#Function: _history-ignore()
#
#Brief: Hook function to filter shell history based on the HISTORY_IGNORE pattern.
#
_history-ignore() {
  emulate -L zsh
  setopt extendedglob

  # Check if HISTORY_IGNORE is set
  [[ -z "$HISTORY_IGNORE" ]] && return 0  # Save all commands if no ignore pattern
  [[ -n "$HISTORY_DEBUG" ]] && echo "Checking command: ${1%%$'\n'}"
  [[ ${1%%$'\n'} != "${~HISTORY_IGNORE}" ]]
}

autoload -Uz add-zsh-hook
add-zsh-hook zshaddhistory _history-ignore

#
# Enable Shell History.app
#

[[ -d "/Applications/ShellHistory.app/Contents/Helpers" ]] || return

# adding shhist to PATH, so we can use it from Terminal
PATH="${PATH}:/Applications/ShellHistory.app/Contents/Helpers"

# creating an unique session id for each terminal session
__shhist_session="${RANDOM}"

# prompt function to record the history
__shhist_prompt() {
  local __exit_code="${?:-1}"
  \history -D -t "%s" -1 | sudo --user ${SUDO_USER:-${LOGNAME}} shhist insert --session ${TERM_SESSION_ID:-${__shhist_session}} --username ${LOGNAME} --hostname $(hostname) --exit-code ${__exit_code} --shell zsh
  return ${__exit_code}
}

# integrating prompt function in prompt
precmd_functions=(__shhist_prompt $precmd_functions)
