# Identify your disk (like UUID of a partition). Get this value from
# ./get-disk-info.sh:
wwn="usb-SanDisk_Cruzer_Glide_3.0_4C530001030827103162-0:0"

# Give a name to your LVM volumes. This is usually same as your
# installation name (eg. mysystem)
lvm_name="nar"

# Assign below variables *after* partitioning the disk
# (format-btrfs-swap-lvm-luks.sh... step)
# use ./get-disk-info.sh /dev/sdX again to identify the UUID's:
boot_part='UUID=a86e2d3b-5eaa-4dec-b88e-404b34e40a65'
crypt_part='UUID=3c2f1983-1cc6-4725-84df-32708dd09398'

# you probably won't need to change those:
crypt_dev_name=${lvm_name}_crypt
root_lvm=${lvm_name}-root
swap_lvm=${lvm_name}-swap
subvol=${subvol:-rootfs}

root_dev=/dev/mapper/${root_lvm}
swap_dev=/dev/mapper/${swap_lvm}
root_mnt="/mnt/$root_lvm"
rootfs_mnt="${root_mnt}-${subvol}"
