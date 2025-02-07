#!/usr/bin/env bash

function main() {
	set -euo pipefail
    "${@}"
    # shellcheck disable=SC2181
    while [ $? -eq 0 ]; do
        "${@}"
        sleep 3
    done
}

main "${@}"
