#!/bin/bash
set_dir () { DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; }; set_dir
safe_source () { source $1; set_dir; }
safe_source $DIR/common.sh
safe_source $DIR/config.sh

name="zencefil"
disk=$(get_device_by_id $zencefil_disk)
crypt_part=$(get_device_by_uuid $zencefil_luks_uuid)

echo "...checking if $zencefil_mnt is mounted"
require_not_mounted $zencefil_mnt
mkdir -p $zencefil_mnt

unencrypted_part=/dev/mapper/$name
echo "...decrypting $crypt_part"
cryptsetup open $crypt_part $name
sleep 2 # to let lvm to be activated
lvscan 

# mount the root LVM
mount_unless_mounted ${unencrypted_part}-root $zencefil_mnt
echo_green "Successfully mounted on $zencefil_mnt"
