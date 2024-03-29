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
