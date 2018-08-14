#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/common.sh
start_timer

echo_green "Cleaning up $(mount_point_of $HEYBE_SNAP)"
cleanup_src_snapshots_by_disk_space "200G" "$HEYBE_SNAP/$HEYBE_LIVE" "$DEST_SNAP/$HEYBE_LIVE"

echo_green "Cleaning up $(mount_point_of $ROOTFS_SNAP)"
cleanup_src_snapshots_by_disk_space "5G" "$ROOTFS_SNAP/$ROOTFS_LIVE" "$DEST_SNAP/$ROOTFS_LIVE"

echo_green "Cleanup done"
show_timer
