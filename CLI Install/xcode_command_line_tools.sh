#!/usr/bin/env bash

# Install command line tools

xcode-select --install
sleep 1
osascript <<EOD
  tell application "System Events"
    tell process "Install Command Line Developer Tools"
      keystroke return
      delay 2
      click button "Agree" of window "License Agreement"
    end tell
  end tell
EOD
