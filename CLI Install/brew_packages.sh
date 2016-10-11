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

# Install development packages
brew install git
brew install bash-completion
brew install carthage
brew install hockey

# If you have home server or machines you want to wake up on lan
brew install wakeonlan

# Install brew cask programs
brew cask install transmission
brew cask install keepingyouawake

# Remove outdated packages
brew cleanup
