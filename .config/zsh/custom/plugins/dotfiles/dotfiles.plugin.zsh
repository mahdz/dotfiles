###############################################################
# Dotfiles Plugin — Bare Git Repository Workflow
# Repo: $HOME/.dotfiles
# Worktree: $HOME
###############################################################

# --- Environment ---

# Dotfiles Repo Path
: ${DOTFILES_DIR:="${HOME}/.dotfiles"}

# VS Code Workspace
export DOT_WORKSPACE="${XDG_CONFIG_HOME:-$HOME/.config}/vscode/dotfiles.code-workspace"

# Default Branch
export DOTFILES_BRANCH='main'

# Obsidian Vault Path
export VAULT_PATH="$HOME/Vault"

# --- Utilities ---

_dotfiles_command_exists() { command -v "$1" >/dev/null 2>&1; }

###############################################################
# Git Command Wrapper
###############################################################
_dotfiles_git() {
    /usr/bin/env git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"
}

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
        _dotfiles_git "$@"
        return $?
    fi

    # Security Allowlist: Prevent accidental execution of shell binaries
    case "$1" in
        status|add|commit|push|pull|log|diff|branch|checkout|reset|\
        merge|rebase|stash|show|ls-files|check-ignore|clean|mv|rm|\
        restore|switch|tag|fetch|init|config|remote|reflog|shortlog|\
        archive|blame|grep|bisect|describe|notes|submodule|worktree)
            _dotfiles_git "$@"
            ;;
        *)
            echo "❌ Unknown git command: '$1'"
            echo "   To force execution, use: dots git $1"
            return 1
            ;;
    esac
}

###############################################################
# High-Level Safe Helper Commands
###############################################################

dotstatus() {
    # --short provides a cleaner "changed files" list
    _dotfiles_git status --short
}

dotadd() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: dotadd <file> [files...]"
        return 1
    fi

    if ! _dotfiles_command_exists git; then
        echo "❌ git command not found in PATH"
        return 1
    fi

    for path in "$@"; do
        # Normalize path: remove leading slash if present
        path="${path#/}"

        # Check existence relative to HOME (Worktree root)
        if [[ ! -e "${HOME}/${path}" ]]; then
            echo "❌ File does not exist: ${path}"
            return 1
        fi

        echo "➕ Adding: ${path}"
        # Pass relative path to git (worktree is already $HOME)
        _dotfiles_git add -- "${path}"
    done
}

dotignore() {
    local pattern="$1"
    local ignore_file="$HOME/.gitignore"

    if [[ -z "$pattern" ]]; then echo "Usage: dotignore <pattern>"; return 1; fi

    # Ensure the file exists
    [[ -f "$ignore_file" ]] || touch "$ignore_file"

    # Idempotency check: Don't add if already exists
    if grep -qF "$pattern" "$ignore_file"; then
        echo "⚠️  Pattern '$pattern' already exists in .gitignore"
    else
        echo "$pattern" >> "$ignore_file"
        _dotfiles_git add "$ignore_file"
        echo "📝 Added and staged ignore pattern: $pattern"
    fi
}

dotdiff() {
    _dotfiles_git diff --color "$@"
}

dotcommit() {
    if [[ $# -eq 0 ]]; then echo "Usage: dotcommit <message>"; return 1; fi
    _dotfiles_git commit -m "$*"
}

dotpush() {
    _dotfiles_git push origin "${DOTFILES_BRANCH}"
}

dotgrep() {
    _dotfiles_git grep -n "$@"
}

doted() {
    # Check prerequisites
    if ! _dotfiles_command_exists fzf; then
        echo "❌ fzf not found in PATH"
        return 1
    fi

    if ! _dotfiles_command_exists code; then
        echo "❌ VS Code 'code' command not found"
        return 1
    fi

    local file
    # Uses fzf to pick a file from the tracked index
    file=$(_dotfiles_git ls-files 2>/dev/null | fzf --height 40% --layout=reverse) || return 1

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
    local subcommand="$1"; shift

    case "$subcommand" in
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
alias dotdir='cd "$DOTFILES_DIR"'

if _dotfiles_command_exists code; then
    alias dotty='dotcode'
fi

###############################################################
# Function Precedence Handling
###############################################################

# Ensure our dot function takes precedence over external commands (e.g., Graphviz)
# This handles the case where Homebrew installs Graphviz with a `dot` binary
# ⚠️ DISABLED: This function was causing PATH manipulation issues during initialization
# The dot function defined above will take precedence naturally in zsh scope rules
# If you need to handle Graphviz conflicts, do so AFTER full shell initialization
# (e.g., in .zprofile or at the end of .zshrc after all plugins load)

###############################################################
# Initialization Banner
###############################################################
if [[ -z "$_DOTFILES_PLUGIN_LOADED" ]]; then
    export _DOTFILES_PLUGIN_LOADED=1
    # Removed: _ensure_dot_precedence - causes PATH issues at load time
    # Removed: _verify_function_loading - not needed during initialization
    # Functions are defined above and will work correctly
fi

zstyle ':zsh_custom:plugin:dotfiles' loaded 'yes'
