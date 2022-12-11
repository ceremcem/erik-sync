# Moving active disk to a backup disk

* Create missing directories (/var/tmp) within the rootfs/ directory 
* Transfer files that are explicitly excluded from synchronization (all `tmp` directories)
* Transfer any readonly snapshots (FIXME: This should already be done within the synchronization process)
* Reboot with the new disk
1. ./rootfs/update-config.sh
2. Update ./*/btrbk.conf files accordingly (FIXME: this should be automatic)
3. Do manual backups
...TODO: complete this howto

