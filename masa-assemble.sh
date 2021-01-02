#!/bin/bash
set -eu

root_mnt="/mnt/masa-root"
src="$root_mnt/snapshots/erik3/"
dest="$root_mnt/rootfs"
conf="./masa-config.sh"

die(){
    echo "$@"
    exit 1
}

# show help
show_help(){
    cat <<HELP

    $(basename $0) 
    Options:
        --full           : Make a full installation (including Grub install)
        --refresh        : Delete old rootfs recursively, create it from the latest backups

HELP
    exit
}

# Parse command line arguments
# ---------------------------
# Initialize parameters
full=false
refresh=false
# ---------------------------
args_backup=("$@")
args=()
_count=1
while [ $# -gt 0 ]; do
    key="${1:-}"
    case $key in
        -h|-\?|--help|'')
            show_help    # Display a usage synopsis.
            exit
            ;;
        # --------------------------------------------------------
        --full)
            # install Grub, etc.
            full=true
            ;;
        --refresh)
            refresh=true
            ;;
        # --------------------------------------------------------
        -*) # Handle unrecognized options
            die "Unknown option: $1"
            ;;
        *)  # Generate the new positional arguments: $arg1, $arg2, ... and ${args[@]}
            if [[ ! -z ${1:-} ]]; then
                declare arg$((_count++))="$1"
                args+=("$1")
            fi
            ;;
    esac
    shift
    [[ -z ${1:-} ]] && break
done; set -- "${args_backup[@]}"
# Use $arg1 in place of $1, $arg2 in place of $2 and so on, 
# "$@" is in the original state,
# use ${args[@]} for new positional arguments

[[ $(whoami) = "root" ]] || die "This script must be run as root."

source $conf

mountpoint $root_mnt > /dev/null || ./masa-attach.sh
[[ $refresh = true ]] && ./btrfs-ls $dest | xargs btrfs sub del 
[[ -d $dest ]] || ./assemble-backups.sh $src $dest
./multistrap-helpers/install-to-disk/generate-scripts.sh $conf -o $dest --update

if $full; then
    if [[ -d $dest/boot.backup ]]; then
        echo "Copying contents of \$dest/boot.backup/ to \$dest/boot/"
        mount $boot_part $dest/boot
        rsync -a --delete $dest/boot.backup/ $dest/boot/
        umount $boot_part
    fi
    ./multistrap-helpers/install-to-disk/chroot-to-disk.sh $conf "./2-install-grub.sh; exit;"
else 
    echo "INFO: Skipping Grub re-installation."
fi
echo
echo "All done."
echo "Test with VirtualBox (after completely detaching masa)"
