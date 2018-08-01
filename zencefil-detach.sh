#!/bin/bash
set_dir () { DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; }; set_dir
safe_source () { source $1; set_dir; }
safe_source $DIR/common.sh
safe_source $DIR/config.sh

umount_if_mounted $zencefil_mnt
echo "detaching lvm parts"
unencrypted_part="/dev/mapper/zencefil"
detach_lvm_parts $unencrypted_part
cryptsetup close $unencrypted_part
echo_green "Successfully detached zencefil" 
