# Description 

![screenshot](https://user-images.githubusercontent.com/6639874/44114354-8f6ae384-a013-11e8-94cd-44799fc5e38c.png)

This is the sync toolset I'm using for backing up my laptop. 

## Automatic Snapshots

Snapshots are automatically taken on every `apt-get install` command:

`/etc/apt/apt.conf.d/70smith-sync`:
```bash
// create a btrfs snapshot before (un)installing packages
Dpkg::Pre-Invoke {"/home/ceremcem/.sbin/erik-sync/take-snapshot.sh";};
```

## Manual Snapshots

To take a snapshot manually:

    take-snapshot.sh

# Send snapshots to first external disk

This should be done every day or more often:

        heybe-sync.sh
