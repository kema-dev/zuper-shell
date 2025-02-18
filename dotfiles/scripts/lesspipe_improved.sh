#!/usr/bin/env bash

function exit_script() {
	if [[ -n "${tmp_created}" ]]; then
		rm "${tmp_created}"
	fi
	exit "${1:-}"
}

function preview_dir() {
	eza --all --git --header --group --group-directories-first --color=always --icons --links --tree --level=2 --git-ignore "${input}"
	exit_script 0
}

function translate_type_to_bat() {
	case "${1:-}" in
	"shell") echo -n "sh" && return 0 ;;
	"batch") echo -n "bat" && return 0 ;;
	"javascript") echo -n "js" && return 0 ;;
	"latex") echo -n "tex" && return 0 ;;
	"perl") echo -n "pl" && return 0 ;;
	"powershell") echo -n "ps1" && return 0 ;;
	"python") echo -n "py" && return 0 ;;
	"rust") echo -n "rs" && return 0 ;;
	"jsonl") echo -n "json" && return 0 ;;
	esac
	echo -n "${1:-}"
}

function preview_file() {
	local bat_mimes
	bat_mimes="$(bat --list-languages | sed 's/svg//')"
	local file_ext
	file_ext="$(echo "${input}" | awk -F. '{print $NF}')"
	file_ext="$(translate_type_to_bat "${file_ext}")"
	if echo "${bat_mimes}" | grep -qP "${file_ext}[\s,]"; then
		bat --color=always --plain --number --language="${file_ext}" "${input}"
		exit_script 0
	fi
	local detected
	detected="$(magika --json "${input}" | jq -r '.[] | .result.value.output.extensions[], .result.value.output.group')"
	label="$(echo "${detected}" | awk 'NR==1')"
	label="$(translate_type_to_bat "${label}")"
	local group
	group="$(echo "${detected}" | awk 'NR==2')"
	if [[ "${group}" = image ]]; then
		local dim
		FZF_PREVIEW_LINES="$((("${FZF_PREVIEW_LINES}") * 2))"
		FZF_PREVIEW_COLUMNS="$((("${FZF_PREVIEW_COLUMNS}" - 1) * 2))"
		dim="${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}"
		if [[ "${dim}" = "x" ]]; then
			dim="$(stty size </dev/tty | awk '{print $2 "x" $1}')"
		fi
		chafa -f sixel -s "${dim}" "${input}"
		exiftool "${input}"
		exit_script 0
	fi
	if echo "${bat_mimes}" | grep -qP "${label}[\s,]"; then
		bat --color=always --plain --number --language="${label}" "${input}"
		exit_script 0
	else
		lesspipe.sh "${input}" | bat --color=always --plain --number || bat --color=always --plain --number "${input}"
		exit_script 0
	fi
}

function preview_color() {
	echo "Content is a color, previewing it"
	local color
	color="$(echo "${content}" | tr -d '#')"
	local red
	red="$((16#${color:0:2}))"
	local green
	green="$((16#${color:2:2}))"
	local blue
	blue="$((16#${color:4:2}))"
	printf "\e[48;2;%d;%d;%dm %s \e[0m\n" "${red}" "${green}" "${blue}" "${content}"
	exit_script 0
}

function main() {
	set -euo pipefail
	tmp_created=""
	if [[ $# -eq 0 ]]; then
		tmp_created="$(mktemp)"
		cat >"${tmp_created}"
		input="${tmp_created}"
	else
		input="${1:-}"
	fi
	if [[ "${input:0:1}" = "~" ]]; then
		local replaced_input
		if [[ "${input}" = "~" ]]; then
			replaced_input="${HOME}"
		else
			replaced_input="${HOME}${input:1}"
		fi
		if [[ -d "${replaced_input}" || -f "${replaced_input}" ]]; then
			input="${replaced_input}"
		fi
	fi
	if [[ -d "${input}" ]]; then
		preview_dir
	fi
	if [[ $(wc -l <"${input}") -eq 0 ]]; then
		local content
		content="$(cat "${input}")"
		if [[ -f "${content}" || -d "${content}" ]]; then
			echo "Content is a file or directory, previewing it"
			input="$(cat "${input}")"
			if [[ -d "${input}" ]]; then
				preview_dir
			fi
		elif echo "${content}" | grep -qP '^#?[0-9a-fA-F]{6}$'; then
			preview_color
		fi
	fi
	if [[ -f "${input}" ]]; then
		preview_file
	fi
	exit_script 1
}

main "${@}"
