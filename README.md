# Description 

This is the backup toolset I'm currently using on my laptop. 

## Automatic Snapshots (Prior to apt-get install)

Snapshots are automatically taken on every `apt-get install` command:

`/etc/apt/apt.conf.d/70smith-sync`:
```bash
// create a btrfs snapshot before (un)installing packages
Dpkg::Pre-Invoke {"/home/ceremcem/.sbin/erik-sync/take-snapshot.sh --with-skip-option";};
```

## Manual Snapshots

To take a snapshot manually:

    take-snapshot.sh

# Send snapshots to first external disk (masa)

This should be done every day or more often:

        masa-auto.sh

# Exclude list

Subvolumes with name of `tmp` are not backed up. 


# Scrub 

A `scrub start` job is explicitly triggered by a `weekly` scheduled `systemd` service. See ./scrub. 

Any interrupted scrubs are continued `on-idle`, see `~/startup.service`.

# Plug-n-backup

Backups are started upon plugging the disk named `zencefil`. This is controlled via `zencefil-auto.sh --poll` script. See `~/startup.service`. 
