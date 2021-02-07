#!/bin/bash
set -eu

containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

targets=( $(find targets/ -name "current-backups.list") )

merged=( $(cat "${targets[@]}" | sort -n -r | uniq) )

echo "------------------------------------------------------"
# Header
for target in "${targets[@]}"; do
    target_name="$(basename $(dirname $target))"
    column_str=$(printf "%-13s" $target_name)
    echo -n "  $column_str  |"
done
echo
echo "------------------------------------------------------"
# Body
for backup in "${merged[@]}"; do
    for target in "${targets[@]}"; do
        if grep -q "$backup" "$target"; then
            echo -n "  $backup  |"
        else
            echo -n "  -------------  |"
        fi
    done
    echo
done
echo "------------------------------------------------------"
