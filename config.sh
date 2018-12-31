# First BTRFS source path settings
ROOTFS="/mnt/masa"
ROOTFS_SNAP="$ROOTFS/snapshots/erik"
ROOTFS_LIVE="rootfs"

# Second BTRFS source path settings
HEYBE_SNAP="$ROOTFS/snapshots/erik"
HEYBE_LIVE="cca-heybe"

# Rollback location.
ROLLBACK_SNAPSHOT="$ROOTFS/rootfs_rollback"

# Zencefil
# ---------------------------------------------
# Local USB target disk settings (/dev/disk/by-id/$KNOWN_DISK)
zencefil_disk="usb-WD_Elements_10A8_575833314536335946303730-0:0"
zencefil_luks_uuid="5494c36d-0ecf-44ac-843a-adf9e0e12ea1"
zencefil_mnt="/mnt/zencefil"

# Heybe
# ---------------------------------------------
heybe_disk="wwn-0x5000c5009ce12c7d"
heybe_luks_uuid="d78e239f-1693-454e-8de0-233c5800fdac"
heybe_mnt="/mnt/heybe"
heybe_boot_mnt="${heybe_mnt}-boot"
heybe_boot_uuid="2d83832e-f1b1-44b7-a882-17dac6813afb"
