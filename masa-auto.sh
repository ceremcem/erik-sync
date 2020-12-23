#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }
set -eu

cd $_sdir
hd="masa"
sudo notify-send "Backing up to $hd."
t0=$EPOCHSECONDS
./$hd-attach.sh
time ./$hd-backup.sh
./$hd-detach.sh
t1=$EPOCHSECONDS
notify-send -u critical "Backup of $hd has ended." \
    "Took `date -d@$(($t1 - $t0)) -u +%H:%M:%S` seconds. $hd can be unplugged safely."
