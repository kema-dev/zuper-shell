#!/usr/bin/env bash

function main() {
    set -euo pipefail
    local session_command
    session_command="$(basename "${1:-}")"
    local session_name
    session_name="${session_command}_$(date +%Y_%m_%d_%H_%M_%S)"
    tmux new-session -d -s "${session_name}"
    tmux send-keys -t "${session_name}" "$*" Enter
    echo "${session_name}"
}

main "${@}"
