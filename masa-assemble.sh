#!/bin/bash
set -eu

root_mnt="/mnt/masa-root"
src="$root_mnt/snapshots/erik3/"
dest="$root_mnt/rootfs/"
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

HELP
    exit
}

# Parse command line arguments
# ---------------------------
# Initialize parameters
full=false
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

mountpoint $root_mnt || ./masa-attach.sh
[[ -d $dest ]] || ./assemble-backups.sh $src $dest
[[ $full = true ]] && tmp="/mnt/masa-assembly.tmp" || tmp=$dest
if $full; then
    [[ -d $tmp ]] && die "$tmp exists, not continuing."
    mkdir $tmp # create temporary directory for assembly: https://unix.stackexchange.com/q/558604/65781
    mount /dev/mapper/masa-root $tmp -o rw,subvol=rootfs
    mount UUID=7f7b9b8e-a773-4d4e-b448-ee194fd58a0f $tmp/boot
    rsync -avP --delete /boot/ $tmp/boot/
fi
./multistrap-helpers/install-to-disk/generate-scripts.sh -o $tmp $conf --update

if $full; then
    ./multistrap-helpers/do-chroot.sh $tmp "./2-install-grub.sh; exit;"
    umount $tmp/boot
    umount $tmp
    rmdir $tmp
fi
echo
echo "All done."
echo "Test with VirtualBox (after completely detaching masa)"
