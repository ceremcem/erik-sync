#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd $_sdir
conf="zencefil-btrbk.conf"
./gen-config.sh $conf.orig > $conf

s=0
while sleep $s; do
    s=3
    sudo ./btrbk -c $conf clean && break
done

sudo ./btrbk -c $conf --progress ${1:-run}
