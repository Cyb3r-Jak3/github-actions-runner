#!/bin/bash

# Copy GITHUB_TOKEN to TOFUENV_GITHUB_TOKEN if set
if [ -n "$GITHUB_TOKEN" ]; then
  export TOFUENV_GITHUB_TOKEN="$GITHUB_TOKEN"
fi
export GITHUB_OUTPUT="true"
tenv update-path