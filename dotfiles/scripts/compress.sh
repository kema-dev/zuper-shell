#!/usr/bin/env bash

function select_compress_targets() {
    if [ ! "${#}" -eq 1 ]; then
        echo -e "${COLOR_REGULAR_RED:-}Please provide one directory to compress${COLOR_RESET:-}" >&2
        exit 1
    fi
    local dir
    dir="${1:-}"
    if [ ! -d "${dir}" ]; then
        echo -e "${COLOR_REGULAR_RED:-}Directory ${dir} does not exist${COLOR_RESET:-}" >&2
        exit 1
    fi
    local DIRS_CONTENTS
    DIRS_CONTENTS="$(find "${dir}" -mindepth 1)"
    SELECTABLE_TARGETS="$(echo "${dir}" | tr ' ' '\n' && echo "${DIRS_CONTENTS[*]}" | tr ' ' '\n')"
    COMPRESS_TARGETS="$(echo "${SELECTABLE_TARGETS}" | tr ' ' '\n' | fzf --prompt "Select targets to compress: " | tr '[:space:]' ' ' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    RECOMPUTED_COMPRESS_TARGETS=""
    if [ -z "${COMPRESS_TARGETS}" ]; then
        echo -e "${COLOR_REGULAR_RED:-}No targets selected${COLOR_RESET:-}" >&2
        exit 1
    fi
    if [ "$(echo "${COMPRESS_TARGETS}" | tr ' ' '\n' | wc -l)" -eq 1 ]; then
        if [ -d "${COMPRESS_TARGETS}" ]; then
            echo -e "${COLOR_REGULAR_GREEN:-}Stripping parent directories from target${COLOR_RESET:-}"
            cd "$(echo "${COMPRESS_TARGETS}" | tr -d '[:space:]')"
            RECOMPUTED_COMPRESS_TARGETS="."
        fi
    fi
}

function select_compress_algorithm() {
    local available_algorithms
    available_algorithms=("gzip" "bzip2" "xz" "zip" "7z")
    COMPRESSION_ALGORITHM="$(echo "${available_algorithms[*]}" | tr ' ' '\n' | fzf --prompt "Compression algorithm to use: " | tr -d '[:space:]')"
    if [ -z "${COMPRESSION_ALGORITHM}" ]; then
        echo -e "${COLOR_REGULAR_RED:-}No compression algorithm selected${COLOR_RESET:-}" >&2
        exit 1
    fi
}

function select_destination() {
    FZF_DEFAULT_OPTS="$(echo "${FZF_DEFAULT_OPTS}" | sed -e 's/--exit0//g' -e 's/--select-1//g')"
    DESTINATION="$(echo "" | fzf --bind 'enter:transform:echo print-query' --prompt "Select destination: " --preview-label=" Directory preview " --preview "${KEMA_SCRIPTS_DIR_PUBLIC}/lesspipe_improved.sh {fzf:query}" | tr -d '[:space:]')"
    if [ -z "${DESTINATION}" ]; then
        echo -e "${COLOR_REGULAR_RED:-}No destination selected${COLOR_RESET:-}" >&2
        exit 1
    fi
    if [ ! -d "${DESTINATION}" ]; then
        if [ -e "${DESTINATION}" ]; then
            echo -e "${COLOR_REGULAR_RED:-}Destination ${DESTINATION} is not a directory${COLOR_RESET:-}" >&2
            exit 1
        else
            echo -en "${COLOR_REGULAR_GREEN:-}"
            read -p "Directory ${DESTINATION} does not exists, create it? [y/N] " -n 1 -r
            echo -e "${COLOR_RESET:-}"
            if [[ ! "${REPLY}" =~ ^[Yy]$ ]]; then
                echo -e "${COLOR_REGULAR_RED:-}Exiting...${COLOR_RESET:-}" >&2
                exit 1
            else
                mkdir -p "${DESTINATION}"
            fi
        fi
    fi
}

