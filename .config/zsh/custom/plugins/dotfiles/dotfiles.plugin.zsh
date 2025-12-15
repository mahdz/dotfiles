###############################################################
# Dotfiles Plugin — Bare Git Repository Workflow
# Repo: $HOME/.dotfiles
# Worktree: $HOME
###############################################################

# --- Environment ---
: ${DOTFILES:="$HOME/.dotfiles"}
: ${ZDOTDIR:="$HOME/.config/zsh"}
export DOT_WORKSPACE="${XDG_CONFIG_HOME:-$HOME/.config}/vscode/dotfiles.code-workspace"
export ZSH_CUSTOM="${ZSH_CUSTOM:-$ZDOTDIR/custom}"

# --- Utilities ---
_dotfiles_command_exists() { command -v "$1" >/dev/null 2>&1; }

###############################################################
# dots(): The Strict Git Wrapper
###############################################################
dots() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: dots [git] <command> [args...]"
        echo "  dots status"
        echo "  dots add <file>"
        echo "  dots commit -m 'msg'"
        return 1
    fi

    # Explicit git mode – safest mechanism
    if [[ "$1" == "git" ]]; then
        shift
        command git --git-dir="$DOTFILES" --work-tree="$HOME" "$@"
        return $?
    fi

    # Security Allowlist: Prevent accidental execution of shell binaries
    local git_commands=(
        status add commit push pull log diff branch checkout
        reset merge rebase stash show ls-files check-ignore clean
        mv rm restore switch tag fetch init config remote reflog
        shortlog archive blame grep bisect describe notes submodule
        worktree
    )

    if (( ${git_commands[(Ie)$1]} )); then
        command git --git-dir="$DOTFILES" --work-tree="$HOME" "$@"
    else
        echo "❌ Unknown git command: '$1'"
        echo "   To force execution, use: dots git $1"
        return 1
    fi
}

###############################################################
# High-Level Safe Helper Commands
###############################################################

dotstatus() {
    # --short provides a cleaner "changed files" list
    git --git-dir="$DOTFILES" --work-tree="$HOME" status --short
}

dotadd() {
    local path="$1"
    if [[ -z "$path" ]]; then echo "Usage: dotadd <file>"; return 1; fi

    # Check existence relative to HOME (Worktree root)
    if [[ ! -e "$HOME/$path" ]]; then
        echo "❌ File does not exist: $path"
        return 1
    fi

    echo "➕ Adding: $path"
    git --git-dir="$DOTFILES" --work-tree="$HOME" add -- "$path"
}

dotignore() {
    local pattern="$1"
    local ignore_file="$HOME/.gitignore"

    if [[ -z "$pattern" ]]; then echo "Usage: dotignore <pattern>"; return 1; fi

    # Idempotency check: Don't add if already exists
    if grep -qF "$pattern" "$ignore_file"; then
        echo "⚠️  Pattern '$pattern' already exists in .gitignore"
    else
        echo "$pattern" >> "$ignore_file"
        git --git-dir="$DOTFILES" --work-tree="$HOME" add "$ignore_file"
        echo "📝 Added and staged ignore pattern: $pattern"
    fi
}

dotdiff() {
    git --git-dir="$DOTFILES" --work-tree="$HOME" diff --color "$@"
}

dotcommit() {
    if [[ -z "$1" ]]; then echo "Usage: dotcommit <message>"; return 1; fi
    git --git-dir="$DOTFILES" --work-tree="$HOME" commit -m "$*"
}

dotpush() {
    git --git-dir="$DOTFILES" --work-tree="$HOME" push origin main
}

dotgrep() {
    git --git-dir="$DOTFILES" --work-tree="$HOME" grep -n "$@"
}

doted() {
    local file
    # Uses fzf to pick a file from the tracked index
    file=$(git --git-dir="$DOTFILES" --work-tree="$HOME" ls-files | fzf --height 40% --layout=reverse 2>/dev/null)

    if [[ -n "$file" ]]; then
        echo "✏️ Opening: $file"
        code "$HOME/$file"
    fi
}

###############################################################
# Unified Interface: dot <command>
###############################################################
# This function aggregates the high-level helpers
dot() {
    local cmd="$1"; shift

    case "$cmd" in
        s|status)  dotstatus "$@" ;;
        a|add)     dotadd "$@" ;;
        i|ignore)  dotignore "$@" ;;
        d|diff)    dotdiff "$@" ;;
        c|commit)  dotcommit "$@" ;;
        p|push)    dotpush "$@" ;;
        e|edit)    doted "$@" ;;
        g|grep)    dotgrep "$@" ;;
        *)
            echo "Available commands:"
            echo "  s | status   : Show status"
            echo "  a | add      : Add file"
            echo "  i | ignore   : Ignore pattern"
            echo "  d | diff     : View changes"
            echo "  c | commit   : Commit changes"
            echo "  p | push     : Push to remote"
            echo "  e | edit     : FZF file picker"
            echo "  g | grep     : Search code"
        ;;
    esac
}

###############################################################
# VS Code Integration
###############################################################
dotcode() {
    if _dotfiles_command_exists code; then
        code "$DOT_WORKSPACE"
    else
        echo "⚠️ VS Code 'code' command not found."
    fi
}

###############################################################
# Aliases
###############################################################

# NOTE: We DO NOT alias dot='dots' here.
# 'dot' is now the high-level function, 'dots' is the low-level git wrapper.

alias ds='dotstatus'
alias da='dotadd'
alias dan='dots add -n' # Keep dry-run on the low-level command
alias dc='dotcommit'
alias dp='dotpush'
alias dl='dots pull'
alias dd='dotdiff'
alias dg='dotgrep'
alias de='doted'

alias zdot="cd \"$ZDOTDIR\""
alias zcust="cd \"$ZSH_CUSTOM\""
alias dotdir='cd "$DOTFILES"'

if _dotfiles_command_exists code; then
    alias dotty='dotcode'
fi

###############################################################
# Initialization Banner
###############################################################
if [[ -z "$_DOTFILES_PLUGIN_LOADED" ]]; then
    export _DOTFILES_PLUGIN_LOADED=1
    echo "✨ Dotfiles plugin loaded (repo: ~/.dotfiles)"
fi

zstyle ':zsh_custom:plugin:dotfiles' loaded 'yes'
