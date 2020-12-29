#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }
set -eu

tflag="/tmp/take-snapshot.last-run.txt" # timestamp file
_flag="/tmp/masa-auto.last-run.txt"

[[ -f $tflag ]] || echo 0 > $tflag
[[ -f $_flag ]] || echo 0 > $_flag
if [[ "$(cat $_flag)" -lt "$(cat $tflag)" ]]; then
    notify-send "$(basename $0)' last run is stale."
else
    echo "Not running as it should be already backed up."
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
hd="masa"
notify-send "Backing up to $hd."
t0=$EPOCHSECONDS
./$hd-attach.sh
time ./$hd-backup.sh
./$hd-detach.sh
t1=$EPOCHSECONDS
notify-send -u critical "Backup of $hd has ended." \
    "Took `date -d@$(($t1 - $t0)) -u +%H:%M:%S` seconds. $hd can be unplugged safely."

echo $EPOCHSECONDS > $_flag
