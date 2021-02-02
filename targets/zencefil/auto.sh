#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }

no_new=false
[[ ${1:-} == "--no-new" ]] && no_new=true

cd $_sdir
t0=$EPOCHSECONDS
./attach.sh
notify-send -u critical "Backing up to zencefil."
[[ $no_new == false ]] && ../rootfs/take-snapshot.sh || echo "Skipping taking a new snapshot."
time ./backup.sh

snapshots=$(cat btrbk.conf | grep "target\b" | awk '{print $2}')
../../smith-sync/list-backup-dates.sh $snapshots > current-backups.list

./assemble-bootable.sh --refresh --full
./detach.sh
t1=$EPOCHSECONDS
notify-send -u critical "Backup of zencefil has ended." \
    "Took `date -d@$(($t1 - $t0)) -u +%H:%M:%S` seconds. Zencefil can be unplugged safely."
