#!/usr/bin/env bash

function parse_args() {
	while [[ "${#}" -gt 0 ]]; do
		case "${1:-}" in
		--no-login)
			NO_LOGIN="true"
			shift
			;;
		*)
			echo "Invalid argument: ${1:-}" >&2
			exit 1
			;;
		esac
	done
}

function select_profile() {
	if [[ -z "${AWS_CONFIG_FILE}" ]]; then
		echo "AWS_CONFIG_FILE is not set" >&2
		exit 1
	elif [[ ! -f "${AWS_CONFIG_FILE}" ]]; then
		echo "AWS_CONFIG_FILE (${AWS_CONFIG_FILE}) does not exist" >&2
		exit 1
	fi
	AVAILABLE_PROFILES="$(grep -P "^\[profile " "${AWS_CONFIG_FILE}" | sed -E 's/^\[profile (.*)\]/\1/')"
	SELECTED_PROFILE_FZF="$(echo "${AVAILABLE_PROFILES}" | fzf --prompt "AWS profile to use: " --preview-label=" Profile configuration " --preview "grep -A 15 -P '^\[profile {}\]' <${AWS_CONFIG_FILE} | sed '/^$/q' | bat -p --color always -l toml")"
	SELECTED_PROFILE="$(echo "${SELECTED_PROFILE_FZF}" | tr -d '[:space:]')"
	echo -e "${COLOR_REGULAR_BLACK:-}Selected profile: ${COLOR_REGULAR_GREEN:-}${SELECTED_PROFILE}${COLOR_RESET:-}"
	if [[ -z "${SELECTED_PROFILE}" ]]; then
		echo "No profile selected"
		exit 1
	fi
	if [[ -z "${NO_LOGIN:-}" ]]; then
		if [[ -z $(aws sts get-caller-identity --profile "${SELECTED_PROFILE}") ]]; then
			aws sso login --profile "${SELECTED_PROFILE}"
		fi
	fi
	# NOTE sourcing the file is necessary and done in the alias in order to propagate the env var to the calling shell
	echo "${SELECTED_PROFILE}" >"${HOME}/.aws/selected_sso_profile"
	echo -e "${COLOR_REGULAR_BLACK:-}Connected profile: ${COLOR_REGULAR_GREEN:-}${SELECTED_PROFILE}${COLOR_RESET:-}"
}

function main() {
	set -euo pipefail
	parse_args "${@}"
	select_profile
}

main "${@}"
