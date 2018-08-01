#!/bin/bash
set_dir () { DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; }; set_dir
safe_source () { source $1; set_dir; }
safe_source $DIR/common.sh
safe_source $DIR/config.sh

require_mounted $ROOTFS
require_mounted $DEST
require_being_btrfs_subvolume $DEST_SNAP

echo_green "Started sync-local"
start_timer

send_all_snapshots "$ROOTFS_SNAP/$ROOTFS_LIVE" "$DEST_SNAP/$ROOTFS_LIVE"
show_timer "sync of $ROOTFS_SNAP completed in"

send_all_snapshots "$HEYBE_SNAP/$HEYBE_LIVE" "$DEST_SNAP/$HEYBE_LIVE"
show_timer "Synchronization finished in"
