#!/usr/bin/env bash

# Install OS X dmg into USB hdd-drive

INSTALL=$1
VOLUME=$2

if [ $# -ne 2 ] || [ -z "$INSTALL" ] || [ -z "$VOLUME" ]; then
    echo "Use this script with name of OS X installation file and USB hdd volume name"
    echo "For example:"
    echo "prepare_for_install.sh 'Install OS X El Capitan' 'Untitled'"
    exit 1
fi

APP="/Applications/$INSTALL.app/Contents/Resources/createinstallmedia"
VOLUME="/Volumes/$VOLUME"
INSTALL="/Applications/$INSTALL.app"

exec sudo "$APP" --volume "$VOLUME" --applicationpath "$INSTALL" --nointeraction