#!/usr/bin/env bash

function print_ipv4_infos() {
    echo -e "${COLOR_REGULAR_BLUE:-}${1:-} INTERFACES${COLOR_RESET:-}"
    local JSON
    JSON="$(ip -f inet -json addr list)"
    local INTERFACES
    INTERFACES="$(echo "${JSON}" | jq -r '.[] | select(.operstate == "'"${1:-}"'")')"
    local TEXT
    TEXT="$(echo "${INTERFACES}" | jq -r '.ifname + " " + .addr_info[0].local')"
    local MAX_IFNAME
    MAX_IFNAME="$(echo "${TEXT}" | awk '{print length($1)}' | sort -nr | head -1)"
    echo "${TEXT}" | awk -v max_ifname="${MAX_IFNAME}" "{printf \"${COLOR_REGULAR_GREEN:-}%-*s${COLOR_RESET:-} ${COLOR_REGULAR_YELLOW:-}%-15s${COLOR_RESET:-}\n\", max_ifname, \$1, \$2}"
}

function main() {
    set -euo pipefail
    print_ipv4_infos "UNKNOWN"
    print_ipv4_infos "UP"
}

main
