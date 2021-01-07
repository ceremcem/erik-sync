#!/bin/bash

# Usage:
#
#   $ sudo -s
#   # source $(basename $0)
#
# See also: https://unix.stackexchange.com/questions/627262/chroot-fails-to-be-executed-more-than-once-in-a-while-loop

#_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
#[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }
#cd $_sdir

source config.sh
echo "Started monitoring zencefil."
while sleep 1; do 
    while sleep 1; do test -b /dev/disk/by-id/$wwn || break; done;
    echo "Waiting for zencefil to attach..."
    while sleep 1; do test -b /dev/disk/by-id/$wwn && break; done;
    ./auto.sh
done
