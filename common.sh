#!/bin/bash
if [[ $(id -u) > 0 ]]; then
    #echo "This script needs root privileges..."
    sudo $0 "$@"
    exit
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DEBUG=false
source $DIR/smith-sync/lib/basic-functions.sh
source $DIR/smith-sync/lib/fs-functions.sh
source $DIR/smith-sync/btrfs-functions.sh
source $DIR/smith-sync/sync-functions.sh
source $DIR/smith-sync/luks-functions.sh
