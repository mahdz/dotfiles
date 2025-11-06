# --- Environment ---
: ${DOTFILES:=$HOME/.dotfiles}
: "${ZDOTDIR:=$HOME/.config/zsh}"
export DOT_WORKSPACE="${XDG_CONFIG_HOME:-$HOME/.config}/vscode/dotfiles.code-workspace"
export ZSH_CUSTOM="${ZSH_CUSTOM:-$ZDOTDIR/custom}"

# --- Core function ---
dots() {    
    # If no arguments, show usage
    if [[ $# -eq 0 ]]; then
        echo "Usage: dots [git] <command> [args...]"
        echo ""
        echo "Examples:"
        echo "  dots status              # git status"
        echo "  dots add -n file         # git add -n file (dry run)"
        echo "  dots add file            # git add file"
        echo "  dots commit -m 'msg'     # git commit -m 'msg'"
        echo "  dots push                # git push"
        echo "  dots git log --oneline   # explicit git mode"
        return 1
    fi
    
    # Handle explicit git mode
    if [[ "$1" == "git" ]]; then
        shift
        command git --git-dir="$DOTFILES" --work-tree="$HOME" "$@"
        return $?
    fi
    
    # List of common git commands (implicit mode)
    local git_commands=(
        status add commit push pull log diff branch checkout
        reset merge rebase stash show ls-files check-ignore
        clean mv rm restore switch tag fetch clone init
        config remote reflog shortlog archive blame grep
        bisect describe notes submodule worktree
    )
    
    # Check if first argument is a known git command
    if (( ${git_commands[(Ie)$1]} )); then
        command git --git-dir="$DOTFILES" --work-tree="$HOME" "$@"
    else
        # Fallback: try to execute as regular command with git environment
        GIT_DIR="$DOTFILES" GIT_WORK_TREE="$HOME" "$@"
    fi
}

# --- Helpers ---
dotcode() {
  emulate -L zsh
  setopt LOCAL_OPTIONS PIPE_FAIL ERR_EXIT

  if command_exists code; then
    dots code "$DOT_WORKSPACE"
  else
    echo "VSCode 'code' command not found."
  fi
}

show_dotfiles_workspace() {
  cat "$DOT_WORKSPACE"
}

# --- Aliases ---
# Make sure this alias has priority over binaries in /opt/homebrew/bin
alias -g dot='dots'

# Dotfiles shortcuts for Warp AI suggestions
alias ds='dots status'
alias da='dots add'
alias dan='dots add -n'  # dry-run first!
alias dc='dots commit'
alias dp='dots push'
alias dl='dots pull'
alias dd='dots diff'

alias zdot="cd \"$ZDOTDIR\""
alias zcust="cd \"$ZSH_CUSTOM\""
alias dotg="dots git"

if command_exists code; then
  alias dotty="dots code \"$DOT_WORKSPACE\""
fi

# dotfiles
alias dotdir='cd "$DOTFILES"'
alias dotcode='GIT_WORK_TREE="$HOME" && cd "$DOTFILES" && code .'
alias zdot='cd $ZDOTDIR'

hash -d vault="$VAULT_PATH"

# Mark the plugin as loaded
zstyle ':zsh_custom:plugin:dotfiles' loaded 'yes'
