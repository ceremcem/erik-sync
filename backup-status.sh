#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -eu


echo "----------------"
$_sdir/smith-sync/list-backup-dates.sh /mnt/heybe-root/snapshots/erik3/
echo "----------------"
