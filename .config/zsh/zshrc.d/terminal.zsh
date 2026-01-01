case "${TERM_PROGRAM:l}" in
  apple_terminal)
    export SHELL_SESSIONS_DISABLE=1
    ;;
  vscode)
    # https://code.visualstudio.com/docs/terminal/shell-integration
    export TERM=xterm-256color
    export PAGER="/bin/cat"
    export GIT_PAGER="/bin/cat"
    export SYSTEMD_PAGER="/bin/cat"
    export LESS="-FRX"
    PS1="%n@%m %1~ %# "

    # https://code.visualstudio.com/docs/terminal/shell-integration
    source "$(code --locate-shell-integration-path zsh)"
    ;;
esac