#!/usr/bin/env bash

function main() {
	set -euo pipefail
	local CMD
	CMD="$(basename "${1:-}")"
	if [[ -z "${CMD}" ]]; then
		echo "Usage: help >"
		return
	fi
	local HELP_FOUND=false
	[[ -d "${2:-}" ]] && "${KEMA_SCRIPTS_DIR_PUBLIC}/lesspipe_improved.sh" "${2:-}" 2>/dev/null && echo && HELP_FOUND=true
	grep -qP "alias ${1:-}=" "${KEMA_ALIASES_LIST_PATH}" >/dev/null 2>&1 &&
		grep -P "alias ${1:-}=" "${KEMA_ALIASES_LIST_PATH}" | bat --color always -p -l sh 2>/dev/null &&
		CMD="$(grep -P "alias ${1:-}=" "${KEMA_ALIASES_LIST_PATH}" 2>/dev/null | cut -d= -f2 | tr -d "'" | tr -d '"' | cut -d' ' -f1)" && echo && HELP_FOUND=true
	tldr "${CMD}" >/dev/null 2>&1 && tldr --color always "${CMD}" 2>/dev/null | bat --color always -p 2>/dev/null && echo && HELP_FOUND=true
	man "${CMD}" >/dev/null 2>&1 && man "${CMD[@]}" 2>/dev/null | bat --color always -p -l man 2>/dev/null && echo && HELP_FOUND=true
	which "${CMD}" 2>/dev/null && echo && HELP_FOUND=true
	[[ -f "${2:-}" ]] && "${KEMA_SCRIPTS_DIR_PUBLIC}/lesspipe_improved.sh" "${2:-}" 2>/dev/null && echo && HELP_FOUND=true
	[[ "${HELP_FOUND}" == false ]] && echo "No help found for ${CMD}"
}

main "${1:-}" "${2:-}"
