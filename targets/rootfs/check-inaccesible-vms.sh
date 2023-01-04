#!/usr/bin/env bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
set -u

file="$_sdir/known_inaccessible_vms.txt"
touch "$file"
readarray -t known_vms < <(cat "$file" \
    | grep -v "^#" \
    | grep -v "^$" \
    )
# (skip empty and comment lines)

# debug
#echo "${known_vms[*]}"

error=0
while read -r vm; do
    uuid=$(echo "$vm" | awk '{print $NF}')
    if [[ " ${known_vms[*]} " =~ " ${uuid} " ]]; then
        # Skip checking known inaccessible VMs
        echo "...Skipping known inaccessible vm: $vm"
        continue
    fi
    error=1
    echo "Inaccessible VM found: $vm"
done <<< $(VBoxManage list vms | grep inaccessible)

exit $error
