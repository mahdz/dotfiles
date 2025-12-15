# Automatically "Warpify" subshells
# printf '\eP$f{"hook": "SourcedRcFileForWarp", "value": { "shell": "zsh"}}\x9c'

# Disable Warp hooks when agent bridge fails
#if [[ -n "$WARP_IS_INSIDE" ]]; then
#  disable_warp_hooks() {
#    unset -f warp_preexec warp_precmd warp_send_json_message warp_maybe_send_reset_grid_osc
#  }

  # Automatically disable if warp-agent not found
#  if ! pgrep -x "warp-agent" >/dev/null; then
#    disable_warp_hooks
#  fi
#fi

# Disable pagers in non-interactive environments (e.g., Cline IDE) and VSCode
if [[ -n "$CLINE_ACTIVE" || "$TERM_PROGRAM" == "vscode" ]]; then
    export TERM=xterm-256color
    export PAGER="/bin/cat"
    export GIT_PAGER="/bin/cat"
    export SYSTEMD_PAGER="/bin/cat"
    export LESS="-FRX"
    PS1="%n@%m %1~ %# "

    # https://code.visualstudio.com/docs/terminal/shell-integration
    source "$(code --locate-shell-integration-path zsh)"
fi
