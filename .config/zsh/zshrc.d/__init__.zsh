# =============================================================================
# __init__.zsh
# =============================================================================
# This runs prior to any other conf.d contents.

# =============================================================================
# ENVIRONMENT VARIABLES & EXPORTS
# =============================================================================

# Apps
export EDITOR=micro
export VISUAL=code
export PAGER=less

# The github username where the setup scripts are downloaded from
export GH_USERNAME='mahdz'

export GIT_CONFIG_GLOBAL="${XDG_CONFIG_HOME}/git/config"

# # This repo is cloned into this location
export DOTFILES="${HOME}/.dotfiles"
# Note: GIT_DIR and GIT_WORK_TREE are not set globally to avoid interfering with other Git operations
# Use the 'dot' or 'dotgit' aliases for dotfiles management instead

# # Branch name of the dotfiles repo that's to be used for testing PR changes before merging
export DOTFILES_BRANCH='main'

# # All development codebases are cloned into a subfolder of this folder
export PROJECTS_BASE_DIR="${HOME}/Developer"

export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME}/ripgrep/config"

export SCRIPTS='/Users/mh/Developer/repos/id774/scripts'

[ -f ${XDG_DATA_HOME}/secrets/secrets.zsh ] && source ${XDG_DATA_HOME}/secrets/secrets.zsh

# # clone external plugins/themes
# function zsh_custom_clone {
#   emulate -L zsh
#   setopt local_options no_monitor pipefail
#   local repo dest
#   dest="${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/$1"; shift
#   mkdir -p "$dest"
#   for repo in $@; do
#     if [[ ! -d $dest/${repo:t} ]]; then
#       git -C $dest clone --quiet --recursive --depth 1 https://github.com/$repo &
#     fi
#   done
#   wait
# }

# zsh_custom_clone plugins \
# #  aloxaf/fzf-tab \
# #  jeffreytse/zsh-vi-mode \
# #  kaelzhang/shell-safe-rm \
# #  mattmc3/zman \
# #  romkatv/zsh-no-ps2 \
# #  zdharma-continuum/fast-syntax-highlighting \
# #  zsh-users/zsh-autosuggestions \
# #  zsh-users/zsh-completions \
# #  zsh-users/zsh-history-substring-search

# zsh_custom_clone themes \
# #  romkatv/powerlevel10k

# zsh_custom_clone .external \
#  # kaelzhang/shell-safe-rm \
#   romkatv/zsh-bench

# -----------------------------------------------------
# ╭─────────╮
# │ VS Code │
# ╰─────────╯
#if type code >/dev/null 2>&1; then
# VSCODE_PORTABLE: Stores all VS Code data including settings, keybindings, and snippets
#  export VSCODE_PORTABLE="~/Applications/code-portable-data/user-data"

# VSCODE_EXTENSIONS: Specifies custom extensions directory
#  export VSCODE_EXTENSIONS="${XDG_DATA_HOME:-~/.local/share}/vscode/extensions"
#fi

# -----------------------------------------------------
# ╭─────────╮
# │ Python  │
# ╰─────────╯
# Define hook functions
_venv_post_hook() {
    v cd
    v venv
}

_venv_post_hook_deactivate() {
    v cd
    v reset_venv
}

# Register the hooks
zsh_uv_add_post_hook_on_activate '_venv_post_hook'
zsh_uv_add_post_hook_on_deactivate '_venv_post_hook_deactivate'


# -----------------------------------------------------
# ╭─────────────────╮
# │ Shell Utilities │
# ╰─────────────────╯

# tldr
[[ $(command -v tldr) ]] && export TEALDEER_CONFIG_DIR="${XDG_CONFIG_HOME}/tldr"

# bat
[[ $(command -v bat) ]] && export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# bat-extras
[[ $(command -v batman) ]] && eval "$(batman --export-env)"

# batpipe
[[ $(command -v batpipe) ]] && eval "$(batpipe)"

# fastfetch
#[[ $(command -v fastfetch) ]] && fastfetch --config $(printf "%s\n" examples/{12,13} | gshuf -n 1)

# navi
#[[ $(command -v navi) ]] && eval "$(navi widget zsh)"
