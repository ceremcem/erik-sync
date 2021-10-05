#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }
set -eu

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
