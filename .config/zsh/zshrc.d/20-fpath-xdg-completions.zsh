# Ensure XDG_DATA_HOME zsh completions directory is on fpath
: ${XDG_DATA_HOME:=$HOME/.local/share}
local xdg_completions_dir="$XDG_DATA_HOME/zsh/completions"
if [[ -d "$xdg_completions_dir" ]]; then
  case " ${fpath} " in
    *" $xdg_completions_dir "*) ;;
    *) fpath=($xdg_completions_dir $fpath) ;;
  esac
fi
