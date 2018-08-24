#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

safe_source $_dir/smith-sync/lib/all.sh
safe_source $_dir/config.sh

[[ $(whoami) = "root" ]] || { sudo $0 $*; exit 0; }

name="heybe"
disk=$(get_device_by_id $heybe_disk)
crypt_part=$(get_device_by_uuid $heybe_luks_uuid)

echo "...mounting $heybe_mnt"
if mountpoint $heybe_mnt; then
    echo "...seems already mounted."
    exit 0
fi
require_not_mounted $heybe_mnt
mkdir -p $heybe_mnt

unencrypted_part=/dev/mapper/$name
echo "...decrypting $crypt_part"
cryptsetup open $crypt_part $name

# mount the root LVM
mount_unless_mounted ${unencrypted_part} $heybe_mnt
echo_green "Successfully mounted on $heybe_mnt"
