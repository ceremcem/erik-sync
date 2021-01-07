#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
tools="../../smith-sync"

[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }

cd $_sdir
conf="btrbk.conf"
$tools/btrbk-gen-config $conf > $conf.calculated

$tools/btrbk -c $conf.calculated clean
$tools/btrbk -c $conf.calculated --progress ${1:-run}