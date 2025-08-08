# =============================================================================
# __init__.zsh
# =============================================================================
# This runs prior to any other conf.d contents.

# =============================================================================
# ENVIRONMENT VARIABLES & EXPORTS
# =============================================================================

# Apps
# Preferred editor for remote sessions
if [[ -n "${SSH_CONNECTION}" ]]; then
  export EDITOR=nano
elif (( $+commands[code] )); then
  export EDITOR=code
elif (( $+commands[micro] )); then
  export EDITOR=micro
else
  export EDITOR=nano
fi

# Align VISUAL with EDITOR if not set
export VISUAL=${VISUAL:-$EDITOR}

# Set pager and options
export PAGER=less
export LESS='-iRFXMx4 --incsearch --use-color --mouse'

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

export PYTHONWARNINGS="ignore::DeprecationWarning"

# Hook to run after virtual environment activation
_venv_post_hook() {
  # Change to project root directory (if applicable)
  # Example: cd to directory containing the virtualenv or a known project folder
  if [[ -f "pyproject.toml" || -f "setup.py" ]]; then
    echo "In project root"
  else
    echo "Warning: Not in project root"
  fi

  # Show active Python version and virtualenv path
  echo "Python version: $(python --version)"
  echo "Virtualenv: $VIRTUAL_ENV"

  # Activate virtualenv-specific environment variables or aliases
  #export FLASK_ENV=development
  #export DJANGO_SETTINGS_MODULE=myproject.settings.local

  # List installed packages (optional)
  #pip list --format=columns | head -20

  # Run any project-specific initialization scripts
  # ./scripts/post_activate.sh
}

# Hook to run after virtual environment deactivation
_venv_post_hook_deactivate() {
  # Return to previous directory or project root if desired
  # cd -

  # Unset virtualenv-specific environment variables
  #unset FLASK_ENV
  #unset DJANGO_SETTINGS_MODULE

  # Clean up any temporary files or caches related to the venv
  rm -rf .pytest_cache

  echo "Virtual environment deactivated."
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
