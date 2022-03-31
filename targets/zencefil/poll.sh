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

trap './detach.sh' EXIT

while :; do
    echo "Waiting for $hd to attach..."
    while sleep 1; do test -b "$dev" && break; done;

    _timeout=10
    ans=$(zenity --timeout $_timeout --question --text \
        "Backup to $hd? \n(timeout: ${_timeout}s)" \
        --ok-label="Do nothing" --extra-button "Scrub" --cancel-label="Backup*" --width 200;)
    rc=$?
    if [[ "$ans" == "Scrub" ]]; then
        ./scrub.sh --dialog
        ./detach.sh
    elif [[ $rc -eq 0 ]]; then
        notify-send "Skipped."
    else
        message="Backing up to $hd"
        [[ $rc -eq 5 ]] && notify-send -u critical "$message"
        echo "`date`: $message"
        ./auto.sh
    fi
    echo "---------------------------------"
    message="Backup is completed."
    echo "$message"
    while sleep 1; do test -b "$dev" || break; done;
    echo "---------------------------------"
done
