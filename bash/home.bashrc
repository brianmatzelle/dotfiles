# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
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

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

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

# Created by `pipx` on 2024-07-12 02:09:27
export PATH="$PATH:/home/brian/.local/bin"
#eval "$(register-python-argcomplete pipx)"

export PATH="$PATH:/usr/local/cuda/bin/nvcc"

alias reload='source ~/.bashrc'
alias edit-bashrc='nvim ~/.bashrc'
export PATH="$PATH:/home/brian/manual-installs/bin"
export PYTHONPATH="$PYTHONPATH:/home/brian/manual-installs/lib/python"
export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
alias restart-refhub-service='sudo systemctl stop refhub-api.service && sudo systemctl start refhub-api.service && sudo systemctl status refhub-api.service'
alias status-refhub-api='sudo systemctl status refhub-api.service'
alias restart-goonscreen='sudo systemctl stop goonscreen.service && sudo systemctl start goonscreen.service && sudo systemctl status goonscreen.service'

alias restart-asdftype='sudo systemctl stop asdftype && sudo systemctl disable asdftype && sudo systemctl start asdftype && sudo systemctl enable asdftype && sudo systemctl status asdftype'
alias restart-botparty-workers='sudo systemctl stop botparty-workers && sudo systemctl disable botparty-workers && sudo systemctl start botparty-workers && sudo systemctl enable botparty-workers && sudo systemctl status botparty-workers'
alias restart-botparty-api='sudo systemctl stop botparty-api && sudo systemctl disable botparty-api && sudo systemctl start botparty-api && sudo systemctl enable botparty-api && sudo systemctl status botparty-api'
# alias restart-botparty-temporal='sudo systemctl stop botparty-temporal && sudo systemctl disable botparty-temporal && sudo systemctl start botparty-temporal && sudo systemctl enable botparty-temporal && sudo systemctl status botparty-temporal'


alias restart-botparty-session-worker='sudo systemctl stop botparty-session-worker && sudo systemctl disable botparty-session-worker && sudo systemctl start botparty-session-worker && sudo systemctl enable botparty-session-worker && sudo systemctl status botparty-session-worker'
alias restart-botparty-append-worker='sudo systemctl stop botparty-append-worker && sudo systemctl disable botparty-append-worker && sudo systemctl start botparty-append-worker && sudo systemctl enable botparty-append-worker && sudo systemctl status botparty-append-worker'
alias restart-botparty-update-subs-worker='sudo systemctl stop botparty-update-subs-worker && sudo systemctl disable botparty-update-subs-worker && sudo systemctl start botparty-update-subs-worker && sudo systemctl enable botparty-update-subs-worker && sudo systemctl status botparty-update-subs-worker'
alias restart-botparty-user-worker='sudo systemctl stop botparty-user-worker && sudo systemctl disable botparty-user-worker && sudo systemctl start botparty-user-worker && sudo systemctl enable botparty-user-worker && sudo systemctl status botparty-user-worker'

alias restart-botparty-workers='restart-botparty-session-worker && restart-botparty-append-worker && restart-botparty-update-subs-worker && restart-botparty-user-worker'
alias stop-botparty='sudo systemctl stop botparty-workers && sudo systemctl stop botparty-api'
alias start-botparty='sudo systemctl start botparty-workers && sudo systemctl start botparty-api'
alias restart-botparty='stop-botparty && start-botparty'


alias stop-election-crawler-workers="sudo systemctl stop worker && sudo systemctl stop worker2"
alias start-election-crawler-workers="sudo systemctl start worker && sudo systemctl start worker2"
alias restart-election-crawler-workers="sudo systemctl daemon-reload && stop-election-crawler-workers && start-election-crawler-workers && sudo systemctl status worker"


# activate python venv function
av() {
  for dir in venv .venv; do
    if [ -d "$dir" ]; then
      source "$dir/bin/activate"
      echo "$dir activated"
      echo "using python $(which python)"
      echo "$(python --version)"
      return
    fi
  done
  echo "No virtual environment named venv or .venv found in the current directory."
}


alias temporal="/home/brian/manual-installs/temporal"

export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH="$HOME/.local/bin:$PATH"

export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# add XMR program paths 
alias p2pool="/home/brian/manual-installs/p2pool-v4.3-linux-x64/p2pool"
alias monerod="/home/brian/manual-installs/monero-x86_64-linux-gnu-v0.18.3.4/monerod --data-dir=/mnt/ssd/monero_node"
alias xmrig="/home/brian/manual-installs/xmrig-6.22.2/xmrig"

# XMR address
export XMR_ADDR="47WC1uM8naA5PNteEiHtJC5wrmei1mcrYFLe4py2kYCrGwXvHEDNeHQhBhLAeQXK3ZL3ZANQ6ymYuRAAsGQxtvxKPfgx14S"

# start hosting
#alias start-monerod="sudo /home/brian/manual-installs/monero-x86_64-linux-gnu-v0.18.3.4/monerod --data-dir=/mnt/ssd/monero_node --zmq-pub tcp://127.0.0.1:18083 --out-peers 32 --in-peers 64 --add-priority-node=p2pmd.xmrvsbeast.com:18080 --add-priority-node=nodes.hashvault.pro:18080 --disable-dns-checkpoints --enable-dns-blocklist"
alias start-monerod="sudo /home/brian/manual-installs/monero-x86_64-linux-gnu-v0.18.3.4/monerod --data-dir=/mnt/ssd/monero_node --zmq-pub tcp://127.0.0.1:18083 --out-peers 32 --in-peers 64 --enable-dns-blocklist"
alias start-p2pool="p2pool --host 127.0.0.1 --wallet $XMR_ADDR"
alias start-mini-p2pool="p2pool --host 127.0.0.1 --wallet $XMR_ADDR --mini"

alias bl-email='sudo mutt -f /home/blindlily/Maildir'
export PATH=$PATH:/usr/local/go/bin

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

alias start-mc-server="java -Xmx2G -Xms1G -jar ~/minecraft-server/server.jar nogui"

alias mp='multipass'

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

eval "$(oh-my-posh init bash --config $(brew --prefix oh-my-posh)/themes/emodipt.omp.json)"
export PATH=~/.npm-global/bin:$PATH
