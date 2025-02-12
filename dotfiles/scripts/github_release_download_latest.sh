#!/usr/bin/env bash

function parse_args() {
	local USAGE_STRING
	USAGE_STRING="Usage: ${0:-} <repo_github_path> <binary_pattern> [--dir <extract dir>]"
	if [[ "${#}" -lt 1 ]]; then
		echo "${USAGE_STRING}"
		exit 1
	fi
	while [[ "${#}" -gt 0 ]]; do
		if [[ "${1:-}" == "--help" ]]; then
			echo "${USAGE_STRING}"
			exit 0
		elif [[ "${1:-}" == "--dir" ]]; then
			shift
			EXTRACT_DIR="${1:-}"
			shift
		elif [[ "${1:-}" == *"/"* ]]; then
			REPO_GITHUB_PATH="${1:-}"
			shift
		else
			BINARY_PATTERN="${1:-}"
			shift
		fi
	done
	if [[ -z "${BINARY_PATTERN:-}" ]]; then
		BINARY_PATTERN="linux.+amd64"
		echo -e "${COLOR_REGULAR_YELLOW:-}Binary pattern not provided, using default pattern ${COLOR_REGULAR_GREEN:-}${BINARY_PATTERN:-}${COLOR_RESET:-}"
	fi
	if [[ -z "${EXTRACT_DIR:-}" ]]; then
		EXTRACT_DIR="${KEMA_DEV_DIR}/tools"
		echo -e "${COLOR_REGULAR_YELLOW:-}Extract directory not provided, using default directory ${COLOR_REGULAR_GREEN:-}${EXTRACT_DIR:-}${COLOR_RESET:-}"
	fi
	if [[ -z "${REPO_GITHUB_PATH:-}" ]]; then
		echo "${USAGE_STRING}"
		exit 1
	fi
}

function download_latest_release() {
	echo -e "${COLOR_REGULAR_BLACK:-}Downloading latest release from ${COLOR_REGULAR_GREEN:-}${REPO_GITHUB_PATH:-}${COLOR_REGULAR_BLACK:-} with binary pattern ${COLOR_REGULAR_GREEN:-}${BINARY_PATTERN:-}${COLOR_RESET:-}"
	DOWNLOAD_DIR="/tmp/${REPO_GITHUB_PATH}"
	BINARY_NAME_MATCH="$(gh release view --repo "${REPO_GITHUB_PATH:-}" --json 'assets' --jq '.assets[] | select(.name | test("'"${BINARY_PATTERN:-}"'")) | .name')"
	if [[ -z "${BINARY_NAME_MATCH:-}" ]]; then
		echo -e "${COLOR_REGULAR_RED:-}Failed to get binary name${COLOR_RESET:-}"
		exit 1
	fi
	BINARY_NAME="${BINARY_NAME_MATCH}"
	if wc -l <<<"${BINARY_NAME_MATCH}" | grep -qP '^\d+$'; then
		BINARY_NAME="$(echo "${BINARY_NAME_MATCH}" | head -n 1)"
		CHECKSUM_FILE="$(echo "${BINARY_NAME_MATCH}" | grep -P '\.sha256|\.md5' || true)"
		if [[ -n "${CHECKSUM_FILE:-}" ]]; then
			echo -e "${COLOR_REGULAR_BLACK:-}Checksum file: ${COLOR_REGULAR_GREEN:-}${CHECKSUM_FILE}${COLOR_RESET:-}"
			gh release download --repo "${REPO_GITHUB_PATH:-}" --pattern "${CHECKSUM_FILE:-}" --dir "${DOWNLOAD_DIR}" --clobber
		fi
		SIGNATURE_FILE="$(echo "${BINARY_NAME_MATCH}" | grep -P '\.asc|\.sig' || true)"
		if [[ -n "${SIGNATURE_FILE:-}" ]]; then
			echo -e "${COLOR_REGULAR_BLACK:-}Signature file: ${COLOR_REGULAR_GREEN:-}${SIGNATURE_FILE}${COLOR_RESET:-}"
			gh release download --repo "${REPO_GITHUB_PATH:-}" --pattern "${SIGNATURE_FILE:-}" --dir "${DOWNLOAD_DIR}" --clobber
		fi
	fi
	echo -e "${COLOR_REGULAR_BLACK:-}Binary name: ${COLOR_REGULAR_GREEN:-}${BINARY_NAME}${COLOR_RESET:-}"
	gh release download --repo "${REPO_GITHUB_PATH:-}" --pattern "${BINARY_NAME:-}" --dir "${DOWNLOAD_DIR}" --clobber
	echo -e "${COLOR_REGULAR_BLACK:-}Downloaded binary to ${COLOR_REGULAR_GREEN:-}${DOWNLOAD_DIR}/${BINARY_NAME:-}${COLOR_RESET:-}"
}

function extract_binary() {
	local TOOL_EXTRACT_DIR
	TOOL_EXTRACT_DIR="${EXTRACT_DIR}/${REPO_GITHUB_PATH}"
	mkdir -p "${TOOL_EXTRACT_DIR}"
	local BINARY_PATH
	BINARY_PATH="${DOWNLOAD_DIR}/${BINARY_NAME:-}"
	if [[ ! -f "${BINARY_PATH:-}" ]]; then
		echo -e "${COLOR_REGULAR_RED:-}Failed to find binary ${BINARY_PATH:-}${COLOR_RESET:-}"
		exit 1
	fi
	echo -e "${COLOR_REGULAR_BLACK:-}Extracting binary ${COLOR_REGULAR_GREEN:-}${BINARY_PATH:-}${COLOR_RESET:-} to ${COLOR_REGULAR_GREEN:-}${EXTRACT_DIR:-}${COLOR_RESET:-}"
	if [[ "${BINARY_NAME:-}" == *".tar.gz" ]]; then
		tar -xzf "${BINARY_PATH:-}" -C "${TOOL_EXTRACT_DIR:-}"
	elif [[ "${BINARY_NAME:-}" == *".zip" ]]; then
		unzip -o "${BINARY_PATH:-}" -d "${TOOL_EXTRACT_DIR:-}"
	elif grep -vqP '.+\.[a-zA-Z0-9]+' <<<"${BINARY_NAME:-}"; then
		chmod +x "${BINARY_PATH:-}"
		cp "${BINARY_PATH:-}" "${TOOL_EXTRACT_DIR:-}"
		exit 1
	fi
	echo -e "${COLOR_REGULAR_BLACK:-}Extracted binary to ${COLOR_REGULAR_GREEN:-}${TOOL_EXTRACT_DIR:-}${COLOR_RESET:-}"
}

function check_variables() {
	if [ -z "${KEMA_DEV_DIR:-}" ]; then
		echo -e "${COLOR_REGULAR_RED:-}KEMA_DEV_DIR not set${COLOR_RESET:-}" >&2
		exit 1
	fi
}

function main() {
	set -euo pipefail
	check_variables
	parse_args "${@}"
	download_latest_release
	extract_binary
}

main "${@}"
