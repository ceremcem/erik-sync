#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

period="3h"
notify-send "Started periodic snapshotting" "Snapshots will be taken every $period"
echo "Perodic snapshotting started."
while :; do
    if $_sdir/take-snapshot.sh; then
        echo "`date -u`: take-backup.sh finished." 
    else
        notify-send -u critical "Error in take-backup.sh" \
            "Something went wrong, please check the console."
    fi
    sleep $period
done
