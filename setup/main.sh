#!/bin/zsh

echo "Hi! Setting up your configs now."

# TODO: ask the user if they want to use bash or zsh

# TODO: check if were in the root of the dotfiles project, if not, cd to it

# TODO: ask what type of config the user would like to init (work, personal)

# TODO: setup tmux

# TODO: setup nvim (git clone)

# ln -s $PWD/../zsh/work.zshrc ~/.zshrc
ln -s $PWD/../zsh/work.zsh_aliases ~/.zsh_aliases
ln -s $PWD/../zsh/work.zsh_functions ~/.zsh_functions

source ~/.zshrc

