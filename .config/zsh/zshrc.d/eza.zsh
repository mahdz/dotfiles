#
# eza: Customize ls-replacement
#

# Load eza aliases if available.
(( $+commands[eza] )) || return

# Disable icons/hyperlinks over SSH or when TERM is dumb
if [[ -n $SSH_CONNECTION ]] || [[ -z ${TERM:-} ]] || [[ $TERM = dumb ]]; then
    EZA_ICONS_FLAG="--icons=never"
    EZA_HYPERLINK_FLAG=""
else
    EZA_ICONS_FLAG="--icons=auto"
    EZA_HYPERLINK_FLAG="--hyperlink"
fi

# Core replacement
# alias ls="eza -ghabG --header --group-directories-first $EZA_ICONS_FLAG $EZA_HYPERLINK_FLAG --color=auto"

# Most-used shortcuts
alias l="eza -lahbG --header --group-directories-first $EZA_ICONS_FLAG $EZA_HYPERLINK_FLAG --color=auto"  # long, all, human, git, header
alias ll="eza -laFh --group-directories-first $EZA_ICONS_FLAG $EZA_HYPERLINK_FLAG --color=auto"             # detailed long
# alias la="eza -la --group-directories-first $EZA_ICONS_FLAG $EZA_HYPERLINK_FLAG --color=auto"                # show dotfiles

# Handy utilities
# alias lt="eza -lah --sort=newest --group-directories-first $EZA_ICONS_FLAG $EZA_HYPERLINK_FLAG --color=auto"  # newest first
# alias lb="eza -lahr --sort=size --color-scale --group-directories-first $EZA_ICONS_FLAG $EZA_HYPERLINK_FLAG"  # largest files
