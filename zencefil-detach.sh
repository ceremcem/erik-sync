#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

safe_source $_dir/smith-sync/lib/all.sh
safe_source $_dir/config.sh

[[ $(whoami) = "root" ]] || { sudo $0 $*; exit 0; }

umount_if_mounted $zencefil_mnt
echo "detaching lvm parts"
unencrypted_part="/dev/mapper/zencefil"
detach_lvm_parts $unencrypted_part
cryptsetup close $unencrypted_part
echo_green "Successfully detached zencefil"
