#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

[[ $(whoami) = "root" ]] || { sudo "$0" "$@"; exit 0; }

# Get period from btrbk.conf.template. Use `snapshot_preserve_min - 1` value.
period=$(cat $_sdir/btrbk.conf.template | grep snapshot_preserve_min | awk 'match($2, /([0-9]+)(h)/) {print substr($2, RSTART, RLENGTH-1)}')
period=$(($period - 1))
if [[ $period -lt 1 ]]; then
    echo "Period should be greater than 0." 
    echo "Check btrbk.conf.template for snapshot_preserve_min value"
    exit 1
fi
period="${period}h"

# Prevent taking snapshots while dpkg is performing:
# https://unix.stackexchange.com/q/681324/65781
lockfile="/var/lib/dpkg/lock"

notify-send "Started periodic snapshotting" "Snapshots will be taken every $period."
echo "Perodic snapshotting started."
while :; do
    if (( $(lsof -t "$lockfile" | wc -w) > 0 )) ; then
        echo "dpkg is running. Will try again in 10m" >&2
        sleep 10m
        continue
    fi

    if $_sdir/take-snapshot.sh; then
        echo "`date -u`: take-backup.sh finished." 
    else
        notify-send -u critical "Error in take-backup.sh" \
            "Something went wrong, please check the console."
    fi
    sleep $period
done
