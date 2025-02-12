#!/usr/bin/env bash

function generate_repos_github() {
    local GH_API_HOSTS
    GH_API_HOSTS="$(yq 'keys | .[]' <"${HOME}/.config/gh/hosts.yml")"
    if [[ -z "${GH_API_HOSTS}" ]]; then
        return
    fi
    for GH_API_HOST in ${GH_API_HOSTS}; do
        gh api --hostname "${GH_API_HOST}" --paginate /user/repos --jq ".[] | \"${GH_API_HOST}/\(.full_name)\""
    done
}

function generate_repos() {
    generate_repos_github
}

function main() {
    set -euo pipefail
    generate_repos
}

main "${@}"
