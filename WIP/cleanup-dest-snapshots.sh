#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/common.sh
start_timer

needed_space="200G"
echo_green "Starting cleanup to make $needed_space of free space in $(mount_point_of $DEST_SNAP)"

cleanup_dest_snapshots_by_disk_space $needed_space "$HEYBE_SNAP/$HEYBE_LIVE" "$DEST_SNAP/$HEYBE_LIVE"
cleanup_dest_snapshots_by_disk_space $needed_space "$ROOTFS_SNAP/$ROOTFS_LIVE" "$DEST_SNAP/$ROOTFS_LIVE"

echo_green "Cleanup done, current free space: $(get_free_space_of_snap $DEST_SNAP) K"
show_timer
