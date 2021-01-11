# Description 

This is the backup toolset I'm currently using on my laptop. 

### Design considerations

> Assuming 6M files consuming 800GB space on a 1TB disk.

1. Taking whole system snapshot(s) requires less than 10 seconds and does not disturb the running
   system. 
2. Every snapshot is in an internally consistent state. 
3. Great number of backups are kept on hard disk with a negligible space cost. 
4. Sending changes to the physical backup disk costs an extra of 5 minutes at most. 
5. All backup operations are performed unattended (periodic, when system is idle, 
   on usb attach, etc) as well as on demand.
6. Whole data resides on a cryptographic layer. A stolen/lost external disk 
   or laptop does not cause a security breach. A failed hard disk can be safely thrown
   away (or sent to the service) without introducing a security flaw, such as an unauthorized data recovery attempt.
7. Backup disk is always ready to boot the same or similar hardware in case of a hard disk or total system failure.
8. Backup disk can be fully tested via VirtualBox. 
9. Configuring a brand new external usb storage as a backup unit (partitioning, formatting, etc.) takes less than 5 minutes.
10. All dangerous operations are performed via dedicated tools and have proper error guards. 

##### Work In Progress

11. Only necessary changes should be sent to a remote server (no cache/temporary files).
12. Backups should be transferred over an unreliable network connection. Transfers should be resumable. (See https://github.com/ceremcem/smith-sync/issues/10)
13. Backup disk on the remote site should always be ready to boot a similar hardware.
 
    > NOTE to myself: Kernel version differences *might* interfere with `chroot` operations
  
14. Data should be deduplicated.

    > See https://btrfs.wiki.kernel.org/index.php/Deduplication#Duplicate_file_finders_with_btrfs_support

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
