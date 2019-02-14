#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

# ----------------------------------------------------
# Procedure:
# 1. Delete current rootfs_rollback
# 2. Take current / as rootfs_rollback
# 3. Backup /boot to /boot.backup with rsync (because it is on another partition)
# 4. Take snapshot of rootfs
# 5. Take snapshot of cca-heybe
# ----------------------------------------------------

safe_source $_dir/smith-sync/lib/all.sh
safe_source $_dir/config.sh

# show help
show_help(){
    cat <<HELP

    $(basename $0) [options]

    Options:

        --dry-run       : Dry run, don't touch anything actually

HELP
    exit
}

check_dry_run(){
    if [[ $dry_run = false ]]; then
        "$@"
    else
        echo "DRY RUN: $@"
    fi
}

# Parse command line arguments
# ---------------------------
# Initialize parameters
dry_run=false
new_hostname=
root_dir=
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
        --dry-run) shift
            dry_run=true
            ;;
        # --------------------------------------------------------
        -*)
            echo
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)  # generate the positional arguments: $_arg1, $_arg2, ...
            [[ ! -z ${1:-} ]] && declare _arg$((_count++))="$1" && shift
    esac
    [[ -z ${1:-} ]] && break
done; set -- "${args[@]}"
# use $_arg1 in place of $1, $_arg2 in place of $2 and so on, "$@" is intact

# All checks are done, run as root.
[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }

start_timer

# Remove if rollback snapshot is present
if is_btrfs_subvolume $ROLLBACK_SNAPSHOT; then
    # check if rollback_snapshot is mounted or not, because we don't want
    # to delete a mounted snapshot
    require_not_mounted $ROLLBACK_SNAPSHOT
    echo "Removing current rollback snapshot ($ROLLBACK_SNAPSHOT)"
    check_dry_run btrfs sub delete $ROLLBACK_SNAPSHOT
else
    echo_yellow "No rollback snapshot found."
fi

echo_green "Snapshotting current rootfs as rollback ($ROLLBACK_SNAPSHOT)"
check_dry_run btrfs sub snap / $ROLLBACK_SNAPSHOT
show_timer "Current rootfs is now in rollback location."

echo_green "Backing up /boot partition"
check_dry_run rsync -avrP /boot/ /boot.backup/

echo_green "Backing up chromium config"
check_dry_run rsync -avrP /home/ceremcem/.config/chromium/ /home/ceremcem/.config/chromium.backup

POSTFIX=$(get_timestamp)
echo_green "Taking Snapshots with $POSTFIX postfix..."
check_dry_run take_snapshot "$ROOTFS/$ROOTFS_LIVE" "$ROOTFS_SNAP/$ROOTFS_LIVE/$ROOTFS_LIVE.$POSTFIX"
check_dry_run take_snapshot "$ROOTFS/$HEYBE_LIVE" "$ROOTFS_SNAP/$HEYBE_LIVE/$HEYBE_LIVE.$POSTFIX"

for vm in /var/lib/lxc/*; do
    [[ -d "$vm" ]] || continue
    vm_name=$(basename $vm)
    if [[ -e "$vm/do-not-backup" ]]; then
        echo_yellow "$vm_name won't be backed up due to 'do-not-backup' flag"
        continue
    elif ! is_btrfs_subvolume $vm/rootfs; then
        echo_yellow "$vm_name is not using a btrfs subvolume"
        continue
    fi
    echo "...Found vm: $vm_name"
    dst="$ROOTFS/snapshots/$vm_name"
    check_dry_run mkdir -p $dst
    check_dry_run take_snapshot $vm/rootfs $dst/$vm_name.$POSTFIX
done

show_timer "All done."
