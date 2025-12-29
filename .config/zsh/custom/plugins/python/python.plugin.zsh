#
# python - Aliases and functions for python
#

# python aliases
alias py3='python3'
alias py='python'
alias pyfind='find . -name "*.py"'
alias pygrep='command grep --include="*.py"'

function pyclean {
  # Clean common python cache files.
  find "${@:-.}" -type f -name "*.py[co]" -delete
  find "${@:-.}" -type d -name "__pycache__" -delete
  find "${@:-.}" -depth -type d -name ".mypy_cache" -exec rm -r "{}" +
  find "${@:-.}" -depth -type d -name ".pytest_cache" -exec rm -r "{}" +
}

# # >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/Users/mh/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/Users/mh/miniconda3/etc/profile.d/conda.sh" ]; then
#         . "/Users/mh/miniconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="$PATH:/Users/mh/miniconda3/bin"
#     fi
# fi
# unset __conda_setup
# # <<< conda initialize <<<
