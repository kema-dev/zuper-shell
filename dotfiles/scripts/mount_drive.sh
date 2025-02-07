#!/usr/bin/env bash

function main() {
	set -euo pipefail
	local drive="${1:-}"
	if [[ -z "${drive}" ]]; then
		echo "No drive specified"
		return 1
	fi
	local mount_name="${2:-}"
	if [[ -z "${mount_name}" ]]; then
		echo "No mount name specified"
		return 1
	fi
	local mount_point="/mnt/${mount_name}"
	if [[ ! -d "${mount_point}" ]]; then
		sudo mkdir -p "${mount_point}"
	fi
	sudo mount "${drive}" "${mount_point}"
}

main "${@}"
