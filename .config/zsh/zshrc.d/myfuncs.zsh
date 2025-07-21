##? Get an Azure DB token
function azdbtok {
    local tok="$(az account get-access-token --resource https://ossrdbms-aad.database.windows.net --query accessToken --output tsv)"
    echo "$tok" | tee >(pbcopy) >(cat)
}

##? Show all extensions in current folder structure.
function allexts {
  find . -not \( -path '*/.git/*' -prune \) -type f -name '*.*' | sed 's|.*\.|\.|' | sort | uniq -c
}

##? Backup files or directories
function bak {
  local now f
  now=$(date +"%Y%m%d-%H%M%S")
  for f in "$@"; do
    if [[ ! -e "$f" ]]; then
      echo "file not found: $f" >&2
      continue
    fi
    cp -R "$f" "$f".$now.bak
  done
}

##? clone - clone a git repo
function clone {
  if [[ -z "$1" ]]; then
    echo "What git repo do you want?" >&2
    return 1
  fi
  local user repo
  if [[ "$1" = */* ]]; then
    user=${1%/*}
    repo=${1##*/}
  else
    user=mattmc3
    repo=$1
  fi

  local giturl="github.com"
  local dest=${XDG_PROJECTS_HOME:-~/Developer/repos}/$user/$repo

  if [[ ! -d $dest ]]; then
    git clone --recurse-submodules "git@${giturl}:${user}/${repo}.git" "$dest"
  else
    echo "No need to clone, that directory already exists."
    echo "Taking you there."
  fi
  cd $dest
}

##? noext - Find files with no file extension
function noext {
  # for fun, rename with: noext -exec mv '{}' '{}.sql' \;
  find . -not \( -path '*/.git/*' -prune \) -type f ! -name '*.*'
}


##? optdiff - show a diff between set options and Zsh defaults
function optdiff {
  tmp1=$(mktemp)
  tmp2=$(mktemp)
  zsh -df -c "set -o" >| $tmp1
  set -o >| $tmp2
  gdiff --changed-group-format='%<' --unchanged-group-format='' $tmp2 $tmp1
  rm $tmp1 $tmp2
}

##? Remove zwc files
function rmzwc {
  if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    echo "rmzwc"
    echo "  removes zcompiled files"
    echo "options:"
    echo " -q         Quiet"
    echo " --dry-run  Dry run"
    echo " -h --help  Show help screen"
    return 0
  fi

  local findprint="-print"
  local finddel="-delete"
  if [[ "$1" == '-q' ]]; then
    findprint=""
  elif [[ "$1" == "--dry-run" ]]; then
    finddel=""
  fi

  if [[ -d "${ZDOTDIR}" ]]; then
    find "${ZDOTDIR:A}" -type f \( -name "*.zwc" -o -name "*.zwc.old" \) $findprint $finddel
  fi
  find "$HOME" -maxdepth 1 -type f \( -name "*.zwc" -o -name "*.zwc.old" \) $findprint $finddel
  find . -maxdepth 1 -type f \( -name "*.zwc" -o -name "*.zwc.old" \) $findprint $finddel
}

##? substenv - substitutes string parts with environment variables
function substenv {
  if (( $# == 0 )); then
    subenv ZDOTDIR | subenv HOME
  else
    local sedexp="s|${(P)1}|\$$1|g"
    shift
    sed "$sedexp" "$@"
  fi
}

function tailf {
  local nl
  tail -f $2 | while read j; do
    print -n "$nl$j"
    nl="\n"
  done
}

##? touchf - makes any dirs recursively and then touches a file if it doesn't exist
function touchf {
  if [[ -n "$1" ]] && [[ ! -f "$1" ]]; then
    mkdir -p "$1:h" && touch "$1"
  fi
}

# works in both bash and zsh
##? up - go up any number of directories
up() {
  local parents=${1:-1}
  if ! (( "$parents" > 0 )); then
    echo >&2 "up: expecting a numeric parameter"
    return 1
  fi
  local i dotdot=".."
  for ((i = 1 ; i < parents ; i++)); do
    dotdot+="/.."
  done
  cd $dotdot
}

##? What's the weather?
function weather {
  curl "http://wttr.in/$1"
}

function zcompiledir {
  emulate -L zsh; setopt localoptions extendedglob globdots globstarshort nullglob rcquotes
  autoload -U zrecompile

  local f
  local flag_clean=false
  [[ "$1" == "-c" ]] && flag_clean=true && shift
  if [[ -z "$1" ]] || [[ ! -d "$1" ]]; then
    echo "Bad or missing directory $1" && return 1
  fi

  if [[ $flag_clean == true ]]; then
    for f in "$1"/**/*.zwc(.N) "$1"/**/*.zwc.old(.N); do
      echo "removing $f" && command rm -f "$f"
    done
  else
    for f in "$1"/**/*.zsh{,-theme}; do
      echo "compiling $f" && zrecompile -pq "$f"
    done
  fi
}

##? Echo to stderror
function echoerr {
  echo >&2 "$@"
}

##? Pass thru for copy/paste markdown
#function $ { $@ }

##? Check if a file can be autoloaded by trying to load it in a subshell.
function is-autoloadable {
  ( unfunction $1 ; autoload -U +X $1 ) &> /dev/null
}

##? Check if a name is a command, function, or alias.
function is-callable {
  (( $+commands[$1] || $+functions[$1] || $+aliases[$1] || $+builtins[$1] ))
}

##? Check a string for case-insensitive "true" value (1,y,yes,t,true,o,on).
function is-true {
  [[ -n "$1" && "$1:l" == (1|y(es|)|t(rue|)|o(n|)) ]]
}



function mkdirvar {
  local dirvar
  for dirvar in $@; do
    [[ -n "$dirvar" ]] && [[ -n "${(P)dirvar}" ]] || continue
    [[ -d "${(P)dirvar}" ]] || mkdir -p "${(P)dirvar}"
  done
}

##? funcfresh - refresh function definition
function funcfresh {
  if ! (( $# )); then
    echo >&2 "funcfresh: Expecting function argument."
    return 1
  elif ! (( $+functions[$1] )); then
    echo >&2 "funcfresh: Function not found '$1'."
    return 1
  fi
  unfunction $1
  autoload -Uz $1
}

#
# Install missing application (dependency for the selected feature from this script to run properly)
#
# @param the Homebrew formula name
# @param the website for the application
#
installApp(){
    application="$1"
    website="$2"

    if [[ $(which brew | grep "not found") ]] ;
    then
        read -p 'Homebrew need to be installed: install it? [Y/n]: ' ANSWER

        if [[ ! "$ANSWER" || "$ANSWER" == "Y" || "$ANSWER" == "y" ]] ;
        then
            curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
        else
            print "Please install ${YELLOW}Homebrew${NOFORMAT} or ${YELLOW}$application${NOFORMAT} manually (see $website for instructions) and run the script again."
            exit
        fi
    fi

    confirmation=$(gum confirm "$application needs to be installed to run this command. Do you want to install it?" && print "true" || print "false")
    if [[ "$confirmation" == "true" ]] ; then
        tput sc
        brew install "$application"
        tput rc
        tput ed
    else
        print "$application not installed. Install it manually (see $website for instructions) and run the script again."
        exit
    fi
}

#
# Clear last terminal line
#
__clearLastLine(){
    tput cuu 1 >&2
    tput el >&2
}

#
# Select a file from the running directory
#
# @param file type (Images, PDFs...)
# @param file extension (.pdf, .png, .jpg). If multiple extensions, use ".png|.jpeg"
#
# Return the file selected by the user
#
getFile(){
    files=$(/bin/ls | grep -E "$2")
    __clearLastLine #I cannot get the error output to silence!
    file;

    if [[ $files ]] ; then
        print "Please select a ${YELLOW}$1${NOFORMAT}" >&2
        file=$(/bin/ls  | sort -f | grep -E "$2" | gum choose)
    else
        print "No $1 in this folder: you need to enter the ${YELLOW}full path of the $1${NOFORMAT} manually" >&2
        file=$(gum input --placeholder "$HOME/Downloads/your-file$2")
    fi

    clearLastLine
    print "$file"
}

#
# Check if the user will have to enter the password when needing root access using sudo
#
# @param the reason why sudo is needed
#
# return 0 if not needed, 1 if it is
#
__checkSudo(){
    sudo -n true 2>/dev/null
    sudo_needed=$(echo $?)

    if [[ $sudo_needed == 1 ]] ; then
        print
        gum format -- "sudo is require to $1"
        print
    fi
}

#
# Get the file name without the extension
#
# @param file
#
# return file name
#
__getFilename(){
    echo "${1%.*}"
}

#
# Get the file extension
#
# @param file
#
# return file extension
#
__getFileExtension(){
    echo "${1##*.}"
}

# quickly edit or run scripts from my scripts directory
dot_scripts() {
  var=$(gum choose "edit" "run" --item.foreground="360" --cursor="→ ")
  script=$(find ${XDG_CONFIG_HOME} -type f | sort | fzf --height=12 --cycle -d"/" --with-nth=6.. --reverse)
  case $var in
    edit)
      printf "%s\n" "$script"|xargs nvim ;;
    run)
      sh $script ;;
  esac
}

# quickly edit zsh config stuff
edit_zsh() {
  var=$(gum choose "zshrc" "functions" "aliases" "zshenv" --item.foreground="360" --cursor="→ ")
  case $var in
    zshrc)
      $EDITOR $HOME/.config/zsh/.zshrc ;;
    functions)
      $EDITOR $HOME/.config/zsh/zshrc.d/myfuncs.zsh ;;
    aliases)
      $EDITOR $HOME/.config/zsh/zshrc.d/myaliases.zsh ;;
    zshenv)
      $EDITOR $HOME/.config/zsh/.zshenv ;;
  esac
}

