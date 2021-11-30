#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }

do_detach(){
    ./detach.sh
    notify-send -u critical "$hd is unmounted."
}

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

echo "source: $source_snapshots"
echo "target: $target_snapshots"

no_new=false
[[ ${1:-} == "--no-new" ]] && no_new=true

hd="zencefil"
cd $_sdir
t0=$EPOCHSECONDS

./detach.sh
./attach.sh
notify-send "Backing up to $hd."

MARK_SNAPSHOTS="../../smith-sync/mark-snapshots.sh"

[[ $no_new == false ]] && ../rootfs/take-snapshot.sh || echo "Skipping taking a new snapshot."
$MARK_SNAPSHOTS "$source_snapshots" --unfreeze
if ! time ./backup.sh; then
    notify-send -u critical "ERROR: $hd backup" "Something went wrong. Check console."
    do_detach
    exit 1
fi


# Backups are taken succesfully, remove the old saved snapshots, create new ones. (1/2)
latest_timestamp=$($MARK_SNAPSHOTS "$target_snapshots" --get-latest-ts)

../../smith-sync/list-backup-dates.sh $target_snapshots > current-backups.list

if ! ./assemble-bootable.sh --refresh --full; then
    echo
    echo "-------------------------------------------------------"
    echo "Something went wrong while assembling the bootable copy."
    echo "$hd is left attached. Please manually handle the problem."
    echo "-------------------------------------------------------"
    echo
    exit 2
fi
t1=$EPOCHSECONDS
duration=`date -d@$(($t1 - $t0)) -u +%H:%M:%S`

notify-send -u critical "$hd backup completed" "Backup completed in ${duration}."

#./scrub.sh --dialog

do_detach

# Backups are taken succesfully, remove the old saved snapshots, create new ones. (2/2)
# (Perform these operations after detach, in order to save time
$MARK_SNAPSHOTS "$source_snapshots" --clean
$MARK_SNAPSHOTS "$source_snapshots" --timestamp $latest_timestamp --freeze
