#!/bin/bash
# ----------------------------------------------------
# Procedure:
# 1. Safely delete current rootfs_rollback
#    1. Only rename at this point
#    2. We'll remove when everything goes correctly.
# 2. Take current rootfs snapshot as rootfs_rollback
# 3.

set_dir () { DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; }; set_dir
safe_source () { source $1; set_dir; }
safe_source $DIR//common.sh
safe_source $DIR/config.sh

echo $DIR
exit
return

# check if rollback_snapshot is mounted or not, because we don't want
# to delete a mounted snapshot
require_not_mounted $ROLLBACK_SNAPSHOT
start_timer

echo_green "Snapshotting current rootfs as rollback ($ROLLBACK_SNAPSHOT)"
echo "Marking $ROLLBACK_SNAPSHOT to be deleted..."
mv $ROLLBACK_SNAPSHOT $ROLLBACK_SNAPSHOT.del
btrfs sub snap / $ROLLBACK_SNAPSHOT
btrfs sub delete $ROLLBACK_SNAPSHOT.del
show_timer "Current rootfs is now in rollback location."

echo_green "Backing up /boot partition"
rsync -avrP /boot/ /boot.backup/

echo_green "Taking Snapshots..."
POSTFIX=$(get_timestamp)
take_snapshot "$SRC1/$SRC1_SUB1" "$SRC1_SNAP/$SRC1_SUB1/$SRC1_SUB1.$POSTFIX"
take_snapshot "$SRC2/$SRC2_SUB1" "$SRC2_SNAP/$SRC2_SUB1/$SRC2_SUB1.$POSTFIX"
show_timer "All snapshots are taken."

show_timer "All done."
