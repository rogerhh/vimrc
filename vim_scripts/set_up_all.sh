#!/bin/bash

echo $HOME

cd ~
mkdir -p $HOME/.config/nvim
echo "source $HOME/vimrc/nvim/config/init.vimrc" > "$HOME/.config/nvim/init.vim"
