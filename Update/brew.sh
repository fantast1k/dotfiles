#!/usr/bin/env bash

# This script install brew packages

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Make sure we have latest brew
brew update

# Upgrade any already installed packages
brew upgrade --all

# Remove outdated versions
brew cleanup
