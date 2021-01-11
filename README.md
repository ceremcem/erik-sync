# Description 

This is the backup toolset I'm currently using on my laptop. 

### Design considerations

> Assuming 6M files consuming 800GB space on a 1TB disk.

1. Taking snapshots should take less than 10 seconds and should not disturb the running
   system. 
2. Every snapshot should be in a consistent state. 
3. Great number of backups should be kept on hard disk with a negligible space costs. 
4. Sending changes to the physical backup disk should cost an extra 5 minutes at most. 
5. All backup operations should be performed unattended (periodic, when system is idle, 
   on usb attach, etc).
6. Every personal data should reside on a cryptographic layer. Stolen/lost external disk 
   or laptop shouldn't cause a security breach. A failed hard disk can be safely thrown
   away without introducing a security flaw, such as an unauthorized data recovery attempt.
7. In case of a hard disk failure, creating a new bootable system from the latest backups 
   should take less than 1 minute, without interaction.
8. Backup disk should be tested (including the "bootable" feature) without 
   interrupting the running system.
9. Configuring a brand new external usb storage as a backup unit should take less than 5 minutes.
10. All dangerous operations should have proper error guards so they can be performed in 
   highly stressful situations. 

##### Work In Progress

11. Only necessary changes should be sent to a remote server (no cache/temporary files).
12. Backups should be transferred over an unreliable network connection. Transfers should be resumable.

    > * BTRFS send/receive can not resume transfers 
    > * See https://unix.stackexchange.com/q/102620/65781

13. Backup disk on the remote site should always be ready to boot a similar hardware.
 
    > NOTE to myself: Kernel version differences would interfere with `chroot` operations
  
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
