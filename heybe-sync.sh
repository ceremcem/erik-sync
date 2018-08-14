#!/bin/bash
set -eu -o pipefail
set_dir(){ _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; }; set_dir
safe_source () { source $1; set_dir; }
# end of bash boilerplate

# Algorithm
# ------------
# 1. Find the common snapshots in these two disks
# 2. If no common snapshots are found,
#      * send the newest one (with .partial extension, then remove the extension when done)
#      * send the rest with diffs (if in full-sync mode)
# 3. If there are common snapshots:
#      * choose the newest one
#      * send the diff between the common snapshot and the newest snapshot

safe_source $_dir/config.sh
safe_source $_dir/smith-sync/lib/all.sh

#-------------------------------------------------------------
require_different_disks () {
    if [[ $(mount_point_of $1) = $(mount_point_of $2) ]]; then
        echo_err "Source and destination are on the same disk!"
    fi
}

get_subvol_list(){
    btrfs sub list -R -u -r "$1"
}
find_common_sub(){
    local s=$1  # source
    local d=$2  # destination
    get_subvol_list $(mount_point_of $s) | while read -r ssub; do
        s_rcv=`echo $ssub | get_line_field received_uuid`
        s_id=`echo $ssub | get_line_field uuid`
        s_path=`echo $ssub | get_line_field path`
        get_subvol_list $(mount_point_of $d) | while read -r dsub; do
            d_rcv=`echo $dsub | get_line_field received_uuid`
            d_id=`echo $dsub | get_line_field uuid`
            d_path=`echo $dsub | get_line_field path`
            if [[ $s_rcv = $d_rcv ]] || [[ $s_id = $d_rcv ]]; then
                # match found
                src_subvol="$(mount_point_of $s)/$s_path"
                dst_subvol="$(mount_point_of $d)/$d_path"

                # print if subvolume is below the source path
                if [[ $src_subvol = $s/* ]]; then
                    echo $src_subvol
                fi
            fi
        done
        #echo $ssub
    done
}
list_subvol_below () {
    local path=$1
    local mnt=$(mount_point_of $path)
    local rel_path=${path#$mnt/}
    btrfs sub list $mnt | get_line_field 'path' | while read -r sub; do
        if [[ $sub = $rel_path/* ]]; then
            echo $mnt/$sub
        fi
    done
}

containsElement () {
    # taken from https://stackoverflow.com/a/8574392/1952991
    local e match="$1"
    shift
    for e; do [[ "$e" == "$match" ]] && return 0; done
    return 1
}

get_snapshot_roots(){
    # finds incrementally snapshotted subvolume paths
    local dirs=`list_subvol_below $1 | xargs dirname | sort | uniq`
    local excludes=()
    for i in $dirs; do
        for j in $dirs; do
            if [[ $j = $i/* ]]; then
                # $i is parent, so should be removed from output
                excludes+=( $i )
                break
            fi
        done
    done
    for out in $dirs; do
        if containsElement $out "${excludes[@]}"; then
            continue
        fi
        echo $out
    done
}

#-------------------------------------------------------------

s=$ROOTFS_SNAP
d=$heybe_mnt/snapshots

[[ $(whoami) = "root" ]] || { sudo $0 $*; exit 0; }

echo "from $s to $d"

# source and destination should be on different disks
require_different_disks $s $d

#echo "listing subvols below $s"
#list_subvol_below $s

src_mnt=$(mount_point_of $s)
dst_mnt=$(mount_point_of $d)

echo "snap roots:"
for _snap_root in $(get_snapshot_roots $s); do
    snap_root=${_snap_root#$src_mnt/}
    echo "Syncing $snap_root"
    list_subvol_below $src_mnt/$snap_root
    echo "-----------         ------------"
    echo "the subvolumes that are already sent:"
    find_common_sub "$src_mnt/$snap_root" "$dst_mnt/$snap_root"
    echo "--------------------------------"
done

exit

echo "common subvols"
find_common_sub $s $d
latest_common=`find_common_sub $s $d | sort | head`
echo "found latest common: $latest_common"


exit

echo "machines to sync:"
common=$(find_common_sub $s $d)
find_machines $s | while read -r machine; do
    echo "=== $machine ==="
    set +ue
    _common=`echo $common | grep $machine | sort | head`
    if [[ ! -z $_common ]]; then
        echo "..using common: $_common"
        machine_latest=$_common
    else
        echo "...USE RSYNC!!!!"
        exit FIXME
        machine_latest=$latest_common
    fi
    set -ue
    list_subvol_below $machine | while read -r snap; do
        [[ $machine_latest = $snap ]] && continue
        dest_path=$(dirname $d/${snap#$s})
        mkdir -p $dest_path

        # FIXME: use previously sent snapshot as machine_latest

        #echo "will send the snapshot: $snap to $dest_path"
        btrfs send -p $machine_latest $snap | pv | btrfs receive $dest_path
    done
    #echo $machine_latest
done
