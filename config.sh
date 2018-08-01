#!/bin/bash
# VERY IMPORTANT
set -o errexit -o pipefail -o nounset 
#DEBUG=true

# First BTRFS source path settings
ROOTFS="/mnt/masa"
ROOTFS_SNAP="$ROOTFS/snapshots"
ROOTFS_LIVE="rootfs"

# Second BTRFS source path settings
HEYBE_SNAP="$ROOTFS/snapshots"
HEYBE_LIVE="cca-heybe"

# Rollback location.
ROLLBACK_SNAPSHOT="$ROOTFS/rootfs_rollback"

# Zencefil
# ---------------------------------------------
# Local USB target disk settings (/dev/disk/by-id/$KNOWN_DISK)
zencefil_disk="usb-WD_Elements_10A8_575833314536335946303730-0:0"
zencefil_luks_uuid="5494c36d-0ecf-44ac-843a-adf9e0e12ea1"
zencefil_mnt="/mnt/zencefil"
