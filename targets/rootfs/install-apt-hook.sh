#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }

hook_file="/etc/apt/apt.conf.d/01take-snapshot"
echo "INFO: Registering ./take-snapshot.sh via $hook_file"
cat << EOF > $hook_file
// create a btrfs snapshot before (un)installing packages
Dpkg::Pre-Invoke {"$_sdir/take-snapshot.sh --with-skip-option";};
EOF

echo "INFO: Add the following line to /etc/sudoers:"
echo
echo "    $SUDO_USER ALL=(ALL:ALL) NOPASSWD: $_sdir/take-snapshot.sh"
echo