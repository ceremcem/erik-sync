#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

period="12h"
notify-send "Started periodic snapshotting" "Snapshots will be taken every $period"
echo "Perodic snapshotting started."
while sleep $period; do 
    $_sdir/take-snapshot.sh 
    notify-send -u critical "take-backup.sh ended." "`date`"
done