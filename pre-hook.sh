#!/bin/bash

source $HOME/.nvm/nvm.sh

{
    echo PATH=$PATH:$HOME/.local/bin:$HOME/.tofuenv/bin
    echo TOFUENV_ROOT="$HOME/.tofuenv"
    echo NVM_DIR="$HOME/.nvm "
} >> "$GITHUB_ENV"