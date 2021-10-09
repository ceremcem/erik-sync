#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }

. $_sdir/config.sh

export TOP_PID=$$

flag="/tmp/${TOP_PID}_should_run.txt"

# set the flag file
echo "true" > $flag

scrub_status(){
    btrfs scrub status "$root_mnt" | grep Status | awk '{print $2}'
}

cleanup(){
    rm $flag 2> /dev/null
    echo "Cancelling scrub on $root_mnt"
    if [[ "$(scrub_status)" == "running" ]]; then
        btrfs scrub cancel "$root_mnt"
    fi
    out=$_sdir/scrub-statuses
    mkdir -p $out
    outfile=$out/$(date +"%Y%m%dT%H%M")-$(scrub_status).txt
    echo "Last scrub status is written to $outfile"
    btrfs scrub status "$root_mnt" > $outfile
}

trap cleanup EXIT SIGTERM

$_sdir/attach.sh

watch_scrub(){
    while [[ -f $flag ]]; do
        if [[ "$(scrub_status)" != "running" ]]; then
            btrfs scrub resume "$root_mnt"
        fi
        sleep 10
    done
}

watch_stop(){
    if [[ "${1:-}" == "--dialog" ]]; then
        zenity --info --text "Stop scrubbing ${lvm_name}?" --width=200
        kill -TERM $TOP_PID
    fi
}

watch_progress(){
    while [[ -f $flag ]]; do
        clear
        echo "Scrub status for $lvm_name (flag: $flag)"
        echo "--------------------------"
        btrfs scrub status $root_mnt
        echo "--------------------------"
        sleep 2
    done
}

watch_finish(){
    while [[ -f $flag ]]; do
        sleep 2
        if [[ "$(scrub_status)" == "finished" ]]; then
            echo "Finished scrubbing."
            kill -TERM $TOP_PID
        fi
    done
}

watch_scrub &
watch_stop "${1:-}" &
watch_finish &
watch_progress
