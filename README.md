![erik-sync-screenshot](https://user-images.githubusercontent.com/6639874/45538780-a6123a00-b810-11e8-8225-fa2969e0a6ae.png)

# Description 

This is the backup toolset I'm currently using on my laptop. 

## Automatic Snapshots

Snapshots are automatically taken on every `apt-get install` command:

`/etc/apt/apt.conf.d/70smith-sync`:
```bash
// create a btrfs snapshot before (un)installing packages
Dpkg::Pre-Invoke {"/home/ceremcem/.sbin/erik-sync/take-snapshot.sh --with-skip-option";};
```

## Manual Snapshots

To take a snapshot manually:

    take-snapshot.sh

# Send snapshots to first external disk

This should be done every day or more often:

        heybe-sync.sh

# To skip 'mycontainer' backup

        sudo touch /var/lib/lxc/mycontainer/do-not-backup
