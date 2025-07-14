#!/bin/zsh

#
# FZF
#

if [ -z "$FZF_PATH" ]; then
  if [ -d "/opt/homebew/opt/fzf" ]; then
    FZF_PATH="/opt/homebrew/opt/fzf"
  elif [ -d "$XDG_DATA_HOME/mise/shims" ]; then
    FZF_PATH="$XDG_DATA_HOME/mise/shims"
  fi
fi

#[ -z "$FZF_PATH" ] && { [ -d "/opt/homebew/opt/fzf" ] && FZF_PATH="/opt/homebew/opt/fzf" || [ -d "$XDG_DATA_HOME/mise/shims" ] && FZF_PATH="$XDG_DATA_HOME/mise/shims"; }

#---------------------------------------------------------------------------

export FZF_DEFAULT_OPTS='--exact --layout=reverse --info=inline --pointer="→" --header="CTRL-c or ESC to quit"'

if [[ -n ${TMUX} ]] && command -v fzf-tmux &>/dev/null; then
    fzf() {
        fzf-tmux -p -w 100% -h 80%
    }
else
    export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --height=50%"
fi

# Set the default command to use when input is tty - default is to set it to these in the order in which they"re found:
# - `rg --files --hidden --glob "!.git/*"`
# - `fd --type f --hidden --exclude .git`
# - `ag -l --hidden -g "" --ignore .git`,
export FZF_DEFAULT_COMMAND='fd --type file --strip-cwd-prefix --hidden --follow --exclude ".git"'

export FZF_DEFAULT_OPTS=${FZF_DEFAULT_OPTS}"
  --color=fg:#d0d0d0,bg:#121212,hl:#5f87af
  --color=fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff
  --color=info:#afaf87,prompt:#d7005f,pointer:#af5fff
  --color=marker:#87ff00,spinner:#af5fff,header:#87afaf"

# To apply the command to CTRL-T as well
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Preview file content using bat (https://github.com/sharkdp/bat)
export FZF_CTRL_T_OPTS='--walker-skip .git,node_modules,target \
--preview "bat -n --color=always {}" \
--bind "ctrl-/:change-preview-window(down|hidden|)"'

# CTRL-Y to copy the command into clipboard using pbcopy
export FZF_CTRL_R_OPTS='--bind "ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort" \
--color header:italic \
--header "Press CTRL-Y to copy command into clipboard"'

export FZF_CTRL_R_OPTS='\n--preview "echo {}" --preview-window down:3:hidden:wrap --bind "?:toggle-preview" --reverse --header "Press CTRL-Y to copy command into clipboard"'

# Unset vars to prevent them from being appended to multiple times if bash
# shells are nested and as a result .bashrc is sourced multiple times
unset FZF_ALT_C_OPTS FZF_CTRL_R_OPTS FZF_DEFAULT_OPTS

# If tree command is installed, show directory contents in preview pane when use Alt-C
if (( $+commands[tree] )); then
  export FZF_ALT_C_OPTS='--preview "tree -C {} | head -200"'
fi

# Use ~~ as the trigger sequence instead of the default **
export FZF_COMPLETION_TRIGGER='~~'

# Options to fzf command
export FZF_COMPLETION_OPTS='--border --info=inline'

# Disable keybindings - default: no
#export DISABLE_FZF_KEY_BINDINGS="true"
#export DISABLE_FZF_AUTO_COMPLETION="true"

(( $+commands[fzf] )) || return 1

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
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

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - This function generates a list of file paths for fzf completion.
# - The first argument to the function ($1) is the base path to start traversal.
# - It uses fd to recursively search for files, including hidden ones, while excluding .git directories.
# - The output is passed to fzf for interactive selection.
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

cd() {
  if [[ "$#" != 0 ]]; then
    builtin cd "$@"
    return
  fi
  while true; do
    local lsd=$(echo ".." && ls -d -- */)
    local dir="$(printf '%s\n' "${lsd[@]}" |
      fzf --reverse --preview '
            __cd_nxt="$(echo {})";
            __cd_path="$(echo $(pwd)/${__cd_nxt} | sed "s;//;/;")";
            echo $__cd_path;
            echo;
            ls -p --color=always "${__cd_path}";
    ')"
    [[ ${#dir} != 0 ]] || return 0
    builtin cd "$dir" &>/dev/null
  done
}
