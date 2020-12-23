wwn="ata-WDC_WD10JPLX-00MBPT0_JR1000BN2EUYPE"
lvm_name="masa"

# use ./get-disk-info.sh to identify the UUID's:
boot_part='UUID=7f7b9b8e-a773-4d4e-b448-ee194fd58a0f'
crypt_part='UUID=d8ede8f6-a295-401a-93d8-8f5e3d3f3f2e'

crypt_key="/home/ceremcem/.ssh/luks-keys/masa-key-1"

# you probably won't need to change those:
crypt_dev_name=${lvm_name}_crypt
root_dev=/dev/mapper/${lvm_name}-root
subvol=${subvol:-rootfs}
root_mnt="/mnt/$(basename $root_dev)"
rootfs_mnt="${root_mnt}-${subvol}"
