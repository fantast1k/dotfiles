#!/usr/bin/env bash

# Performs actions for allowing to migrate dotfiles to needed place

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cp `find "$DIR" -name ".*" -d 1` ~/
