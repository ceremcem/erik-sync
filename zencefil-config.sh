# Disk WWN:
# 
# 	ata-WDC_WD10JMVW-11AJGS1_WD-WX31E63YF070
# 
# UUID information: 
# 
# NAME   FSTYPE      FSVER LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINT
# sdc    zfs_member  23                                                              
# ├─sdc1 ext2        1.0         fe2cfe8c-28d3-455c-961e-b586cf763367                
# └─sdc2 crypto_LUKS 2           32d6e3b6-1e75-4d40-86c2-5a8853996e73                

wwn="ata-WDC_WD10JMVW-11AJGS1_WD-WX31E63YF070"
lvm_name="zencefil"

# use ./get-disk-info.sh to identify the UUID's:
boot_part='UUID=fe2cfe8c-28d3-455c-961e-b586cf763367'
crypt_part='UUID=32d6e3b6-1e75-4d40-86c2-5a8853996e73'
crypt_key="/home/ceremcem/.ssh/luks-keys/zencefil-key-1"

# you probably won't need to change those:
crypt_dev_name=${lvm_name}_crypt
root_dev=/dev/mapper/${lvm_name}-root
subvol=${subvol:-rootfs}
root_mnt="/mnt/$(basename $root_dev)"
rootfs_mnt="${root_mnt}-${subvol}"


# root passwd: mynewbox
