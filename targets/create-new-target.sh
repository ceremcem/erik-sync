#!/bin/bash
set -eu

if [[ -z ${1:-} ]]; then
    echo "Usage: "
    echo
    echo "      $(basename $0) [--delete] my-new-target"
    echo
    exit 1
fi
if [[ "${1:-}" == "--delete" ]]; then
    git submodule deinit -f -- $2
else
    git submodule add git@github.com:ceremcem/smith-sync-new-target $1
fi
