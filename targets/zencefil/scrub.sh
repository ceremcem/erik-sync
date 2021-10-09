#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }

. $_sdir/config.sh

_should_run=true
cleanup(){
    _should_run=false
    echo "Cancelling scrub on $root_mnt"
    btrfs scrub cancel "$root_mnt"
}

trap cleanup EXIT

$_sdir/attach.sh

is_scrub_running(){
    local status=$(btrfs scrub status "$root_mnt" | grep Status | awk '{print $2}')
    if [[ "$status" == "running" ]]; then
        return 0
    else
        return 1
    fi
}

watch_scrub(){
    while $_should_run; do
        if ! is_scrub_running; then
            btrfs scrub resume "$root_mnt"
        fi
        sleep 10
    done
}

watch_scrub &

while :; do
    clear
    echo "Scrub status for $lvm_name"
    echo "--------------------------"
    btrfs scrub status $root_mnt
    echo "--------------------------"
    sleep 2
done

