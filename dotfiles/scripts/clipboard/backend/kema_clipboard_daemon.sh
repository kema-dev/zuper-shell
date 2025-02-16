#!/usr/bin/bash

MAX_CB_FILES=1000

function get_clipboard() {
    # return empty string on non-text content (empty clip)
    xclip -selection clipboard -out 2>/dev/null || echo ""
}

function compute_hashed_name() {
    echo -n "${1:-}" | sha1sum | cut -d ' ' -f 1
}

function init_clipboard_manager() {
    if [[ ! -d "${KEMA_CLIPBOARD_MANAGER_DIR}" ]]; then
        mkdir -p "${KEMA_CLIPBOARD_MANAGER_DIR}"
    fi
    cd "${KEMA_CLIPBOARD_MANAGER_DIR}"
    local EXISTING_FILES
    EXISTING_FILES="$(ls -1t 2>/dev/null)"
    if [[ -z "${EXISTING_FILES}" ]]; then
        NUMBER_OF_FILES=0
    else
        NUMBER_OF_FILES="$(echo "${EXISTING_FILES}" | wc -l)"
    fi
    local NUMBER_OF_EXCESS_FILES
    NUMBER_OF_EXCESS_FILES="$((NUMBER_OF_FILES - MAX_CB_FILES))"
    if [[ "${NUMBER_OF_EXCESS_FILES}" -gt 0 ]]; then
        local EXCESS_FILES
        EXCESS_FILES="$(echo "${EXISTING_FILES}" | tail -n "${NUMBER_OF_EXCESS_FILES}")"
        # any filename containing a space will make this fail, however compute_hashed_name does not create files with spaces in the name
        # shellcheck disable=SC2086
        rm ${EXCESS_FILES}
        NUMBER_OF_FILES="$((NUMBER_OF_FILES - NUMBER_OF_EXCESS_FILES))"
    fi
    OLD_CLIPBOARD="$(get_clipboard)"
}

function add_to_cb_manager() {
    local CURRENT_CLIPBOARD_SUM
    CURRENT_CLIPBOARD_SUM="$(compute_hashed_name "${CURRENT_CLIPBOARD}")"
    local EXISTING_FILES
    EXISTING_FILES="$(ls -1t 2>/dev/null)"
    local COLLISION
    COLLISION="$(echo "${EXISTING_FILES}" | grep "${CURRENT_CLIPBOARD_SUM}" | head -n 1 || echo -n "")"
    echo -n "${CURRENT_CLIPBOARD}" >"${CURRENT_CLIPBOARD_SUM}"
    if [[ -z "${COLLISION}" ]]; then
        NUMBER_OF_FILES="$((NUMBER_OF_FILES + 1))"
    fi
    # any file created outside of this script will mess up the count, but counting each time is slower
    if [[ "${NUMBER_OF_FILES}" -gt "${MAX_CB_FILES}" ]]; then
        local OLDEST_FILE
        # shellcheck disable=SC2012
        OLDEST_FILE="$(ls -1t 2>/dev/null | tail -n 1)"
        rm "${OLDEST_FILE}"
        NUMBER_OF_FILES="$((NUMBER_OF_FILES - 1))"
    fi
}

function check_variables() {
    if [ -z "${KEMA_CLIPBOARD_MANAGER_DIR:-}" ]; then
        echo -e "${COLOR_REGULAR_RED:-}KEMA_CLIPBOARD_MANAGER_DIR not set${COLOR_RESET:-}" >&2
        exit 1
    fi
}

function main() {
    set -euo pipefail
    init_clipboard_manager
    while true; do
        clipnotify -s clipboard || exit 1
        CURRENT_CLIPBOARD="$(get_clipboard)"
        if [[ "${CURRENT_CLIPBOARD}" != "${OLD_CLIPBOARD}" && -n "${CURRENT_CLIPBOARD}" ]]; then
            add_to_cb_manager
            OLD_CLIPBOARD="${CURRENT_CLIPBOARD}"
        fi
    done
}

main
