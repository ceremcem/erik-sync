#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -eu


echo "----------------"
while read -r backup; do
    remotes=()
    for i in `ls $_sdir/exclude`; do
        [[ $(cat $_sdir/exclude/$i) == "$backup" ]] && remotes+=($i)
    done
    #[[ -e $_sdir/exclude/$backup ]] && remotes+=($(cat $_sdir/exclude/$backup))
    if [[ ${#remotes[@]} -gt 0 ]]; then
        echo "$backup (latest of: ${remotes[@]})"
    else
        echo "$backup"
    fi
done <<< $($_sdir/../../smith-sync/list-backup-dates.sh $(cat $_sdir/current_rootfs_mntpoint.txt)/snapshots/erik3/)
echo "----------------"

