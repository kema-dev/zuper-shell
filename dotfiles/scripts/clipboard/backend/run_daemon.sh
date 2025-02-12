#!/usr/bin/env bash

function check_variables() {
    if [ -z "${KEMA_SCRIPTS_DIR_PUBLIC:-}" ]; then
        echo -e "${COLOR_REGULAR_RED:-}KEMA_SCRIPTS_DIR_PUBLIC not set${COLOR_RESET:-}" >&2
        exit 1
    fi
}

function main() {
	set -euo pipefail
	check_variables
	local session_name="daemon-kema-clipboard-manager"
	local command
	command="while true; do (${KEMA_SCRIPTS_DIR_PUBLIC}/clipboard/backend/kema_clipboard_daemon.sh || tmux kill-session -t \"${session_name}\" ; sleep 1); done"
	"${KEMA_SCRIPTS_DIR_PUBLIC}/daemon_run_in_tmux.sh" "${session_name}" "${command}"
}

main "${@}"
