#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
set -eu

cd $_sdir
. ./config.sh

restore_folder="${root_mnt}/rootfs2"

echo "Missing snapshots in rootfs2:"
echo "-----------------------------"
/usr/bin/diff <( btrfs-ls --relative $root_mnt/rootfs ) <( btrfs-ls --relative $restore_folder )
