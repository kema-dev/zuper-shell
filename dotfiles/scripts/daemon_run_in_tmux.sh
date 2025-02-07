#!/usr/bin/env bash

function main() {
    set -euo pipefail
    if [[ -z "${1:-}" ]]; then
        echo "Usage: $0 <session_name> <command>" >&2
        return 1
    fi
    if [[ "${1:-}" == *_* ]]; then
        echo "Session name cannot contain _" >&2
        return 1
    fi
    local session_name
    session_name="${1:-}"
    shift
    if tmux has-session -t "${session_name}" 2>/dev/null; then
        exit 0
    fi
    local command
    command="$*"
    if [[ -z "${command}" ]]; then
        echo "No command provided" >&2
        return 1
    fi
    tmux new-session -d -s "${session_name}"
    tmux send-keys -t "${session_name}" "${command}" Enter
}

main "${@}"
