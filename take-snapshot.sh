#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd $_sdir
conf=take-snapshot-btrbk.conf
./gen-config.sh $conf.orig > $conf

sudo ./btrbk -c $conf --progress ${@:-run}

