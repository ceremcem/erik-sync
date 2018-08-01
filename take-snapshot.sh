#!/bin/bash
# ----------------------------------------------------
# Procedure:
# 1. Delete current rootfs_rollback
# 2. Take current / as rootfs_rollback
# 3. Backup /boot to /boot.backup with rsync (because it is on another partition)

set_dir () { DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; }; set_dir
safe_source () { source $1; set_dir; }
safe_source $DIR//common.sh
safe_source $DIR/config.sh

# check if rollback_snapshot is mounted or not, because we don't want
# to delete a mounted snapshot
require_not_mounted $ROLLBACK_SNAPSHOT
start_timer
echo "Removing current rollback snapshot ($ROLLBACK_SNAPSHOT)"
btrfs sub delete $ROLLBACK_SNAPSHOT
echo_green "Snapshotting current rootfs as rollback ($ROLLBACK_SNAPSHOT)"
btrfs sub snap / $ROLLBACK_SNAPSHOT
show_timer "Current rootfs is now in rollback location."

echo_green "Backing up /boot partition"
rsync -avrP /boot/ /boot.backup/

POSTFIX=$(get_timestamp)
echo_green "Taking Snapshots (.$POSTFIX)..."
take_snapshot "$ROOTFS/$ROOTFS_LIVE" "$ROOTFS_SNAP/$ROOTFS_LIVE/$ROOTFS_LIVE.$POSTFIX"
take_snapshot "$ROOTFS/$HEYBE_LIVE" "$ROOTFS_SNAP/$HEYBE_LIVE/$HEYBE_LIVE.$POSTFIX"
show_timer "All done."
