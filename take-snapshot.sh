#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

# ----------------------------------------------------
# Procedure:
# 1. Delete current rootfs_rollback
# 2. Take current / as rootfs_rollback
# 3. Backup /boot to /boot.backup with rsync (because it is on another partition)
# 4. Take snapshot of rootfs
# 5. Take snapshot of cca-heybe
# ----------------------------------------------------

safe_source $_dir/smith-sync/lib/all.sh
safe_source $_dir/config.sh

[[ $(whoami) = "root" ]] || { sudo $0 $*; exit 0; }

# check if rollback_snapshot is mounted or not, because we don't want
# to delete a mounted snapshot
require_not_mounted $ROLLBACK_SNAPSHOT
start_timer

# Remove if rollback snapshot is present
if is_btrfs_subvolume $ROLLBACK_SNAPSHOT; then
    echo "Removing current rollback snapshot ($ROLLBACK_SNAPSHOT)"
    btrfs sub delete $ROLLBACK_SNAPSHOT
else
    echo_yellow "No rollback snapshot found."
fi

echo_green "Snapshotting current rootfs as rollback ($ROLLBACK_SNAPSHOT)"
btrfs sub snap / $ROLLBACK_SNAPSHOT
show_timer "Current rootfs is now in rollback location."

echo_green "Backing up /boot partition"
rsync -avrP /boot/ /boot.backup/

POSTFIX=$(get_timestamp)
echo_green "Taking Snapshots with $POSTFIX postfix..."
take_snapshot "$ROOTFS/$ROOTFS_LIVE" "$ROOTFS_SNAP/$ROOTFS_LIVE/$ROOTFS_LIVE.$POSTFIX"
take_snapshot "$ROOTFS/$HEYBE_LIVE" "$ROOTFS_SNAP/$HEYBE_LIVE/$HEYBE_LIVE.$POSTFIX"
show_timer "All done."
