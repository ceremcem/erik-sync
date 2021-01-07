#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
set -eu

cd $_sdir
sudo ../../smith-sync/assemble-bootable-system.sh \
    -c ./config.sh \
    --from snapshots/erik3/ \
    --boot-backup boot.backup \
    "$@"
