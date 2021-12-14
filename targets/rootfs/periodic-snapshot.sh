#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

[[ $(whoami) = "root" ]] || { sudo "$0" "$@"; exit 0; }

period="6h"

# Prevent taking snapshots while dpkg is performing:
# https://unix.stackexchange.com/q/681324/65781
lockfile="/var/lib/dpkg/lock"

notify-send "Started periodic snapshotting" "Snapshots will be taken every $period"
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
