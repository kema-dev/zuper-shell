#!/usr/bin/env bash

function get_branch_from_pull_request() {
    # Do not honor GH_HOST if running against github.com
    if [[ "${HOST}" == "github.com" ]]; then
        unset GH_HOST
    fi
    local BRANCH
    BRANCH="$(gh pr view --repo "${SELECTED_REPO}" "${PULL_REQUEST_NUMBER}" --json headRefName --jq '.headRefName')"
    if [[ -z "${BRANCH}" ]]; then
        echo "Failed to get branch from pull request."
        return 1
    fi
    echo "${BRANCH}"
}

function fuzzy_clone() {
    CODE_INTO=0
    while [[ "${1:-}" == -* ]]; do
        case "${1}" in
        --code)
            CODE_INTO=1
            shift
            ;;
        --reuse-window)
            REUSE_WINDOW="--reuse-window"
            shift
            ;;
        *)
            echo "Unknown option: ${1}"
            return 1
            ;;
        esac
    done
    SELECTED_REPO=""
    if [[ -z "${1:-}" ]]; then
        local -a REPOS
        REPOS="$("${KEMA_SCRIPTS_DIR_PUBLIC}/completion_generate_git_clone.sh")"
        SELECTED_REPO="$(echo "${REPOS[@]}" | fzf --prompt "Repository to clone: " --preview-label=" Repository description " --preview 'gh repo view {1}')"
    else
        SELECTED_REPO="${1:-}"
        SELECTED_REPO="${SELECTED_REPO#https://}"
    fi
    if [[ -z "${SELECTED_REPO}" ]]; then
        echo "No repository selected."
        return 1
    fi
    if [[ "${SELECTED_REPO}" == *"/"*"/"* ]]; then
        :
    elif [[ "${SELECTED_REPO}" == *"/"* ]]; then
        SELECTED_REPO="${GH_HOST:-github.com}/${SELECTED_REPO}"
    else
        local GH_USER
        GH_USER="$(gh api user --jq '.login')"
        if [[ -z "${GH_USER}" ]]; then
            echo "GitHub user not found and repository not fully qualified"
            return 1
        fi
        SELECTED_REPO="${GH_HOST:-github.com}/${GH_USER}/${SELECTED_REPO}"
    fi
    if [[ "${SELECTED_REPO}" =~ ^([^\/]+)\/([^\/]+)\/([\/a-zA-Z0-9]+?)(\/pull\/([0-9]+))?$ ]]; then
        HOST="${BASH_REMATCH[1]}"
        ORG="${BASH_REMATCH[2]}"
        REPO="${BASH_REMATCH[3]/.git/}"
        echo "Host: ${HOST}"
        echo "Org: ${ORG}"
        echo "Repo: ${REPO}"
        if [[ -n "${BASH_REMATCH[5]}" ]]; then
            PULL_REQUEST_NUMBER="${BASH_REMATCH[5]}"
            echo "Pull request number: ${PULL_REQUEST_NUMBER}"
        fi
    else
        echo "Failed to parse repository URL."
        return 1
    fi
    SELECTED_REPO="${HOST}/${ORG}/${REPO}"
    echo "Selected repo: ${SELECTED_REPO}"
    if [[ -n "${PULL_REQUEST_NUMBER:-}" ]]; then
        echo "Pull request number: ${PULL_REQUEST_NUMBER}"
    fi
    if [[ -n "${PULL_REQUEST_NUMBER:-}" ]]; then
        local BRANCH
        BRANCH="$(get_branch_from_pull_request)"
        if [[ -z "${BRANCH}" ]]; then
            echo "Failed to get branch from pull request."
            return 1
        fi
        echo "Found branch from pull request: ${BRANCH}"
    fi
    local REPO_DIR
    REPO_DIR="${KEMA_GIT_REPOS_DIR}/${SELECTED_REPO}"
    if [[ ! -d "${KEMA_GIT_REPOS_DIR}/${SELECTED_REPO}" ]]; then
        # shellcheck disable=SC2086
        git clone --recurse-submodules https://"${SELECTED_REPO}" "${REPO_DIR}"
    fi
    if [[ "${CODE_INTO}" -eq 1 ]]; then
        if [[ -n "${PULL_REQUEST_NUMBER:-}" ]]; then
            if ! git -C "${REPO_DIR}" branch --show-current | grep -q "^${BRANCH}$"; then
                git -C "${REPO_DIR}" fetch --all
                git -C "${REPO_DIR}" switch "${BRANCH}"
            fi
            git -C "${REPO_DIR}" pull
        fi
        code "${REUSE_WINDOW:-}" "${REPO_DIR}"
    fi
}

function check_variables() {
    if [ -z "${KEMA_SCRIPTS_DIR_PUBLIC:-}" ]; then
        echo -e "${COLOR_REGULAR_RED:-}KEMA_SCRIPTS_DIR_PUBLIC not set${COLOR_RESET:-}" >&2
        exit 1
    fi
    if [ -z "${KEMA_GIT_REPOS_DIR:-}" ]; then
        echo -e "${COLOR_REGULAR_RED:-}KEMA_GIT_REPOS_DIR not set${COLOR_RESET:-}" >&2
        exit 1
    fi
}

function main() {
    set -euo pipefail
    check_variables
    fuzzy_clone "${@}"
}

main "${@}"
