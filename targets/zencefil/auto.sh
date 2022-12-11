#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }

# Parameters
no_new=false
[[ "${1:-}" == "--no-new" ]] && no_new=true # do not take a new rootfs snapshot before backup
# end of Parameters

do_detach(){
    ./detach.sh
    notify-send -u critical "$hd is unmounted."
}

hd="zencefil"

suspend_lock_file=/tmp/cca-suspend.defer.$hd
disable_cca_suspend(){
    msg="* INFO: Disabled cca-suspend."
    echo "$msg"; notify-send -u critical "$msg"
    touch $suspend_lock_file
}

enable_cca_suspend(){
    msg="* INFO: Enabled cca-suspend."
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

cd $_sdir
t0=$EPOCHSECONDS

if [[ $no_new == false ]]; then
    notify-send "Taking a new rootfs snapshot"
    ../rootfs/take-snapshot.sh
else
    echo "Skipping taking a new snapshot."
fi


echo "(Trying to unmount $hd first, just in case)"
./detach.sh &> /dev/null

echo "Mounting $hd partitions accordingly..."
./attach.sh

notify-send "Transferring data to $hd."
if ! time ./backup.sh; then
    notify-send -u critical "ERROR: $hd backup" "Something went wrong. Check console."
    do_detach
    exit 1
fi

# Backup is successful, keep the latest snapshot
echo "Backup is successful."
../../smith-sync/mark-not-delete-latest.sh $hd ../rootfs/exclude $target_snapshots

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

t1=$EPOCHSECONDS
duration=`date -d@$(($t1 - $t0)) -u +%H:%M:%S`
echo "$hd data transfer completed." "Duration: ${duration}."

do_detach # visual notification is displayed within the function
