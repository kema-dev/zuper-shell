#!/usr/bin/env bash

# shellcheck disable=SC2001
function main() {
	set -euo pipefail
	str="${*}"
	# Replace non-alphanumeric characters with -
	str="$(echo "${str}" | sd '[^a-zA-Z0-9]+' '-')"
	# Insert - between lower and upper case letters
	# shellcheck disable=SC2016
	str="$(echo "${str}" | sd '([a-z])([A-Z])' '$1-$2')"
	# Replace multiple - with single -
	str="$(echo "${str}" | sd '\-{2,}' '-')"
	# Convert to lowercase
	str="$(echo "${str}" | tr '[:upper:]' '[:lower:]')"
	# Remove leading -
	str="$(echo "${str}" | sd '^-*' '')"
	# Remove trailing -
	str="$(echo "${str}" | sd '\-*$' '')"
	echo "${str}"
}

main "${@}"
