#!/bin/bash
set -o pipefail
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
tools="../../smith-sync"

[[ $(whoami) = "root" ]] || exec sudo "$0" "$@"

cd $_sdir
conf="btrbk.conf"
echo "Calculating the btrbk configuration file"
$tools/btrbk-gen-config $conf > $conf.calculated

logs_dir="$_sdir/logs"
mkdir -p $logs_dir
tf="$logs_dir/$(date +'%Y%m%dT%H%M').log"
echo "Starting backup process..."
$tools/btrbk -c $conf.calculated clean
$tools/btrbk -c $conf.calculated --progress -v ${1:-run} | tee $tf
[[ $? -eq 0 ]] || exit $?
grep '^!!!' -q $tf && exit 1

echo "Backup is successful"
exit 0
