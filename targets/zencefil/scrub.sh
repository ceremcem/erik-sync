#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }

. $_sdir/config.sh



cleanup(){
    echo "Cancelling scrub on $root_mnt"
    btrfs scrub cancel "$root_mnt"
}

trap cleanup EXIT

$_sdir/attach.sh
btrfs scrub resume "$root_mnt"
watch -n 10 "btrfs scrub status $root_mnt"


