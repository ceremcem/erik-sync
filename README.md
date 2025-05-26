# Start a VM from an older backup 

```
cd tartget/yourtarget
./attach
./assemble-older-snap.sh 20250210T2335 # omit date to get list of available snapshots
./test-in-virtualbox.sh
```

Example:

```
ceremcem@erik3:kanat$ ./attach.sh 
  ACTIVE            '/dev/kanat/swap' [16.00 GiB] inherit
  ACTIVE            '/dev/kanat/root' [877.06 GiB] inherit
Mounting /dev/mapper/kanat-root
kanat is attached. (/mnt/kanat-root)
ceremcem@erik3:kanat$ ./assemble-older-snap.sh 
Using /mnt/kanat-root/rootfs as destination.
Date should be one of the followings:
20250206T0054
20250209T0459
20250210T2335
20250212T1001
20250212T2229
ceremcem@erik3:kanat$ ./assemble-older-snap.sh 20250212T1001
Using /mnt/kanat-root/rootfs as destination.
Recursively deleting /mnt/kanat-root/rootfs
Delete subvolume (no-commit): '/mnt/kanat-root/rootfs/var/tmp'
Delete subvolume (no-commit): '/mnt/kanat-root/rootfs/var/log'
Delete subvolume (no-commit): '/mnt/kanat-root/rootfs/var/lib/lxc/ubuntu-test/rootfs'
Delete subvolume (no-commit): '/mnt/kanat-root/rootfs/var/lib/lxc/rootfs.stable'
Delete subvolume (no-commit): '/mnt/kanat-root/rootfs/var/lib/lxc/owncloud/rootfs'
Delete subvolume (no-commit): '/mnt/kanat-root/rootfs/var/lib/lxc/fc-old/rootfs'
Delete subvolume (no-commit): '/mnt/kanat-root/rootfs/var/lib/lxc/fc4/rootfs'
Delete subvolume (no-commit): '/mnt/kanat-root/rootfs/var/lib/lxc/couchdb-erik/rootfs'
Delete subvolume (no-commit): '/mnt/kanat-root/rootfs/var/lib/lxc/antimony/rootfs'
Delete subvolume (no-commit): '/mnt/kanat-root/rootfs/var/lib/lxc/aecad/rootfs'
Delete subvolume (no-commit): '/mnt/kanat-root/rootfs/var/cache'
Delete subvolume (no-commit): '/mnt/kanat-root/rootfs/tmp'
Delete subvolume (no-commit): '/mnt/kanat-root/rootfs/home/ceremcem/VirtualBox_VMs'
Delete subvolume (no-commit): '/mnt/kanat-root/rootfs/home/ceremcem/temp'
Delete subvolume (no-commit): '/mnt/kanat-root/rootfs/home/ceremcem'
Delete subvolume (no-commit): '/mnt/kanat-root/rootfs'
Restoring /mnt/kanat-root/rootfs from backups (/mnt/kanat-root/snapshots/erik3/)
+ ./restore-backups.sh /mnt/kanat-root/snapshots/erik3/ /mnt/kanat-root/rootfs --date 20250212T1001
+ btrfs -q sub snap /mnt/kanat-root/snapshots/erik3//rootfs.20250212T1001 /mnt/kanat-root/rootfs
+ btrfs -q sub snap /mnt/kanat-root/snapshots/erik3//home/ceremcem.20250212T1001 /mnt/kanat-root/rootfs//home/ceremcem
+ btrfs -q sub snap /mnt/kanat-root/snapshots/erik3//home/ceremcem/temp.20250212T1001 /mnt/kanat-root/rootfs//home/ceremcem/temp
+ btrfs -q sub snap /mnt/kanat-root/snapshots/erik3//home/ceremcem/VirtualBox_VMs.20250212T1001 /mnt/kanat-root/rootfs//home/ceremcem/VirtualBox_VMs
+ btrfs -q sub snap /mnt/kanat-root/snapshots/erik3//var/cache.20250212T1001 /mnt/kanat-root/rootfs//var/cache
+ btrfs -q sub snap /mnt/kanat-root/snapshots/erik3//var/log.20250212T1001 /mnt/kanat-root/rootfs//var/log
+ btrfs -q sub snap /mnt/kanat-root/snapshots/erik3//var/lib/lxc/rootfs.stable.20250212T1001 /mnt/kanat-root/rootfs//var/lib/lxc/rootfs.stable
+ btrfs -q sub snap /mnt/kanat-root/snapshots/erik3//var/lib/lxc/aecad/rootfs.20250212T1001 /mnt/kanat-root/rootfs//var/lib/lxc/aecad/rootfs
+ btrfs -q sub snap /mnt/kanat-root/snapshots/erik3//var/lib/lxc/antimony/rootfs.20250212T1001 /mnt/kanat-root/rootfs//var/lib/lxc/antimony/rootfs
+ btrfs -q sub snap /mnt/kanat-root/snapshots/erik3//var/lib/lxc/couchdb-erik/rootfs.20250212T1001 /mnt/kanat-root/rootfs//var/lib/lxc/couchdb-erik/rootfs
+ btrfs -q sub snap /mnt/kanat-root/snapshots/erik3//var/lib/lxc/fc4/rootfs.20250212T1001 /mnt/kanat-root/rootfs//var/lib/lxc/fc4/rootfs
+ btrfs -q sub snap /mnt/kanat-root/snapshots/erik3//var/lib/lxc/fc-old/rootfs.20250212T1001 /mnt/kanat-root/rootfs//var/lib/lxc/fc-old/rootfs
+ btrfs -q sub snap /mnt/kanat-root/snapshots/erik3//var/lib/lxc/owncloud/rootfs.20250212T1001 /mnt/kanat-root/rootfs//var/lib/lxc/owncloud/rootfs
+ btrfs -q sub snap /mnt/kanat-root/snapshots/erik3//var/lib/lxc/ubuntu-test/rootfs.20250212T1001 /mnt/kanat-root/rootfs//var/lib/lxc/ubuntu-test/rootfs
+ set +x
Create subvolume '/mnt/kanat-root/rootfs/tmp'
Create subvolume '/mnt/kanat-root/rootfs/var/tmp'
Outdir is set to: /mnt/kanat-root/rootfs
Creating rootfs/1-make-bootable-rootfs.sh: OK (Updated)
Creating rootfs/2-install-grub.sh: OK (Updated)
Creating rootfs/3-finalize-and-update.sh: OK (Updated)
Creating rootfs/etc/crypttab: OK (Updated)
Creating rootfs/etc/default/grub.d/declare-resume-device.cfg: OK (Updated)
Creating rootfs/etc/fstab: OK (Updated)
Common subdirectories: /mnt/kanat-root/rootfs/boot.backup/grub and /mnt/kanat-root/rootfs/boot/grub
Common subdirectories: /mnt/kanat-root/rootfs/boot.backup/lost+found and /mnt/kanat-root/rootfs/boot/lost+found
Contents of /mnt/kanat-root/rootfs/boot has not been changed. 
WARNING: We should have compared the etc/default/grub** contents!
Skipping GRUB installation. (Use "--force-grub-install" if necessary.)

All done.
ceremcem@erik3:kanat$ ./test-in-virtualbox.sh 
Detaching kanat...
Unmounting /mnt/kanat-root
Deactivating LVM volume: /dev/mapper/kanat-root
Deactivating LVM volume: /dev/mapper/kanat-swap
Closing kanat_crypt: OK
Removing /mnt/kanat-root directory
kanat is detached.
Waiting for VM "kanat-testing" to power on...
VM "kanat-testing" has been successfully started.
```

