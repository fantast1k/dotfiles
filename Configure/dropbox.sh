#!/usr/bin/env bash

# This script removes Dropbox green icon on finder

file=/Applications/Dropbox.app/Contents/Resources/emblem-dropbox-uptodate.icns
[ -e "${file}" ] && mv -f "${file}" "${file}.bak"
