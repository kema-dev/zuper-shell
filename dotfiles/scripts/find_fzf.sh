#!/usr/bin/env bash

function parse_options() {
    SHOW_FILENAME_FZF_OPTION="1"
    IGNORE_REGEXES=("\.git/" "node_modules/" "vendor/" "dist/")
    IGNORE_REGEX="$(echo "${IGNORE_REGEXES[@]}" | tr ' ' '|')"
    while getopts ":hf" opt; do
        case ${opt} in
        h)
            echo "Usage: find_fzf.sh [OPTIONS] <match regex for files>"
            echo "Search current directory's files' content using fzf and output file's relative path"
            echo "Options:"
            echo "  -h  Display this help message"
            echo "  -f  Disable filename displaying"
            exit 0
            ;;
        f)
            SHOW_FILENAME_FZF_OPTION="2"
            shift
            ;;
        \?)
            echo "Invalid option: ${OPTARG}" 1>&2
            exit 1
            ;;
        esac
    done
    MATCH_REGEXES=("")
    for arg in "${@}"; do
        MATCH_REGEXES+=("${arg}")
    done
    MATCH_REGEX="$(echo "${MATCH_REGEXES[@]}" | tr ' ' '|' | sed 's/^|//')"
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
    if pwd | grep -qP '^/$'; then
        echo "Running this script from / would cause messy recursion, aborting"
        exit 1
    fi
    parse_options "${@}"
    # avoid splitting on file names with spaces
    IFS=$'\n'
    for file in $(find . -type f -printf '%T@^%p\n' | sort -n --reverse | cut -d'^' -f 2- | sed 's/\.\///' | grep -vP "${IGNORE_REGEX}"); do
        if [ -n "${MATCH_REGEX}" ]; then
            if ! echo "${file}" | grep -qP "${MATCH_REGEX}"; then
                continue
            fi
        fi
        echo -en "${COLOR_REGULAR_BLACK:-}${file}:${COLOR_REGULAR_GREEN:-}"
        if [ "$(stat --printf="%s" "${file}")" -gt 100000 ]; then
            echo "File too large, will not be searchable"
            continue
        fi
        tr -s '[:space:]' ' ' <"${file}"
        echo
    done | (
        unset IFS
        fzf \
            --with-nth="${SHOW_FILENAME_FZF_OPTION}.." \
            --delimiter : \
            --preview-window ':+{2}/6,~6' \
            --preview "${KEMA_SCRIPTS_DIR_PUBLIC}/lesspipe_improved.sh {1}" |
            cut -d':' -f1
    )
}

main "${@}"
