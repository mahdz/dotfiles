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


# Auto-detect FZF installation path
if [ -z "$FZF_PATH" ]; then
  if [ -d "/opt/homebrew/opt/fzf" ]; then
    FZF_PATH="/opt/homebrew/opt/fzf"
  elif [ -d "$XDG_DATA_HOME/mise/shims" ]; then
    FZF_PATH="$XDG_DATA_HOME/mise/shims"
  fi
fi

#---------------------------------------------------------------------------

# FZF options
# --exact:          Enable exact-match
# --layout=reverse: Enclose in a box at the top of the screen
# --info=inline:    Display finder info inline with the prompt
# --pointer="→":    Set custom pointer
# --header:         Add a header
# --height:         Set height if not in TMUX
# --color:          Set colors
export FZF_DEFAULT_OPTS="
--exact
--layout=reverse
--info=inline
--pointer='→'
--header='CTRL-c or ESC to quit'
--color=fg:#d0d0d0,bg:#121212,hl:#5f87af
--color=fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff
--color=info:#afaf87,prompt:#d7005f,pointer:#af5fff
--color=marker:#87ff00,spinner:#af5fff,header:#87afaf
"

# Use fzf-tmux wrapper if in a TMUX session
if [[ -n "${TMUX}" ]] && (( $+commands[fzf-tmux] )); then
    fzf() {
        fzf-tmux -p -w 100% -h 80%
    }
else
    export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --height=50%"
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

# Custom cd function to use fzf for directory selection.
cd() {
  # If arguments are provided, use the standard `cd`.
  if [[ "$#" != 0 ]]; then
    builtin cd "$@"
    return
  fi

  # Loop to allow continuous directory selection until cancelled.
  while true; do
    # List subdirectories and ".." for parent directory.
    # `ls -d */` is used for portability (avoids GNU-specific `--`).
    local lsd=$(echo ".." && ls -d */ 2>/dev/null)

    # Use fzf to select a directory.
    local dir="$(printf '%s\n' "${lsd[@]}" |
      fzf --reverse --preview '
            # Get the selected item.
            __cd_nxt="$(echo {})";
            # Construct the full path for the preview.
            __cd_path="$(echo $(pwd)/${__cd_nxt} | sed "s;//;/;")";
            echo "Preview of: ${__cd_path}";
            echo;
            # Show the contents of the selected directory.
            ls -p --color=always "${__cd_path}";
    ')"

    # If fzf was cancelled (empty selection), exit the loop.
    [[ ${#dir} != 0 ]] || return 0
    # Change to the selected directory.
    builtin cd "$dir" &>/dev/null
  done
}
