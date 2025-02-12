#!/usr/bin/env bash

function parse_args() {
	while [[ "${#}" -gt 0 ]]; do
		case "${1:-}" in
		--select)
			SELECT_SESSION="true"
			shift
			;;
		*)
			echo "Invalid argument: ${1:-}" >&2
			exit 1
			;;
		esac
	done
}

function get_profile_info() {
	local REQUESTED_INFO="${1:-}"
	if [[ -z "${REQUESTED_INFO}" ]]; then
		echo "No requested info provided" >&2
		exit 1
	fi
	local PROFILE_INFO
	PROFILE_INFO="$(grep -A 15 -P "^\[profile ${AWS_PROFILE}\]" <"${AWS_CONFIG_FILE}" | sed '/^$/q' | grep -oP "^${REQUESTED_INFO}\s*=\s*\K(.*)")"
	echo -n "${PROFILE_INFO}"
}

function open_profile_in_browser() {
	local START_URL
	START_URL="$(get_profile_info "sso_start_url")"
	if [[ -z "${START_URL}" ]]; then
		echo "No SSO start URL found for profile: ${AWS_PROFILE}" >&2
		exit 1
	fi
	local ROLE_NAME
	ROLE_NAME="$(get_profile_info "sso_role_name")"
	if [[ -z "${ROLE_NAME}" ]]; then
		echo "No SSO role name found for profile: ${AWS_PROFILE}" >&2
		exit 1
	fi
	local ACCOUNT_ID
	ACCOUNT_ID="$(get_profile_info "sso_account_id")"
	if [[ -z "${ACCOUNT_ID}" ]]; then
		echo "No SSO account ID found for profile: ${AWS_PROFILE}" >&2
		exit 1
	fi
	local REGION
	REGION="$(get_profile_info "region")"
	local CONSOLE_URL
	if [[ -z "${SELECT_SESSION:-}" ]]; then
		CONSOLE_URL="${START_URL}/#/console?account_id=${ACCOUNT_ID}&role_name=${ROLE_NAME}&destination=https://${REGION}.console.aws.amazon.com/console/home"
	else
		CONSOLE_URL="${START_URL}"
	fi
	echo "Console URL: ${CONSOLE_URL}"
	echo "START_URL: ${START_URL}"
	echo "ROLE_NAME: ${ROLE_NAME}"
	echo "ACCOUNT_ID: ${ACCOUNT_ID}"
	echo "REGION: ${REGION}"
	/opt/firefox_dev/firefox-bin --new-tab "${CONSOLE_URL}"
}

function main() {
	set -euo pipefail
	parse_args "${@}"
	open_profile_in_browser
}

main "${@}"
