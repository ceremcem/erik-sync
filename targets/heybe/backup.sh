#!/bin/bash
set -o pipefail
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
tools="../../smith-sync"

[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }

cd $_sdir
conf="btrbk.conf"
$tools/btrbk-gen-config $conf > $conf.calculated

$tools/btrbk -c $conf.calculated clean
tf=$(mktemp)
trap "rm -f $tf" EXIT
$tools/btrbk -c $conf.calculated --progress -v ${1:-run} | tee $tf
[[ $? -eq 0 ]] || exit $?
grep '^!!!' -q $tf && exit 1

# Snapshots are succesfully backed up
exit 0
