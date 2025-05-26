#!/usr/bin/env bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. $_sdir/../../smith-sync/lib/basic-functions.sh


# All checks are done, run as root.
[[ $(whoami) = "root" ]] || exec sudo "$0" "$@"

while read key value; do
    case $key in
        snapshot_dir|volume)
            declare $key=$value
            ;;
    esac
done < $_sdir/btrbk.conf

echo "Listing the timestamps in "$volume/$snapshot_dir""

# PROBLEMS:
# If NEW_TIMESTAMP has snapshots where OLD_TIMESTAMP has not, then all filenames 
# should be dumped in this snapshots as "DIFF".
echo "TODO: FINISH THIS SCRIPT"