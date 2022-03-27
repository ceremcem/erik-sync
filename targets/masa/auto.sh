#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }
set -eu

# Print generated config
while read key value; do
    case $key in
        snapshot_dir|volume|subvolume|target)
            declare $key=$value
            ;;
    esac
done < $_sdir/btrbk.conf

source_snapshots="$volume/$snapshot_dir"
target_snapshots="$target"

MARK_SNAPSHOTS="../../smith-sync/mark-snapshots.sh --suffix .MASA"

echo "source: $source_snapshots"
echo "target: $target_snapshots"

hd="masa"

tflag="/tmp/take-snapshot.last-run.txt" # timestamp file
_flag="/tmp/$hd-auto.last-run.txt"

[[ "${1:-}" == "--force" ]] && echo "-1" > $_flag
[[ -f $tflag ]] || echo 0 > $tflag
[[ -f $_flag ]] || echo 0 > $_flag
if [[ "$(cat $_flag)" -lt "$(cat $tflag)" ]]; then
    notify-send "${hd}'s last run is stale."
else
    echo "Not running as it should be already backed up. (Consider --force option)"
    exit 0
fi

on_kill(){
    s=2
    echo "In order to kill, press Ctrl+C within $s seconds. $@"
    sleep $s
}

# ignore those signals:
trap -- on_kill SIGTERM SIGHUP SIGINT

list_curr_snapshots(){
    local snapshots=$(cat btrbk.conf | grep "target\b" | awk '{print $2}')
    if [[ -d $snapshots ]]; then
        ../../smith-sync/list-backup-dates.sh $snapshots > current-backups.list
    fi
}

cleanup(){
    list_curr_snapshots
}

trap cleanup EXIT

cd $_sdir
if sudo -u $SUDO_USER vboxmanage showvminfo "masa-testing" | grep -q "running (since"; then
    notify-send -u critical "Not backing up $hd" "masa-testing is running."
    exit 1
fi
notify-send "Backing up to $hd."
t0=$EPOCHSECONDS
./attach.sh
$MARK_SNAPSHOTS "$source_snapshots" --unfreeze --fix-received "$target_snapshots"
if ! time ./backup.sh; then
    notify-send -u critical "ERROR: $hd backup" "Something went wrong. Check console."
    exit 1
fi

./assemble-bootable.sh --refresh --full
#./$hd-detach.sh
t1=$EPOCHSECONDS
notify-send "Backup of $hd has ended." \
    "Took `date -d@$(($t1 - $t0)) -u +%H:%M:%S` seconds. INFO: $hd is left attached."

echo $EPOCHSECONDS > $_flag

# Backups are taken succesfully, remove the old saved snapshots, create new ones.
latest_timestamp=$($MARK_SNAPSHOTS "$target_snapshots" --get-latest-ts)
$MARK_SNAPSHOTS "$source_snapshots" --clean
$MARK_SNAPSHOTS "$source_snapshots" --timestamp $latest_timestamp --freeze

echo "------------------------------------"
echo "Snapshot marking has been completed."
echo "------------------------------------"
