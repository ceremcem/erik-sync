#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

safe_source $_dir/config.sh
safe_source $_dir/smith-sync/lib/all.sh

# All checks are done, run as root.
[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }

machine="erik"
for b in rootfs cca-heybe; do
    src=$(get-latest-folder "$ROOTFS/snapshots/$machine/$b")
    src_name="$(basename $src)"
    echo_green "Backing up $src_name"
    dest="$zencefil_mnt/sync/$machine/$b"
    snap_name="$zencefil_mnt/snapshots/$machine/$b/$src_name"
    if [[ -e "$snap_name" ]]; then
        echo_yellow "Skipping $src_name because it's already snapshotted"
        continue
    fi
    $_sdir/smith-sync/rsync.sh -u "$src/" "$dest/"
    [[ $? -eq 0 ]] && btrfs sub snap -r "$dest" "$snap_name"
done


# TODO: Remove this duplicate code
machine="fc2"
src=$(get-latest-folder "$ROOTFS/snapshots/$machine")
src_name="$(basename $src)"
echo_green "Backing up $src_name"
dest="$zencefil_mnt/sync/$machine"
snap_name="$zencefil_mnt/snapshots/$machine/$src_name"
if [[ -e "$snap_name" ]]; then
    echo_yellow "Skipping $src_name because it's already snapshotted"
else
    [[ -d "$dest" ]] || btrfs sub create "$dest"
    $_sdir/smith-sync/rsync.sh -u "$src/" "$dest/"
    mkdir -p $(dirname "$snap_name")
    [[ $? -eq 0 ]] && btrfs sub snap -r "$dest" "$snap_name"
fi
