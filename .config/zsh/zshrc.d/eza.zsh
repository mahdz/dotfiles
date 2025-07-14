#
# eza: Customize ls-replacement
#

# Load eza aliases if available.
(( $+commands[eza] )) || return

alias lt='eza --icons --tree'
unalias l
alias l='ls -l'
alias la='ls -lAh'


alias ll="eza -lahF --icons"                                                                         # Show details
alias lm="eza -lbGd --header --git --sort=modified --color=always --group-directories-first --icons" # Recent
alias lb="eza -lahr --color-scale --icons -s=size"                                                   # Largest / size
# File listing options
alias lh="eza -dl .* --group-directories-first"
alias lr="ls -R"                              # List files in sub-directories, recursivley
alias lf="eza -lF --color=always | command grep -v /" # Use grep to find files
alias lc="find . -type f | wc -l"             # Shows number of files
alias ld="eza -lD"                            # List directories only
