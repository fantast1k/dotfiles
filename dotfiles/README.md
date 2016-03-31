# A set of useful dotfiles under your home directory

## Prerequisite
I, personally, have 2 files under mine home directory that performs my set up and those which don’t need to be committed into the repository.  One of them is `.path` that modifies `$PATH` variable in an appropriate way and file `.extra` which performs additional individual setup. Consider an example of `.extra` file:
```bash
#! /usr/bin/env bash

# Installs some private vars

GIT_AUTHOR_NAME="Dmitry Fa[n]tastik"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
git config --global user.name "$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="dmitry.fantastik@gmail.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git config --global user.email "$GIT_AUTHOR_EMAIL"
```