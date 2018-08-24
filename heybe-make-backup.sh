#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

safe_source $_dir/config.sh

$_dir/heybe-attach.sh
$_dir/take-snapshot.sh
$_dir/smith-sync/sync $ROOTFS_SNAP $heybe_mnt/snapshots
$_dir/heybe-detach.sh