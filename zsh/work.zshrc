# =======================
# Aliases and Functions
# =======================
# Source aliases
[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases

# Source custom functions
[ -f ~/.zsh_functions ] && source ~/.zsh_functions

# =======================
# Environment Variables
# =======================
# Load environment variables from .env if it exists
# [ -f .env ] && export $(grep -v '^#' .env | xargs)
[ -f "$HOME/.env" ] && export $(grep -v '^#' "$HOME/.env" | xargs)

# SDKMAN setup
export SDKMAN_DIR="$HOME/.sdkman"
[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# Node.js and npm
export PATH="/opt/homebrew/opt/node@20/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/node@20/lib"
export CPPFLAGS="-I/opt/homebrew/opt/node@20/include"

# Jasypt
export PATH="$PATH:/Users/brianmatzelle/Downloads/jasypt-1.9.3/bin"

# pipx
export PATH="$PATH:/Users/brianmatzelle/.local/bin"

# Maven
export PATH="$PATH:/Users/brianmatzelle/manual-installs/apache-maven-3.9.8/bin"

# Spicetify
export PATH="$PATH:/Users/brianmatzelle/.spicetify"

# Additional manual installs
export PATH="$PATH:~/manual-installs"

# Crypttool
export PATH="$PATH:/Users/brianmatzelle/manual-installs/sempl"

# Perl setup
export PATH="/Users/brianmatzelle/perl5/bin:$PATH"
export PERL5LIB="/Users/brianmatzelle/perl5/lib/perl5:$PERL5LIB"
export PERL_LOCAL_LIB_ROOT="/Users/brianmatzelle/perl5:$PERL_LOCAL_LIB_ROOT"
export PERL_MB_OPT="--install_base \"/Users/brianmatzelle/perl5\""
export PERL_MM_OPT="INSTALL_BASE=/Users/brianmatzelle/perl5"

# Java (OpenJDK)
export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"

# ICU
export PATH="/opt/homebrew/opt/icu4c@76/bin:$PATH"
export PATH="/opt/homebrew/opt/icu4c@76/sbin:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Personal projects
export farm="$HOME/personal-projects/farm"

# =======================
# Command Line Enhancements
# =======================
# oh-my-posh
eval "$(oh-my-posh init zsh --config $(brew --prefix oh-my-posh)/themes/amro.omp.json)"

# =======================
# Conda Initialization
# =======================
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/brianmatzelle/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/brianmatzelle/anaconda3/etc/profile.d/conda.sh" ]; then
        source "/Users/brianmatzelle/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/brianmatzelle/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# =======================
# Miscellaneous
# =======================
# bun completions
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# Run .local.zshrc if it exists
[ -f "$HOME/.dotlocaldotzshrc" ] && source "$HOME/.dotlocaldotzshrc"

# Optional tmux initialization
#if [[ -z "$TMUX" ]]; then
#    ts
#fi


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export DISPLAY=:0
d() {
    if [ "$(basename "$PWD")" = "qatests" ]; then
        docker compose run --rm "$(basename "$(dirname "$PWD")")" "$@"
    else
        echo "❌ You must run this command from a directory that contains a qatests directory"
        return 1
    fi
}
dpt() {
    if [ "$(basename "$PWD")" = "qatests" ]; then
        docker compose run --rm "$(basename "$(dirname "$PWD")")" pt "$@"
    else
        echo "❌ You must run this command from a directory that contains a qatests directory"
        return 1
    fi
}
dptk() {
    if [ "$(basename "$PWD")" = "qatests" ]; then
        docker compose run --rm "$(basename "$(dirname "$PWD")")" ptk "$@"
    else
        echo "❌ You must run this command from a directory that contains a qatests directory"
        return 1
    fi
}
dptkh() {
    if [ "$(basename "$PWD")" = "qatests" ]; then
        docker compose run --rm "$(basename "$(dirname "$PWD")")" ptkh "$@"
    else
        echo "❌ You must run this command from a directory that contains a qatests directory"
        return 1
    fi
}
