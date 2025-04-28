#!/bin/bash

echo "PATH=$PATH:$HOME/.local/bin:$HOME/.tofuenv/bin" >> "$GITHUB_ENV"
echo export TOFUENV_ROOT="$HOME/.tofuenv" >> "$GITHUB_ENV"