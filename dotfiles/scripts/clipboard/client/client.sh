#!/usr/bin/env bash

function check_variables() {
	if [ -z "${KEMA_SCRIPTS_DIR_PUBLIC:-}" ]; then
		echo -e "${COLOR_REGULAR_RED:-}KEMA_SCRIPTS_DIR_PUBLIC not set${COLOR_RESET:-}" >&2
		exit 1
	fi
	if [ -z "${KEMA_CLIPBOARD_MANAGER_DIR:-}" ]; then
		echo -e "${COLOR_REGULAR_RED:-}KEMA_CLIPBOARD_MANAGER_DIR not set${COLOR_RESET:-}" >&2
		exit 1
	fi
}

function main() {
	set -euo pipefail
	check_variables
	export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --bind 'ctrl-b:execute(rm {1})+abort+execute(${0})' --header 'ctrl-r : toggle sort | ctrl-\ : toggle preview | alt-\ toggle wrap | ctrl-b delete entry | alt-enter : print query | ctrl-space : select'"
	cd "${KEMA_CLIPBOARD_MANAGER_DIR}"
	local desired_file
	# avoid failing on early exit of fzf
	desired_file="$("${KEMA_SCRIPTS_DIR_PUBLIC}/find_fzf.sh" -f)" || true
	if [[ -z "${desired_file}" ]]; then
		exit 1
	elif [[ -f "${desired_file}" ]]; then
		xsel --input --clipboard <"${desired_file}"
	else
		echo "${desired_file}" | tr -d '\n' | xsel --input --clipboard
	fi
}

main
