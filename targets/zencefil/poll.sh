#!/bin/bash

# Usage:
#
#   $ sudo -s
#   # source $(basename $0)
#

_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }
cd $_sdir
hd="zencefil"
source ./config.sh
dev="/dev/disk/by-id/$wwn"
while :; do
    echo "Waiting for $hd to attach..."
    while sleep 1; do test -b "$dev" && break; done;

    _timeout=10
    zenity --timeout $_timeout --question --text \
        "Backup to $hd? \n(timeout: ${_timeout}s)" \
        --ok-label="Skip" --cancel-label="Backup*" --width 200;
    ans=$?
    if [[ $ans -eq 0 ]]; then
        notify-send "Skipped."
    else
        [[ $ans -eq 5 ]] && notify-send -u critical "Backing up to $hd"
        ./auto.sh
    fi
    echo "---------------------------------"
    message="$hd can be safely unplugged now."
    echo "$message"
    zenity --info --text "$message" --width=200
    while sleep 1; do test -b "$dev" || break; done;
    echo "---------------------------------"
done
