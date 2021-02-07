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

source ./config.sh
dev="/dev/disk/by-id/$wwn"
echo "---------------------------------"
echo "Please unplug zencefil."
while sleep 1; do test -b "$dev" || break; done;
echo "---------------------------------"
echo "Waiting for zencefil to attach..."
while sleep 1; do test -b "$dev" && break; done;
notify-send "Detected zencefil..."
./auto.sh
