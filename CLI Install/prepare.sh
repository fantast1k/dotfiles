#!/usr/bin/env bash

# At first prepare our script for run correctly

# Enable Assitive Touch for Terminal so we don't need 
# to answer popped up windows and can use scripts
sudo touch /private/var/db/.AccessibilityAPIEnabled

# Add sqlite entry that allows terminal for assistive touch
sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "UPDATE access SET allowed=1 WHERE service='kTCCServiceAccessibility' AND client='com.apple.Terminal'"
