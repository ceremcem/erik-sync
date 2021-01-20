#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }

cd $_sdir
t0=$EPOCHSECONDS
./attach.sh
notify-send -u critical "Backing up to zencefil."
../rootfs/take-snapshot.sh
time ./backup.sh
./assemble-bootable.sh --refresh --full
./detach.sh
t1=$EPOCHSECONDS
notify-send -u critical "Backup of zencefil has ended." \
    "Took `date -d@$(($t1 - $t0)) -u +%H:%M:%S` seconds. Zencefil can be unplugged safely."
