# Description 

This is the backup toolset I'm currently using on my laptop. 

## Features

> Assuming 6M files consuming 800GB disk space on a 1TB disk.

1. Taking whole system snapshot(s) requires less than 10 seconds and does not disturb the running
   system while every snapshot is guaranteed to be internally consistent. 
2. Great number of backups are kept on hard disk with a negligible space cost. 
3. Sending changes to the physical backup disk costs an extra of 5 minutes at most. 
4. All backup operations are performed unattended (periodic, when system is idle, 
   on usb attach, etc) as well as on demand.
5. Whole data resides on a cryptographic layer. A stolen/lost external disk 
   or laptop does not cause a security breach. A failed hard disk can be safely thrown
   away (or sent to the service) without introducing a security flaw, such as an unauthorized data recovery attempt.
6. Whole disk is scrubbed in order to read all data and metadata blocks from all devices and verify checksums, automatically repair corrupted blocks if possible. Scrub request is issued every week and the process is continued whenever system is idle. Results are posted via e-mail.
7. Backup disk is always ready to boot the same or similar hardware in case of a hard disk or total system failure.
8. Backup disk can be fully tested via VirtualBox. 
9. Configuring a brand new external usb storage as a backup unit (partitioning, formatting, etc.) takes less than 5 minutes.
10. All dangerous operations are performed via dedicated tools and have proper error guards. 

#### Work In Progress

11. Only necessary files should be sent to the remote server (no cache/temporary files). (See [issue#9](https://github.com/ceremcem/erik-sync/issues/9))
12. Backups should be transferred over an unreliable network connection (should be resumable). Only necessary changes should be sent to the remote server. (See https://github.com/ceremcem/smith-sync/issues/10)
13. Backup disk on the remote site should always be ready to boot a similar hardware.
 
    > NOTE to myself: Kernel version differences *might* interfere with `chroot` operations
  
14. Data should be deduplicated. (See [issue#5](https://github.com/ceremcem/erik-sync/issues/5))

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

Backups are started upon plugging the disk named `zencefil`. This is controlled via `zencefil/poll.sh` script, run by `./startup.service`. 
