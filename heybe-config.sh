wwn="ata-ST1000LM035-1RK172_WES0RD9E"
lvm_name="heybe"

# use ./get-disk-info.sh to identify the UUID's:
boot_part='UUID=f8ffebd3-cf35-4763-bfc7-a0969e83c7cc'
crypt_part='UUID=8167268b-657a-47d5-a7df-5dbe07e8d57b'
crypt_key="/home/ceremcem/.ssh/luks-keys/heybe-key-1"

# you probably won't need to change those:
crypt_dev_name=${lvm_name}_crypt
root_lvm=${lvm_name}-root
swap_lvm=${lvm_name}-swap
subvol=${subvol:-rootfs}

root_dev=/dev/mapper/${root_lvm}
swap_dev=/dev/mapper/${swap_lvm}
root_mnt="/mnt/$root_lvm"
rootfs_mnt="${root_mnt}-${subvol}"

