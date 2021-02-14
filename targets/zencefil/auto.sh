#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }

no_new=false
[[ ${1:-} == "--no-new" ]] && no_new=true

hd="zencefil"
cd $_sdir
t0=$EPOCHSECONDS

./attach.sh
notify-send "Backing up to $hd."
[[ $no_new == false ]] && ../rootfs/take-snapshot.sh || echo "Skipping taking a new snapshot."
if ! time ./backup.sh; then
    notify-send -u critical "ERROR: $hd backup" "Something went wrong. Check console."
    exit 1
fi

snapshots=$(cat btrbk.conf | grep "target\b" | awk '{print $2}')
../../smith-sync/list-backup-dates.sh $snapshots > current-backups.list

./assemble-bootable.sh --refresh --full
t1=$EPOCHSECONDS
duration=`date -d@$(($t1 - $t0)) -u +%H:%M:%S`

notify-send -u critical "$hd backup completed" "Backup completed in ${duration}."

zenity --info \
    --text="Backup of $hd completed." \
    --ok-label="Detach Now" \
    --width=200

./detach.sh
notify-send "$hd is detached."

