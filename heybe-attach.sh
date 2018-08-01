#!/bin/bash
set_dir () { DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; }; set_dir
safe_source () { source $1; set_dir; }
safe_source $DIR/common.sh
safe_source $DIR/config.sh

name="heybe"
disk=$(get_device_by_id $heybe_disk)
crypt_part=$(get_device_by_uuid $heybe_luks_uuid)

echo "...checking if $heybe_mnt is mounted"
require_not_mounted $heybe_mnt
mkdir -p $heybe_mnt

unencrypted_part=/dev/mapper/$name
echo "...decrypting $crypt_part"
cryptsetup open $crypt_part $name

# mount the root LVM
mount_unless_mounted ${unencrypted_part} $heybe_mnt
echo_green "Successfully mounted on $heybe_mnt"
