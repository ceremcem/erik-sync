# Automatic

Snapshots are automatically taken on every `apt-get install ...`

/etc/apt/apt.conf.d/70smith-sync:
```bash
// create a btrfs snapshot before (un)installing packages
Dpkg::Pre-Invoke {"/home/ceremcem/.sbin/erik-sync/take-snapshot.sh";};
```

# Take Snapshot

To take a snapshot manually:

        take-snapshot.sh

# Send snapshots to Heybe

This should be done every day or more often:

        heybe-sync.sh
