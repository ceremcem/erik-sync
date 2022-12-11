#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
set -eu

cd $_sdir
. ./config.sh

restore_date="${1:-}"
restore_folder="${root_mnt}/rootfs2"

if [[ -d "$restore_folder" ]]; then
    echo "Error: Destination folder ($restore_folder) exists."
    exit 1
fi

if [[ -z $restore_date ]]; then
    echo "Usage: $(basename $0) RESTORE_DATE"
    echo
    echo "Restore the RESTORE_DATE backups in $restore_folder"
    echo 
    echo "Available backups:"
    echo "------------------"
    ../../smith-sync/list-backup-dates.sh "${root_mnt}/snapshots/erik3/"
    exit 1
fi

sudo ../../smith-sync/restore-backups.sh "${root_mnt}/snapshots/erik3/" "$restore_folder" \
    --date $restore_date

_tmp=$restore_folder/var/tmp
echo "Re-create $_tmp"
sudo rmdir $_tmp \
    && sudo btrfs sub create $_tmp \
    && sudo chmod 1777 $_tmp

echo
echo "Success: $restore_folder is created from backup: $restore_date."

echo
echo "---------------------------------------------------------"
echo "REMINDER: Set brightness file permissions after booting:"
echo chmod 666 /sys/class/backlight/intel_backlight/brightness
echo "---------------------------------------------------------"
echo

