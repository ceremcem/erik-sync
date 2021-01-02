#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. $_sdir/smith-sync/lib/basic-functions.sh

# show help
show_help(){
    cat <<HELP
    $(basename $0) [options]
    Options:
        --dry-run           : Dry run, don't touch anything actually
        --with-skip-option  : Ask if that backup should be skipped or not.

HELP
    exit
}

# Parse command line arguments
# ---------------------------
# Initialize parameters
action="run"
relaunch_args=""
# ---------------------------
args=("$@")
_count=1
while :; do
    key="${1:-}"
    case $key in
        -h|-\?|--help)
            show_help    # Display a usage synopsis.
            exit
            ;;
        # --------------------------------------------------------
        --dry-run) shift
            action="dryrun"
            relaunch_args="$relaunch_args --dry-run"
            ;;
        --with-skip-option) shift
            if prompt_yes_no "Take a backup first? (You SHOULD)"; then
                # Answered "yes"
                echo_green "OK, backing up"
            else
                # Answered "no"
                echo_yellow "Skipping backup!"
                exit 0
            fi
            ;;
        # --------------------------------------------------------
        -*)
            echo
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)  # generate the positional arguments: $_arg1, $_arg2, ...
            [[ ! -z ${1:-} ]] && declare _arg$((_count++))="$1" && shift
    esac
    [[ -z ${1:-} ]] && break
done; set -- "${args[@]}"
# use $_arg1 in place of $1, $_arg2 in place of $2 and so on, "$@" is intact

# All checks are done, run as root.
[[ $(whoami) = "root" ]] || { sudo $0 $relaunch_args; exit 0; }


# backup boot partition contents 
rsync -avP /boot/ /boot.backup/

cd $_sdir
conf=take-snapshot-btrbk.conf
./gen-config.sh $conf.orig > $conf

sudo ./btrbk -c $conf --progress $action
[[ "$action" == "run" ]] && \
    echo $EPOCHSECONDS > /tmp/take-snapshot.last-run.txt
