#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

"$_sdir/detach.sh"
VBoxManage startvm "masa-testing"

