#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

safe_source $_dir/config.sh
safe_source $_dir/smith-sync/lib/all.sh

# Parse command line arguments
# ---------------------------
# Initialize parameters
postpone=false
periodic=false
dry_run=
# ---------------------------
args=("$@")
_count=1
while :; do
    key="${1:-}"
    case $key in
        -h|-\?|--help)
            show_help    # Display a usage synopsis.
            exit
            ;;
        # --------------------------------------------------------
        --at) shift
            postpone=true
            run_at=$1
            shift
            ;;
        --periodic) shift
            periodic=true
            ;;
        --dry-run)
            dry_run=$1
            shift
            ;;
        # --------------------------------------------------------
        -*) # Handle unrecognized options
            echo
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)  # Generate the positional arguments: $_arg1, $_arg2, ...
            [[ ! -z ${1:-} ]] && declare _arg$((_count++))="$1" && shift
    esac
    [[ -z ${1:-} ]] && break
done; set -- "${args[@]}"
# use $_arg1 in place of $1, $_arg2 in place of $2 and so on, "$@" is intact

[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }

convertsecs() {
 ((h=${1}/3600))
 ((m=(${1}%3600)/60))
 ((s=${1}%60))
 printf "%02d:%02d:%02d\n" $h $m $s
}

if [[ $postpone = true ]]; then
    curr_hour=`date +%s`
    run_hour=`date +%s -d $run_at`
    diff_sec=$(( ($run_hour - $curr_hour + 24 * 3600) % (24 * 3600) ))
    diff_hour=`convertsecs $diff_sec`
    echo_blue "Sync postponed to run at $run_at (left: $diff_hour)"
    sleep $diff_sec
fi

# backup the boot partition
echo "backing up /boot partition"
require_mounted $heybe_boot_mnt
rsync -aP --delete /boot/ $heybe_boot_mnt/
echo "replacing crypt_part uuid's"
# default cryptopts=source=UUID=YOUR_DISK_UUID_HERE,target=masa_crypt,lvm=masa-root
sed -i "s/cryptopts=.*\b/cryptopts=source=UUID=$heybe_luks_uuid,target=heybe_crypt /g" $heybe_boot_mnt/grub/grub.cfg

echo_yellow "# FIXME: there is no swap in heybe, add one!"

$_dir/smith-sync/btrfs-sync $ROOTFS/snapshots $heybe_mnt/snapshots ${dry_run:-}

if [[ $periodic = true ]]; then
    echo "Periodic run is set: "
    $0 "$@"
fi
