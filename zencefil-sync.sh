#!/bin/bash
set_dir () { DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; }
safe_source () { source $1; set_dir; }
set_dir

safe_source $DIR//common.sh
safe_source $DIR/config.sh

start_timer

require_mounted $BACKUP_MEDIA
require_being_btrfs_subvolume $DEST_SSH_SNAP

echo_green "Started sync-physical"

SNAP_ROOT="$BACKUP_MEDIA/$SNAP_CONTAINER"
send_all_snapshots "$SNAP_ROOT/$ROOTFS_LIVE" "$DEST_SSH_SNAP/$ROOTFS_LIVE"
show_timer "sync of $ROOTFS_SNAP completed in"

send_all_snapshots "$SNAP_ROOT/$HEYBE_LIVE" "$DEST_SSH_SNAP/$HEYBE_LIVE"
show_timer "Synchronization finished in"
