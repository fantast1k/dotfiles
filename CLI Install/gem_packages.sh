#!/usr/bin/env bash

# This script install useful gems

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Update gem to the latest
sudo gem update --system

# Reinstall packages into /usr/local/bin since El Capitan
GEMS=`gem list --no-versions | tail -n+1`
GEMS=`echo "$GEMS" | tr '\n' ' '`
sudo gem install "$GEMS" -n/usr/local/bin

sudo gem install cocoapods -n/usr/local/bin

sudo gem cleanup
