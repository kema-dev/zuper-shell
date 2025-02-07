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

# search in directory stack history
function dirstack_search_widget() {
	local SELECTION
	SELECTION="$(sed "s|${HOME}|~|g" <"${KEMA_DIRSTACK_HISTORY_PATH}" | tac | awk '!seen[$0]++' | fzf --prompt "Where to cd: " --preview-label=" Directory preview " --scheme=path --query "${BUFFER}" --preview "${KEMA_SCRIPTS_DIR_PUBLIC}/lesspipe_improved.sh {1}")"
	if [[ -n "${SELECTION}" ]]; then
		BUFFER="cd ${SELECTION}"
		CURSOR="${#BUFFER}"
	fi
	if [[ "$(wc -l <"${KEMA_DIRSTACK_HISTORY_PATH}")" -gt 10000 ]]; then
		tail -n 10000 <"${KEMA_DIRSTACK_HISTORY_PATH}" | sponge "${KEMA_DIRSTACK_HISTORY_PATH}"
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

# Run a script from KEMA_SCRIPTS_DIR_PUBLIC
_ks() {
	local curcontext="$curcontext" state line
	typeset -A opt_args

	_arguments -C \
		"1: :_files -W \"${KEMA_SCRIPTS_DIR_PUBLIC}\" -g \"*.sh\""
}
ks() {
	local script="${1:-}"
	if [[ -z "${script}" ]]; then
		echo "No script specified"
		return 1
	fi
	if [[ ! -f "${KEMA_SCRIPTS_DIR_PUBLIC}/${script}" ]]; then
		echo "Script not found"
		return 1
	fi
	"${KEMA_SCRIPTS_DIR_PUBLIC}/${script}" "${@:2}"
}
compdef _ksp ksp

# Fuzzy cd
function cf() {
	if [[ $# -ne 0 ]]; then
		cd "${@}" || return 1
	fi
	TMP_CD_DIR="$(fzf --prompt "Where to cd: " --preview-label=" Directory preview " --scheme=path --walker=dir,follow,hidden --delimiter ":" --preview "${KEMA_SCRIPTS_DIR_PUBLIC}/lesspipe_improved.sh {1}")"
	if [ -n "${TMP_CD_DIR}" ]; then
		cd "${TMP_CD_DIR}" || return 1
	else
		cd - >/dev/null || return 1
	fi
	unset TMP_CD_DIR
}

# Fuzzy file open
function of() {
	if [[ $# -ne 0 ]]; then
		cd "${@}" || return 1
	fi
	TMP_FILE_PATH="$(find . -type f -print 2>/dev/null | sed "s|^\./||" | sort | fzf --prompt "What to open: " --preview-label=" File preview " --scheme=path --delimiter ":" --preview "${KEMA_SCRIPTS_DIR_PUBLIC}/lesspipe_improved.sh {1}")"
	if [ -n "${TMP_FILE_PATH}" ]; then
		xdg-open "${TMP_FILE_PATH}"
	fi
	cd - >/dev/null || return 1
	unset TMP_FILE_PATH
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

# gcl is a native oh-my-zsh command
unalias gcl
gcl() {
	"${KEMA_SCRIPTS_DIR_PUBLIC}/git_clone_structured.sh" "${@}"
}

gclc() {
	"${KEMA_SCRIPTS_DIR_PUBLIC}/git_clone_structured.sh" --code "${@}"
}

gclcr() {
	"${KEMA_SCRIPTS_DIR_PUBLIC}/git_clone_structured.sh" --code --reuse-window "${@}"
}

_gcl() {
	local curcontext="$curcontext" state line
	typeset -A opt_args

	local -a arguments
	arguments="$("${KEMA_SCRIPTS_DIR_PUBLIC}/completion_generate_git_clone.sh")"

	_arguments -C \
		"1: :_values 'git clone' ${arguments}"
}
compdef _gcl gcl
compdef _gcl gclc