function select_archive_name() {
    echo -en "${COLOR_REGULAR_GREEN:-}"
    read -p "Archive name: " -r
    echo -en "${COLOR_RESET:-}"
    ARCHIVE_NAME="${REPLY}"
    if [ -z "${ARCHIVE_NAME}" ]; then
        echo "No archive name provided"
        exit 1
    fi
    case "${COMPRESSION_ALGORITHM}" in
    "gzip")
        # shellcheck disable=SC2086
        ARCHIVE_NAME="${ARCHIVE_NAME}.tar.gz"
        ;;
    "bzip2")
        # shellcheck disable=SC2086
        ARCHIVE_NAME="${ARCHIVE_NAME}.tar.bz2"
        ;;
    "xz")
        # shellcheck disable=SC2086
        ARCHIVE_NAME="${ARCHIVE_NAME}.tar.xz"
        ;;
    "zip")
        # shellcheck disable=SC2086
        ARCHIVE_NAME="${ARCHIVE_NAME}.zip"
        ;;
    "7z")
        # shellcheck disable=SC2086
        ARCHIVE_NAME="${ARCHIVE_NAME}.7z"
        ;;
    *)
        echo -e "${COLOR_REGULAR_RED:-}Compression algorithm ${COMPRESSION_ALGORITHM} not supported${COLOR_RESET:-}" >&2
        exit 1
        ;;
    esac
    if [ -f "${DESTINATION}/${ARCHIVE_NAME}" ]; then
        echo -e "${COLOR_REGULAR_RED:-}Archive ${DESTINATION}/${ARCHIVE_NAME} already exists${COLOR_RESET:-}" >&2
        exit 1
    fi
}

function ask_for_confirmation() {
    echo -e "${COLOR_REGULAR_BLACK:-}Compressing ${COLOR_REGULAR_GREEN:-}$(echo -n "${COMPRESS_TARGETS}" | tr -s '[:space:]' ' ' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')${COLOR_REGULAR_BLACK:-} to ${COLOR_REGULAR_GREEN:-}${DESTINATION}/${ARCHIVE_NAME}${COLOR_RESET:-}"
    echo -en "${COLOR_REGULAR_GREEN:-}"
    read -p "Proceed? [y/N] " -n 1 -r
    echo -e "${COLOR_RESET:-}"
    if [[ ! "${REPLY}" =~ ^[Yy]$ ]]; then
        echo -e "${COLOR_REGULAR_RED:-}Exiting...${COLOR_RESET:-}" >&2
        exit 1
    fi
}

function compress() {
    if [ -n "${RECOMPUTED_COMPRESS_TARGETS}" ]; then
        COMPRESS_TARGETS="${RECOMPUTED_COMPRESS_TARGETS}"
    fi
    case "${COMPRESSION_ALGORITHM}" in
    "gzip")
        # shellcheck disable=SC2086
        tar -czvf "${DESTINATION}/${ARCHIVE_NAME}" ${COMPRESS_TARGETS}
        ;;
    "bzip2")
        # shellcheck disable=SC2086
        tar -cjvf "${DESTINATION}/${ARCHIVE_NAME}2" ${COMPRESS_TARGETS}
        ;;
    "xz")
        # shellcheck disable=SC2086
        tar -cJvf "${DESTINATION}/${ARCHIVE_NAME}" ${COMPRESS_TARGETS}
        ;;
    "zip")
        # shellcheck disable=SC2086
        zip -r "${DESTINATION}/${ARCHIVE_NAME}" ${COMPRESS_TARGETS}
        ;;
    "7z")
        # shellcheck disable=SC2086
        7za a "${DESTINATION}/${ARCHIVE_NAME}" ${COMPRESS_TARGETS}
        ;;
    *)
        echo -e "${COLOR_REGULAR_RED:-}Compression algorithm ${COMPRESSION_ALGORITHM} not supported${COLOR_RESET:-}" >&2
        exit 1
        ;;
    esac
}

function check_variables() {
    if [ -z "${KEMA_SCRIPTS_DIR_PUBLIC:-}" ]; then
        echo -e "${COLOR_REGULAR_RED:-}KEMA_SCRIPTS_DIR_PUBLIC not set${COLOR_RESET:-}" >&2
        exit 1
    fi
}

function main() {
    set -euo pipefail
    check_variables
    select_compress_targets "${@}"
    select_compress_algorithm
    select_destination
    select_archive_name
    ask_for_confirmation
    compress
}

main "${@}"
