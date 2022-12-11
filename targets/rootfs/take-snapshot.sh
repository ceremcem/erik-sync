#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. $_sdir/../../smith-sync/lib/basic-functions.sh

# show help
show_help(){
    cat <<HELP
    $(basename $0) [options]
    Options:
        --dry-run           : Dry run, don't touch anything actually
        --with-skip-option  : Ask if that backup should be skipped or not.
        --update-config     : Only update config files

    Configuration folder:
        ./exclude           : Folder with files where the filenames are
                              the postfixes to exclude from removal

HELP
    exit
}

mkdir -p $_sdir/exclude

# All checks are done, run as root.
[[ $(whoami) = "root" ]] || exec sudo "$0" "$@"

# Parse command line arguments
# ---------------------------
# Initialize parameters
action="run"
update_config=false
btrbk_args=()
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
            echo "INFO: This is dry run."
            action="dryrun"
            ;;
        --with-skip-option) shift
            if prompt_yes_no "Take a backup first? (You SHOULD)"; then
                # Answered "yes"
                echo_green "OK, backing up"
            else
                # Answered "no"
                echo_yellow "Skipping backup!"
                exit 0
            fi
            ;;
        --update-config) shift
            echo "Updating config files only."
            update_config=true
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

cd $_sdir
conf="btrbk.conf"
get_root_mntpoint(){
    # returns the mountpoint where the root subvolume mounted which holds the actual rootfs.
    mount | grep $(cat /etc/fstab | awk '$2 == "/" {print $1}') | grep "\bsubvolid=5\b" | awk '{print $3}'
}
echo $(get_root_mntpoint) > $_sdir/current_rootfs_mntpoint.txt
cat "${conf}.template" | sed -e "s|{{actual_rootfs_mountpoint}}|$(get_root_mntpoint)|" > $conf
../../smith-sync/btrbk-gen-config $conf > $conf.calculated
echo "Generated $conf.calculated"

$update_config && { echo "Done."; exit 0; }

# Exclude the snapshots from removal
for i in `ls $_sdir/exclude`; do
    timestamp=$(cat $_sdir/exclude/$i)
    btrbk_args+=(--exclude '*'.$timestamp)
done

echo "Excluded snapshots: ${btrbk_args[@]}"

# make sure that everything is written on the disk
echo "Syncing..."
sync

echo "Backup boot partition contents"
[[ $action == "dryrun" ]] || rsync -avP --delete /boot/ /boot.backup/

sudo ../../smith-sync/btrbk -c $conf.calculated --progress $action "${btrbk_args[@]}"
[[ "$action" == "run" ]] && \
    echo $EPOCHSECONDS > /tmp/take-snapshot.last-run.txt

. $_sdir/backup-status.sh
echo
echo "Done."
