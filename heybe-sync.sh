#!/bin/bash
set -eu -o pipefail
set_dir(){ _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; }; set_dir
safe_source () { source $1; set_dir; }
# end of bash boilerplate

safe_source $_dir/config.sh

$_dir/smith-sync/sync $ROOTFS_SNAP $heybe_mnt/snapshots
