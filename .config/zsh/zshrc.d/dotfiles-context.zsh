# =============================================================================
# dotfiles-context.zsh
# =============================================================================
# Sets up context detection for dotfiles management to help Warp AI
# understand when to suggest `dot` commands vs regular `git` commands.

# Load the context function
autoload -Uz dotfiles_context

# Hook into directory changes to update context
autoload -U add-zsh-hook
add-zsh-hook chpwd dotfiles_context

# Set initial context
dotfiles_context
