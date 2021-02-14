#!/bin/bash

# Usage:
#
#   $ sudo -s
#   # source $(basename $0)
#
#   Known Bug: ceremcem/erik-sync#2

_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }
cd $_sdir
hd="zencefil"
source ./config.sh
dev="/dev/disk/by-id/$wwn"
echo "---------------------------------"
echo "Please unplug $hd."
while sleep 1; do test -b "$dev" || break; done;
echo "---------------------------------"
echo "Waiting for $hd to attach..."
while sleep 1; do test -b "$dev" && break; done;

_timeout=10
if zenity --timeout $_timeout --question --text \
    "Backup to $hd? \n(defaults to 'Yes' in ${_timeout}s)" \
    --ok-label="No" --cancel-label="Yes" --width 200;
then
    notify-send "Skipped."
else
    ./auto.sh
fi
