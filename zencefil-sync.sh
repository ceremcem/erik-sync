#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

safe_source $_dir/config.sh
safe_source $_dir/smith-sync/lib/all.sh

# All checks are done, run as root.
[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }

backup_machine_from_erik(){
    #local machine="fc2"
    local machine="$1"
    local src=$(get-latest-folder "$ROOTFS/snapshots/$machine")
    local src_name="$(basename $src)"
    echo_green "Backing up $src_name"
    local dest="$zencefil_mnt/sync/$machine"
    local snap_name="$zencefil_mnt/snapshots/$machine/$src_name"
    if [[ -e "$snap_name" ]]; then
        echo_yellow "Skipping $src_name because it's already snapshotted"
    else
        [[ -d "$dest" ]] || btrfs sub create "$dest"
        $_sdir/smith-sync/rsync.sh -u "$src/" "$dest/"
        [[ $? -eq 0 ]] && mkdir -p $(dirname "$snap_name"); btrfs sub snap -r "$dest" "$snap_name"
    fi
}

backup_machine_from_erik "erik/rootfs"
backup_machine_from_erik "erik/cca-heybe"
backup_machine_from_erik "fc2"


backup_from_aea3(){
    local machine="$1"
    local ssh_conn="aea@192.168.1.10"
    local ssh_settings="-p 2288 -i /home/ceremcem/.ssh/id_rsa"
    local remote_path="/mnt/peynir/snapshots/$machine"
    local glob_pattern="$(ssh $ssh_conn $ssh_settings ls $remote_path | sort)"
    local newest=
    for file in $glob_pattern ; do
        newest=$file
    done
    local src="$remote_path/$newest"
    local src_name="$(basename $src)"
    echo_green "Backing up REMOTE:$src"
    local dest="$zencefil_mnt/sync/$machine"
    local snap_name="$zencefil_mnt/snapshots/$machine/$src_name"
    if [[ -e "$snap_name" ]]; then
        echo_yellow "Skipping $src_name because it's already snapshotted"
    else
        [[ -d "$dest" ]] || { echo_red "$dest does not exist."; return 3; }
        $_sdir/smith-sync/rsync.sh -u --ssh="$ssh_settings" "$ssh_conn:$src/" "$dest/"
        [[ $? -eq 0 ]] && mkdir -p $(dirname "$snap_name"); btrfs sub snap -r "$dest" "$snap_name"
    fi
}

backup_from_aea3 "aea3"
backup_from_aea3 "aktos1"
backup_from_aea3 "aktos-cloud"
backup_from_aea3 "aktos-couch"
backup_from_aea3 "aktos-couch2"
backup_from_aea3 "aktos-git"
backup_from_aea3 "node-occ"