# Description 

This is the backup toolset I'm currently using on my laptop. My hard disk configurations reside inside the `./targets/*` folders. There are 3 hard disks I'm using: 

* `masa` and `heybe` are the permanently installed disks on the laptop. 
* `zencefil` is the external usb disk. 
* `rootfs` is the virtual target that always operates on the disk I'm currently using (`masa`, `heybe` or `zencefil`).  

Normally I'm running my system from one of the installed disks (`masa` or `heybe`, does not matter) on the laptop. Periodic snapshots are taken automatically on the main disk. When the system is idle, the backups are transferred to the other installed disk. The other disk is always kept ready to boot the system with the latest transferred backup. 

If I plug the external usb disk, a dialog pops up and asks if I want to start the backup process or only start filesystem checking. The external disk is also left bootable with the latest backup after transferring the backups.  

## Features

> Assuming 6M files consuming 800GB disk space on a 1TB disk and there is another 1TB USB disk for backups.

1. Backup disk is always ready to boot the same (or similar) hardware in case of a hard disk or total system failure. Backup disks can always be tested via by using VirtualBox. Testing does not require rebooting the host system. 
2. Taking whole system snapshot(s)
     1. Requires less than 10 seconds
     2. Does not disturb the running system
     3. Guaranteed to be internally consistent
