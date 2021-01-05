#!/bin/bash
set -eu
sudo ./assemble-bootable-system.sh -c zencefil-config.sh --from snapshots/erik3/ "$@"
