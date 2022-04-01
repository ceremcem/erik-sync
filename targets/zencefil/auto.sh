#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }

do_detach(){
    ./detach.sh
    notify-send -u critical "$hd is unmounted."
}

suspend_lock_file=/tmp/cca-suspend.lock.zencefil
disable_cca_suspend(){
    msg="* INFO: Disabling cca-suspend."
    echo "$msg"; notify-send -u critical "$msg"
    touch $suspend_lock_file
}

enable_cca_suspend(){
    msg="* INFO: Enabling cca-suspend."
    echo "$msg"; notify-send -u critical "$msg"
    [[ -f $suspend_lock_file ]] && rm $suspend_lock_file
}

trap 'enable_cca_suspend' EXIT

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

disable_cca_suspend

no_new=false
[[ ${1:-} == "--no-new" ]] && no_new=true

hd="zencefil"
cd $_sdir
t0=$EPOCHSECONDS

MARK_SNAPSHOTS="../../smith-sync/mark-snapshots.sh --suffix .ZENCEFIL"

if [[ $no_new == false ]]; then
    # do not take a snapshot while APT is running
    notified=false
    while :; do
        if (( $(lsof -t "/var/lib/dpkg/lock" | wc -w) > 0 )) ; then
            if ! $notified; then
                notify-send -u critical "Waiting for DPKG to finish" "Dpkg is running. Will be re-checked in every 1m"
                >&2 echo "$(date): Waiting for DPKG to finish. Dpkg is running. Will retry in every 1m"
                notified=true
            fi
            sleep 1m
            continue
        else
            break
        fi
    done
    if $notified; then
        notify-send -u critical "DPKG has finished" "Starting backup process"
        >&2 echo "$(date): DPKG has finished. Starting backup process"
    fi
    ../rootfs/take-snapshot.sh
else
    echo "Skipping taking a new snapshot."
fi

./detach.sh
./attach.sh
notify-send "Transferring data to $hd."

$MARK_SNAPSHOTS "$source_snapshots" --unfreeze --fix-received "$target_snapshots"
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

#./scrub.sh --dialog

do_detach # visual notification is displayed within the function

t1=$EPOCHSECONDS
duration=`date -d@$(($t1 - $t0)) -u +%H:%M:%S`
echo "$hd data transfer completed." "Duration: ${duration}."

# Backups are taken succesfully, remove the old saved snapshots, create new ones. (2/2)
# (Perform these operations after detach, in order to save time
$MARK_SNAPSHOTS "$source_snapshots" --clean
$MARK_SNAPSHOTS "$source_snapshots" --timestamp $latest_timestamp --freeze

t2=$EPOCHSECONDS
duration=`date -d@$(($t2 - $t1)) -u +%H:%M:%S`
echo "$hd latest snapshots are frozen in: ${duration}."
