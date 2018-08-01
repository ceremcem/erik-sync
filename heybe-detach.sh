#!/bin/bash
set_dir () { DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; }; set_dir
safe_source () { source $1; set_dir; }
safe_source $DIR/common.sh
safe_source $DIR/config.sh

echo "unmounting $heybe_mnt"
umount_if_mounted $heybe_mnt
unencrypted_part="/dev/mapper/heybe"

echo "closing luks..."
cryptsetup close $unencrypted_part
echo_green "Successfully detached heybe"
