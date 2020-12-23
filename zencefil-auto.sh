#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }

disk_exists(){
	if [[ -z $(udevadm info -n /dev/sd* | grep ID_SERIAL=WD_Elements_10A8_575833314536335946303730-0 | uniq) ]]; then
		return 1
	else
		return 0
	fi
}

if [[ "${1:-}" == "--poll" ]]; then
    echo "Polling: enabled."
    poll=true
else
    poll=false
fi

cd $_sdir
processed=false
while sleep 1; do
    if disk_exists; then
        if [[ "$processed" = false ]]; then
            notify-send "Backing up to zencefil."
            t0=$EPOCHSECONDS
            ./zencefil-attach.sh
            time ./zencefil-backup.sh
            ./zencefil-detach.sh
            t1=$EPOCHSECONDS
            notify-send -u critical "Backup of zencefil has ended." \
                "Took `date -d@$(($t1 - $t0)) -u +%H:%M:%S` seconds. Zencefil can be unplugged safely."
	    processed=true
            [[ "$poll" = false ]] && break
        fi
    else
        processed=false
    fi
done
echo "Exiting."
