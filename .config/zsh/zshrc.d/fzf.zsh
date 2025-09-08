#!/bin/zsh

#
# FZF
#

# Ensure fzf is available, otherwise stop here.
(( $+commands[fzf] )) || return 1

# Guard against re-sourcing this file in nested shells.
if [ -n "$_FZF_ZSH_CONFIGURED" ]; then
    return
fi
export _FZF_ZSH_CONFIGURED=1


# Auto-detect FZF installation path using array of potential locations
if [[ -z "$FZF_PATH" ]]; then
  local fzf_locations=("/opt/homebrew/opt/fzf" "$XDG_DATA_HOME/mise/shims")
  for location in "${fzf_locations[@]}"; do
    if [[ -d "$location" ]]; then
      export FZF_PATH="$location"
      break
    fi
  done
fi

#---------------------------------------------------------------------------

# FZF default options - consolidated configuration
# Basic options:
#   --exact:          Enable exact-match
#   --layout=reverse: Enclose in a box at the top of the screen
#   --info=inline:    Display finder info inline with the prompt
#   --pointer="→":    Set custom pointer
#   --header:         Add a header
# Color scheme: Custom dark theme with blue/purple accents
local fzf_base_opts="--exact --layout=reverse --info=inline --pointer='→' --header='CTRL-c or ESC to quit'"
local fzf_colors="--color=fg:#d0d0d0,bg:#121212,hl:#5f87af --color=fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff --color=info:#afaf87,prompt:#d7005f,pointer:#af5fff --color=marker:#87ff00,spinner:#af5fff,header:#87afaf"

# Set height based on TMUX availability
if [[ -n "${TMUX}" ]] && (( $+commands[fzf-tmux] )); then
    export FZF_DEFAULT_OPTS="$fzf_base_opts $fzf_colors"
    # Override fzf to use fzf-tmux wrapper
    fzf() {
        fzf-tmux -p -w 100% -h 80% "$@"
    }
else
    export FZF_DEFAULT_OPTS="$fzf_base_opts $fzf_colors --height=50%"
fi

# Set the default command for fzf to use fd.
# --type file:      Find only files
# --strip-cwd-prefix: Remove leading './' from paths
# --hidden:         Include hidden files
# --follow:         Follow symlinks
# --exclude .git:   Exclude .git directories
export FZF_DEFAULT_COMMAND='fd --type file --strip-cwd-prefix --hidden --follow --exclude ".git"'

# Use the same command for CTRL-T
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Options for CTRL-T
# --walker-skip:    Skip directories during walk
# --preview:        Use bat for preview
# --bind:           Custom keybindings
export FZF_CTRL_T_OPTS='--walker-skip .git,node_modules,target \
--preview "bat -n --color=always {}" \
--bind "ctrl-/:change-preview-window(down|hidden|)"'

# Options for CTRL-R (history search)
# --preview:        Show command in preview
# --bind:           Copy to clipboard with CTRL-Y, toggle preview with ?
# --header:         Informative header
export FZF_CTRL_R_OPTS='--preview "echo {}" --preview-window down:3:hidden:wrap \
--bind "?:toggle-preview" \
--bind "ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort" \
--color header:italic \
--header "Press CTRL-Y to copy command into clipboard"'


# Options for ALT-C (directory search)
# --preview:        Use tree for preview if available
if (( $+commands[tree] )); then
  export FZF_ALT_C_OPTS='--preview "tree -C {} | head -200"'
fi

# Use ~~ as the trigger sequence for completion
export FZF_COMPLETION_TRIGGER='~~'

# Options for fzf completion
export FZF_COMPLETION_OPTS='--border --info=inline'

# Advanced customization of fzf options via _fzf_comprun function
# This function is called by fzf completion for specific commands.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
  cd) fzf --preview 'tree -C {} | head -200' "$@" ;;
  export | unset) fzf --preview "eval 'echo \$'{}" "$@" ;;
  ssh) fzf --preview 'dig {}' "$@" ;;
  *) fzf --preview 'bat -n --color=always {}' "$@" ;;
  esac
}

# Use fd for listing path candidates for completion.
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion.
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

# Enhanced cd function with fzf directory selection
# Provides interactive directory navigation when called without arguments
cd() {
  # If arguments are provided, use the standard builtin cd
  if [[ "$#" != 0 ]]; then
    builtin cd "$@"
    return
  fi

  # Interactive directory selection loop
  while true; do
    # Build directory list: parent (..) + subdirectories
    # Using fd if available for better performance, fallback to find
    local dirs
    if (( $+commands[fd] )); then
      dirs=(".." $(fd --type d --max-depth 1 --exclude ".git" . 2>/dev/null))
    else
      # Portable fallback using find
      dirs=(".." $(find . -maxdepth 1 -type d ! -name . ! -name ".git" -exec basename {} \; 2>/dev/null))
    fi

    # Use fzf for directory selection with enhanced preview
    local selected_dir="$(printf '%s\n' "${dirs[@]}" | fzf \
      --reverse \
      --prompt='Select directory: ' \
      --preview '
        # Normalize the selected directory path
        if [[ "{}" == ".." ]]; then
          preview_path="$(dirname "$(pwd)")"
        else
          preview_path="$(pwd)/{}"
        fi
        
        echo "Preview: $preview_path"
        echo
        
        # Show directory contents with ls (portable options)
        if [[ -d "$preview_path" ]]; then
          ls -la "$preview_path" 2>/dev/null || echo "Cannot preview directory"
        fi
      ')"

    # Exit if selection was cancelled (empty result)
    [[ -n "$selected_dir" ]] || return 0
    
    # Change to selected directory
    if ! builtin cd "$selected_dir" 2>/dev/null; then
      echo "Error: Cannot change to directory '$selected_dir'" >&2
      return 1
    fi
  done
}
