# history: Custom history features complementing Zephyr history plugin
# Provides: aliases, ignore patterns, and ShellHistory.app integration
# Note: Core options (setopts) and HISTFILE/SIZE are handled by Zephyr.

# =============================================================================
# History and Search Aliases
# =============================================================================
alias h=' hist'             # Lists recent history (Zephyr history plugin)
alias hf=' hist fix -1'     # Fixes last history entry (Zephyr history plugin)
alias h-search=' fc -El 0 | grep' # Searches for a word in terminal history
alias histrg=' history -500 | rg' # Rip grep search recent history
alias hgrep=' fc -El 0 | grep'

# =============================================================================
# History Ignore Configuration
# =============================================================================

IGNORE_COMMANDS=(
  "cat" "less" "more" "head" "tail"
  "uname" "hostname" "whoami" "id"
  "ps" "top" "htop"
  "echo" "printf" "true" "false"
  "history" "fc"
  "clear" "exit" "which" "whereis" "whatis"
  "man" "info" "help"
  "date" "time"
  "df" "du" "dust"
)

HISTORY_IGNORE="^(${(j:|:)IGNORE_COMMANDS})( .*)?$"

_history-ignore() {
  emulate -L zsh
  [[ -z "$HISTORY_IGNORE" ]] && return 0
  local cmd="${1%%$'\n'}"
  if [[ $cmd =~ $HISTORY_IGNORE ]]; then
    return 1
  else
    return 0
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook zshaddhistory _history-ignore

# =============================================================================
# ShellHistory.app Integration
# =============================================================================

if [[ -d "/Applications/ShellHistory.app/Contents/Helpers" ]]; then
    # adding shhist to PATH
    PATH="${PATH}:/Applications/ShellHistory.app/Contents/Helpers"
    __shhist_session="${RANDOM}"

    __shhist_prompt() {
        # SAFETY: Only run in interactive shells to prevent trace traps during tests
        [[ -o interactive ]] || return

        local __exit_code="${?:-1}"
        \history -D -t "%s" -1 | command sudo --preserve-env --user ${SUDO_USER:-${LOGNAME}} shhist insert --session ${TERM_SESSION_ID:-${__shhist_session}} --username ${LOGNAME} --hostname $(hostname) --exit-code ${__exit_code} --shell zsh
        return ${__exit_code}
    }

    # integrate hook
    add-zsh-hook precmd __shhist_prompt
fi
