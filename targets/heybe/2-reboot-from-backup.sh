#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
set -eu

cd $_sdir
. ./config.sh

restore_folder="${root_mnt}/rootfs2"

if ! [[ -d "$restore_folder" ]]; then
    echo "Error: Destination folder ($restore_folder) does not exist."
    exit 1
fi

sudo rsync -aP --delete $restore_folder/boot.backup/ /boot/
sudo mv $root_mnt/rootfs $root_mnt/rootfs-$(date +'%Y%m%dT%H%M')
sudo mv $restore_folder $root_mnt/rootfs

echo "System can be rebooted."