# quickly edit config files
edit_configs() {
  file=$(fd . "$HOME/.config" -t f -d 2 | fzf -d"/" --with-nth -1.. --height=95%)
  [ -z "$file" ] || $EDITOR $file
}

# quickly copy a file or directory from ~/Downloads to current directory
cpd() {
  file=$(fd . "$HOME/Downloads" -t f|fzf -d"/" --with-nth -1.. --height=95%)
  [ ! -z "$file" ] && cp $file . && gum confirm "Delete the original file?" && rm $file || exit 1
}

# quickly access any alias or function i have
qa() { eval "$( (alias && functions | sed -nE 's@^([^_].*)\(\).*@\1@p') | cut -d'=' -f1 | fzf --reverse)" }

# get cheat sheet for a command
chst() {
  [ -z "$*" ] && printf "Enter a command name: " && read -r cmd || cmd=$*
  curl -s cheat.sh/$cmd|bat --style=plain
}

# create a directory and enter it
mkcd() { mkdir -p "$1" && cd "$1"; }

# Make dir and copy
mkcp() {
  dir="$2"
  tmp="$2"; tmp="${tmp: -1}"
  [ "$tmp" != "/" ] && dir="$(dirname "$2")"
  [ -d "$dir" ] ||
    mkdir -p "$dir" &&
    cp -r "$@"
}

