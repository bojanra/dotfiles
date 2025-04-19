# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# use the powerline-go for a fancy prompt
# https://github.com/justjanne/powerline-go
function _update_ps1() {
  PS1="$(powerline-go \
    -ignore-repos $HOME \
    -alternate-ssh-icon \
    -colorize-hostname \
    -hostname-only-if-ssh \
    -git-mode compact \
    -error $? \
    -newline)"
}

PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# replace ls with eza
# https://eza.rocks/
alias ls='eza --color=auto --git --icons --hyperlink'
alias l='eza --color=auto --git --icons --hyperlink -l -F'
alias ll='eza -la --group-directories-first'
alias lt='ls -l --tree --level=2'

# replace cat with bat
# https://github.com/sharkdp/bat/
alias cat='batcat'
export BAT_STYLE=header

# faster ack
export RIPGREP_CONFIG_PATH=~/.ripgreprc
export FZF_DEFAULT_COMMAND='rg --files .'
export FZF_DEFAULT_OPTS="--layout=reverse --info=inline --preview 'batcat {} --color=always'"
alias ack='rg'

# handy aliases
alias h='history'
alias df='df -h'
alias j='jobs -l'
alias less='less -i'
alias duu='du -mcs * .[!.]* | sort -n'
alias c='clear'
alias mgrep="ps aux | grep -v grep | grep"
alias grep="grep --ignore-case --color"

# git alias
alias gs="git status -bs"
alias gd="git difftool -d"
alias ga="git add"
alias gb="git branch -avv"
alias gc="git commit -v"
alias gca="git commit -am"
alias gstashed="git stash list --pretty=format:'%gd: %Cred%h%Creset %Cgreen[%ar]%Creset %s'"
alias gl="git log -30 --graph --all --pretty='%C(yellow)%h%C(green)%d%Creset %s %C(red)(%ar) %C(blue)<%an>'"
alias gla="git log --graph --all --pretty='%C(yellow)%h%C(green)%d%Creset %s %C(red)(%ar) %C(blue)<%an>'"
alias gll="git log --graph --pretty=format:'%C(red)%h%Creset -%C(yellow)%d%Creset %s %C(green)(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gls="git ls-tree --full-tree -r --name-only HEAD"
alias gclean="git clean -nxd"

# vagrant alias
alias vup="vagrant up"
alias vsu="vagrant suspend"
alias vss="vagrant ssh"
alias vde="vagrant destroy"
alias vpr="vagrant provision"

alias diff='colordiff'
alias path='echo -e ${PATH//:/\\n}'
alias root="sudo su -"
alias bigdirs='du --max-depth=1 2> /dev/null | sort -n -r | head -n20'
alias locate='locate -i'
alias n=nvim

# bartib - time tracking
# https://github.com/nikolassv/bartib
export BARTIB_FILE=~/02_personal/bartib_timetracking.log

_bartib_completions() {
  local CWORD=${COMP_WORDS[COMP_CWORD]}
  ALL_PROJECTS=$(bartib projects)

  local IFS=$'\n'
  CANDIATE_PROJECTS=($(compgen -W "${ALL_PROJECTS[*]}" -- "$CWORD"))

  if [ ${#CANDIATE_PROJECTS[*]} -eq 0 ]; then
    COMPREPLY=()
  else
    COMPREPLY=($(printf "\"%s\"\n" "${CANDIATE_PROJECTS[@]}"))
  fi
}
complete -F _bartib_completions bartib

# autochange directory without cd
# - type the directory name to change into
shopt -s autocd

export EDITOR=/usr/bin/nvim

source ~/.config/lf/lf.bash
export LF_BOOKMARK_PATH=~/.config/lf/bookmark

# McFly - fly through your shell history
# https://github.com/cantino/mcfly
if [[ -r ~/bin/mcfly.bash ]]; then
  source ~/bin/mcfly.bash
fi

source ~/bin/key-bindings.bash
source ~/bin/completion.bash

# using ripgrep combined with preview
# find-in-file - usage: fif <searchTerm>
fif() {
  if [ ! "$#" -gt 0 ]; then
    echo "Need a string to search for!"
    return 1
  fi
  rg --files-with-matches --no-messages "$1" | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}"
}

# fkill - kill processes - list only the ones you can kill. Modified the earlier script.
fkill() {
  local pid
  if [ "$UID" != "0" ]; then
    pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
  else
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  fi

  if [ "x$pid" != "x" ]; then
    echo $pid | xargs kill -${1:-9}
  fi
}

# taken from https://junegunn.github.io/fzf/examples/git/
# ripgrep->fzf->vim [QUERY]
# rfv [querystring]
rfv() (
  RELOAD='reload:rg --column --color=always --smart-case {q} || :'
  OPENER='if [[ $FZF_SELECT_COUNT -eq 0 ]]; then
            nvim {1} +{2}     # No selection. Open the current line in Vim.
          else
            nvim {+f}  # Build quickfix list for the selected items.
          fi'
  fzf --disabled --ansi --multi \
    --bind "start:$RELOAD" --bind "change:$RELOAD" \
    --bind "enter:become:$OPENER" \
    --bind "ctrl-o:execute:$OPENER" \
    --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
    --delimiter : \
    --preview 'batcat --style=full --color=always --highlight-line {2} {1}' \
    --preview-window '~4,+{2}+4/3,<80(up)' \
    --query "$*"
)

# This is the list for lf icons:
export LF_ICONS="di=📁:\
fi=📃:\
tw=🤝:\
ow=📂:\
ln=⛓:\
or=❌:\
ex=🎯:\
*.txt=✍:\
*.mom=✍:\
*.me=✍:\
*.ms=✍:\
*.png=🖼:\
*.webp=🖼:\
*.ico=🖼:\
*.jpg=📸:\
*.jpe=📸:\
*.jpeg=📸:\
*.gif=🖼:\
*.svg=🗺:\
*.tif=🖼:\
*.tiff=🖼:\
*.xcf=🖌:\
*.html=🌎:\
*.xml=📰:\
*.gpg=🔒:\
*.css=🎨:\
*.pdf=📚:\
*.djvu=📚:\
*.epub=📚:\
*.csv=📓:\
*.xlsx=📓:\
*.tex=📜:\
*.md=📘:\
*.r=📊:\
*.R=📊:\
*.rmd=📊:\
*.Rmd=📊:\
*.m=📊:\
*.mp3=🎵:\
*.opus=🎵:\
*.ogg=🎵:\
*.m4a=🎵:\
*.flac=🎼:\
*.wav=🎼:\
*.mkv=🎥:\
*.mp4=🎥:\
*.webm=🎥:\
*.mpeg=🎥:\
*.avi=🎥:\
*.mov=🎥:\
*.mpg=🎥:\
*.wmv=🎥:\
*.m4b=🎥:\
*.flv=🎥:\
*.zip=📦:\
*.rar=📦:\
*.7z=📦:\
*.tar.gz=📦:\
*.z64=🎮:\
*.v64=🎮:\
*.n64=🎮:\
*.gba=🎮:\
*.nes=🎮:\
*.gdi=🎮:\
*.1=ℹ:\
*.nfo=ℹ:\
*.info=ℹ:\
*.log=📙:\
*.iso=📀:\
*.img=📀:\
*.bib=🎓:\
*.ged=👪:\
*.part=💔:\
*.torrent=🔽:\
*.jar=♨:\
*.java=♨:\
"
