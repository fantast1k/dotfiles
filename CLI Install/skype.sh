#!/usr/bin/env bash

# This script simply takes latest skype and installs it into Application 
# folder

temp=$TMPDIR$(uuidgen)
mkdir -p $temp/mount
curl -L https://get.skype.com/go/getskype-macosx > $temp/1.dmg
yes | hdiutil attach -noverify -nobrowse -mountpoint $temp/mount $temp/1.dmg
cp -r $temp/mount/*.app /Applications
hdiutil detach $temp/mount
rm -r $temp
