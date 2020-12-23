#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source

[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }

cd $_sdir
s=0
while sleep $s; do
    s=3
    ./multistrap-helpers/install-to-disk/attach-disk.sh zencefil-config.sh && break
done
