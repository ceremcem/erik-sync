# Description 

This is the backup toolset I'm currently using on my laptop. 

# Install 

```
git submodule update --init --recursive
./targets/rootfs/install-apt-hook.sh
(cd ./on-idle && make)
hash tmux || sudo apt-get install tmux 
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
