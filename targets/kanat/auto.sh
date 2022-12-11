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

echo "source: $source_snapshots"
echo "target: $target_snapshots"

hd="kanat"

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

cd $_sdir
if sudo -u $SUDO_USER vboxmanage showvminfo "$hd-testing" | grep -q "running (since"; then
    notify-send -u critical "Not backing up $hd" "$hd-testing is running."
    exit 1
fi
notify-send "Backing up to $hd."
t0=$EPOCHSECONDS
./attach.sh
if ! time ./backup.sh; then
    notify-send -u critical "ERROR: $hd backup" "Something went wrong. Check console."
    exit 1
fi

# Backup is successful, keep the latest snapshot
echo "Backup is successful."
../../smith-sync/mark-not-delete-latest.sh $hd ../rootfs/exclude $target_snapshots

echo "Assembling the bootable subvolume on target:"
./assemble-bootable.sh --refresh --full
#./$hd-detach.sh
t1=$EPOCHSECONDS
notify-send "Backup of $hd has been completed." \
    "Took `date -d@$(($t1 - $t0)) -u +%H:%M:%S` seconds. INFO: $hd is left attached."

echo $EPOCHSECONDS > $_flag

