#!/usr/bin/env bash

function usage() {
	if [[ "${#}" -ne 2 ]]; then
		echo "Usage: ${0:-} <key name> <target>"
		exit 1
	fi
	if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
		echo "Usage: ${0:-} <key name> <target>"
		exit 0
	fi
}

function populate_default_values() {
	DATE_TODAY="$(date -I)"
	USER_NAME="$(whoami)"
	HOST_NAME="$(hostname | grep -oP '^[^.]+')"
}

function check_key_name() {
	if [[ -z "${1:-}" ]]; then
		echo "The key name is empty."
		exit 1
	fi
	echo "${1:-}"
	if [[ ! "${1:-}" =~ ^[a-zA-Z0-9_]+\.key$ ]]; then
		echo "The key name should be alphanumeric and _ only."
		exit 1
	fi
	if [[ -f "${KEMA_SSH_KEYS_DIR}/${1:-}" ]]; then
		echo "The key name is already in use."
		exit 1
	fi
}

function main() {
	set -euo pipefail
	usage "${@}"
	populate_default_values
	check_key_name "${1:-}.key"
	ssh-keygen -t ed25519 -C "- ${USER_NAME}@${HOST_NAME} - ${2:-} - ${DATE_TODAY}" -f "${KEMA_SSH_KEYS_DIR}/${1:-}.key"
}

main "${@}"
