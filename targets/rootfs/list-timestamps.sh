#!/bin/bash

snapshot_dir=$(cat btrbk.conf | grep "\bsnapshot_dir\b" | awk '{print $2}')
volume=$(cat btrbk.conf | grep "\bvolume\b" | awk '{print $2}')
t="$volume/$snapshot_dir"
echo "$t"
../../smith-sync/list-backup-dates.sh $t > current-backups.list


