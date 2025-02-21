# copy terminal buffer to clipboard and clear buffer
function cutbuffer() {
	if type clipcopy >/dev/null; then
		printf "%s" "${BUFFER}" | clipcopy && BUFFER="" && zle redisplay
	else
		printf "clipcopy not found\n"
	fi
}

# copy file content to clipboard
function copyfile {
	if type clipcopy >/dev/null; then
		if [[ -z "${1:-}" ]]; then
			echo "Usage: copyfile <filename>"
			return 1
		fi
		if [[ ! -f "${1:-}" ]]; then
			echo "File not found: ${1:-}"
			return 1
		fi
		emulate -L zsh
		clipcopy "${1:-}"
	else
		echo "clipcopy not found"
	fi
}

# copy file or directory path to clipboard
function copypath {
	if type clipcopy >/dev/null; then
		if [[ -z "${1:-}" ]]; then
			emulate -L zsh
			echo "${PWD}" | clipcopy
		else
			if [[ ! -e "${1:-}" ]]; then
				echo "File or directory not found: ${1:-}"
				return 1
			fi
			emulate -L zsh
			echo "${PWD}/${1:-}" | clipcopy
		fi
	else
		echo "clipcopy not found"
	fi
}

# kill a (space-)word sequence backward
function backward-kill-blank-word() {
	integer pos1 pos2
	pos2="${CURSOR}"
	pos1="${CURSOR}"
	while [[ "${pos1}" -gt 0 && "${BUFFER[${pos1}]}" == ' ' ]]; do
		((pos1--))
	done
	while [[ "${pos1}" -gt 0 && "${BUFFER[${pos1}]}" != ' ' ]]; do
		((pos1--))
	done
	if [[ "${pos1}" -lt "${pos2}" ]]; then
		BUFFER="${BUFFER[1, ${pos1}]}${RBUFFER}"
		CURSOR="${pos1}"
	fi
}

# kill a (space-)word sequence forward
function forward-kill-blank-word() {
	integer pos end
	pos=("${CURSOR}"+1)
	end=("${#BUFFER}"+1)
	while [[ "${pos}" -lt "${end}" && "${BUFFER[${pos}]}" == ' ' ]]; do
		((pos++))
	done
	while [[ "${pos}" -lt "${end}" && "${BUFFER[${pos}]}" != ' ' ]]; do
		((pos++))
	done
	if [[ "${pos}" -gt "${CURSOR}" ]]; then
		BUFFER="${LBUFFER}${BUFFER[${pos}, ${end}]}"
	fi
}

# search in history
function history_search_widget() {
	local SELECTION
	SELECTION="$(history | grep -oP "^\s*\d+\s+\K.*" | tac | awk '!seen[$0]++' | fzf --prompt "Command to run: " --scheme=history --query "${BUFFER}" --no-header)"
	if [[ -n "${SELECTION}" ]]; then
		BUFFER="$(echo -e "${SELECTION}")"
		CURSOR="${#BUFFER}"
	fi
}

# Paste the selected path(s) into terminal
# CREDITS https://github.com/junegunn/fzf
__fsel() {
	local item
	fzf "${@}" < /dev/tty | while read item; do
		echo -n "${(q)item} "
	done
	local ret=$?
	echo
	return $ret
}
insert-file-relpath() {
	LBUFFER="${LBUFFER}$(__fsel)"
	local ret=$?
	zle reset-prompt
	return $ret
}

function full_clear_screen() {
	clear
	zle reset-prompt
}

function watch() {
	if [[ -z "${1:-}" ]]; then
		echo "Usage: watch <command>"
		return 1
	fi
	while true; do
		clear
		date +"%Y-%m-%d %H:%M:%S"
		echo
		eval "${@}"
		sleep 1
	done
}

# init go mod for current directory, based on git remote origin
function gmi() {
	local repo_base
	repo_base="$(git remote get-url origin | sed -e 's|https://||g' -e 's|.git||g')"
	local path_from_git_root
	path_from_git_root="$(git rev-parse --show-prefix)"
	local repo_path
	repo_path="$(echo "${repo_base}/${path_from_git_root}" | sed -e 's|/$||g')"
	go mod init "${repo_path}"
}
