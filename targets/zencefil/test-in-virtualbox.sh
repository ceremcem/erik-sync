#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
set -eu -o pipefail

"$_sdir/detach.sh"
VBoxManage startvm "zencefil-testing"

