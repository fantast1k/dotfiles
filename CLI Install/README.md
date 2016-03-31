# Installing software using Command Line Interface

# Prerequisites

## Using prepare.sh
Some scripts may want to use Assistive Touch from Terminal which is not enabled by default for Terminal, so just in case you don’t know is script going to need Assistive Touch at first run `prepare.sh` script. After you finish all you job for installing software run `teardown.sh` to disable Assistive Touch for Terminal

# The use

## Use of xcode_command_line_tools.sh
That script is simply installs standalone Xcode Command Line Tools, keep in mind it requires Assistive Touch and going to accept License Agreement for you automatically.

## Use of Xcode.sh
That scripts installs Xcode by using AppStore, so you Apple ID credentials be needed. Use that script like:
```bash
echo -e “AppleId
ApplePassword” | xcode.sh
```

## Use of google_chrome.sh
That scripts simply takes the last Google Chrome from website, mount an given image, copy it to Application folder and dismount an image and clear downloaded image

## Use of brew.sh
That script simply install missing OS X package manager

## Use of brew_packages.sh
That script simply installs interested packages using brew

## Use of gem_packages.sh
This script updates and installs interested gems. Careful note: since OS X El Capitan gems gonna be installed to /usr/local/bin, so all installed gems be removed and their new versions installed to /usr/local/bin. New gems also be installed the same path