# Move dir and move into it
mkmv() {
  dir="$2"
  tmp="$2"; tmp="${tmp: -1}"
  [ "$tmp" != "/" ] && dir="$(dirname "$2")"
  [ -d "$dir" ] ||
      mkdir -p "$dir" &&
      mv "$@"
}

# use fzf with tree preview to go into a directory
# change_folder() {
#   CHOSEN=$(fd '.' -d 1 -H -t d $DIR|fzf --cycle --height=95% --preview="exa -T {}" --reverse)
#   [ -z $CHOSEN ] && return 0 || cd "$CHOSEN" && [ $(ls|wc -l) -le 60 ] && ls
# }

# search for file and go into its directory
# ji() {
#    file=$(fzf -q "$1") && dir=$(dirname "$file") && cd "$dir"
# }

### Fzf functions

# Modified version where you can press
#   - CTRL-O to open with `open` command,
#   - CTRL-E or Enter key to open with the $EDITOR
# fo() {
#   IFS=$'\n' out=("$(fzf-tmux --query="$1" --exit-0 --expect=ctrl-o,ctrl-e)")
#   key=$(head -1 <<< "$out")
#   file=$(head -2 <<< "$out" | tail -1)
#   if [ -n "$file" ]; then
#     [ "$key" = ctrl-o ] && open "$file" || ${EDITOR:-vim} "$file"
#   fi
# }
