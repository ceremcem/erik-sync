#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

safe_source $_dir/smith-sync/lib/all.sh
safe_source $_dir/config.sh

[[ $(whoami) = "root" ]] || { sudo $0 $*; exit 0; }

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