3. Space cost is negligible for a great number of snapshots. 
4. Sending changes to the physical backup disk costs an extra a few minutes at most, unlike ~20 mins. for Rsync. 
5. All backup operations are performed unattended (periodic, when system is idle, 
   on usb attach, etc) as well as on demand.
6. Whole data resides on a cryptographic layer. A stolen/lost external disk 
   or laptop does not cause a security breach. A failed hard disk can be safely thrown
   away (or sent to the service) without introducing a security flaw, such as an unauthorized data recovery attempt.
7. Whole disk is scrubbed in order to read all data and metadata blocks from all devices and verify checksums, automatically repair corrupted blocks if possible. Scrub request is issued every week and the process is continued whenever system is idle. Results are posted via e-mail.
8. Configuring a brand new external usb storage as a backup unit (partitioning, formatting, etc.) takes less than 5 minutes.
9. All dangerous operations are performed via dedicated tools and have proper error guards. 

#### Work In Progress

10. Only necessary files should be sent to the remote server (no cache/temporary files). (See [issue#9](https://github.com/ceremcem/erik-sync/issues/9))
11. Backups should be transferred over an unreliable network connection (should be resumable). Only necessary changes should be sent to the remote server. (See https://github.com/ceremcem/smith-sync/issues/10)
12. Backup disk on the remote site should always be ready to boot a similar hardware.
 
    > NOTE to myself: Kernel version differences *might* interfere with `chroot` operations
  
13. Data should be deduplicated. (See [issue#5](https://github.com/ceremcem/erik-sync/issues/5))

# Install 

```
git submodule update --init --recursive
sudo apt-get install tmux 
./targets/rootfs/install-apt-hook.sh
./scrub/install.sh
(cd ./on-idle && make)
```

# Manual Snapshots

To take a snapshot manually:

    ./targets/rootfs/take-snapshot.sh

# Run all services at once

    ./startup.service

# Exclude list

Subvolumes with name of `tmp` are not backed up. 

See ./smith-sync/btrbk-gen-config: exclude_list

# Scrubbing

A `scrub start` job is explicitly triggered by a `weekly` scheduled `systemd` service. See ./scrub. 

# Plug-n-backup

Backups are started upon plugging the disk named `zencefil`. This is controlled via `targets/zencefil/poll.sh` script, run by `./startup.service`. 

# Configuration 

There are a few configuration files involved: 

* `targets/{heybe,masa,zencefil}/config.sh`
* `scrub/credentials.sh`

# Disk Layout

Disk layout is configured by `smith-sync/multistrap-helpers/install-to-disk/format-btrfs-swap-lvm-luks.sh`.
