#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }

cd $_sdir
t0=$EPOCHSECONDS
./zencefil-attach.sh
notify-send "Backing up to zencefil."
./take-snapshot.sh
time ./zencefil-backup.sh
./zencefil-assemble-bootable.sh --refresh --full
./zencefil-detach.sh
t1=$EPOCHSECONDS
notify-send -u critical "Backup of zencefil has ended." \
    "Took `date -d@$(($t1 - $t0)) -u +%H:%M:%S` seconds. Zencefil can be unplugged safely."
