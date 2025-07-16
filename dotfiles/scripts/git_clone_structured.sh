#!/usr/bin/env bash

function get_branch_from_pull_request() {
    # Do not honor GH_HOST if running against github.com
    if [[ "${HOST}" == "github.com" ]]; then
        unset GH_HOST
    fi
    local BRANCH
    BRANCH="$(gh pr view --repo "${SELECTED_REPO}" "${PR_MR_NUMBER}" --json headRefName --jq '.headRefName' 2>/dev/null || glab mr view --repo "${SELECTED_REPO}" "${PR_MR_NUMBER}" --output json | jq '.source_branch' 2>/dev/null | tr -d '"')"
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
    local HOST_REGEX="^([^\/[:space:]]+)"
    local ORG_REGEX="([^\/[:space:]]+)"
    local REPO_REGEX="([^[:space:]]+?)(?:\.git)?"
    local GLOBAL_REGEX="${HOST_REGEX}\/${ORG_REGEX}\/${REPO_REGEX}"
    local PR_MR_NUMBER_REGEX="(?:\/(-\/)?(?:merge_requests|pull)\/([0-9]+))?$"
    local TREE_BLOB_REGEX="(?:\/(-\/)?(?:tree|blob)\/([^[:space:]]+))?$"
    if echo "${SELECTED_REPO}" | grep -qP "${GLOBAL_REGEX}"; then
        HOST="$(echo "${SELECTED_REPO}" | grep -oP "${HOST_REGEX}(?=.*)")"
        ORG="$(echo "${SELECTED_REPO}" | grep -oP "${HOST_REGEX}\/\K${ORG_REGEX}(?=.*)")"
        REPO="$(echo "${SELECTED_REPO}" | grep -oP "${HOST_REGEX}\/${ORG_REGEX}\/\K${REPO_REGEX}(?=$|\/[^\/[:space:]]+)")"
        PR_MR_NUMBER="$(echo "${SELECTED_REPO}" | grep -oP "${GLOBAL_REGEX}\K${PR_MR_NUMBER_REGEX}" | grep -oP "\/\K[0-9]+" || echo "")"
        TREE_BLOB_BRANCH_NAME="$(echo "${SELECTED_REPO}" | grep -oP "${GLOBAL_REGEX}\K${TREE_BLOB_REGEX}" | grep -oP "(tree|blob)\/\K([^\/[:space:]]+)(?=$|\/)" || echo "")"
    else
        echo "Failed to parse repository URL."
        return 1
    fi
    SELECTED_REPO="${HOST}/${ORG}/${REPO}"
    echo "Selected repo: ${SELECTED_REPO}"
    if [[ -n "${PR_MR_NUMBER:-}" ]]; then
        echo "Pull / Merge request number: ${PR_MR_NUMBER}"
    fi
    local BRANCH
    if [[ -n "${PR_MR_NUMBER:-}" ]]; then
        BRANCH="$(get_branch_from_pull_request)"
        if [[ -z "${BRANCH:-}" ]]; then
            echo "Failed to get branch from pull request."
            return 1
        fi
        echo "Found branch from pull request: ${BRANCH}"
    fi
    if [[ -n "${TREE_BLOB_BRANCH_NAME:-}" ]]; then
        echo "Branch name: ${TREE_BLOB_BRANCH_NAME}"
        if [[ -z "${BRANCH:-}" ]]; then
            BRANCH="${TREE_BLOB_BRANCH_NAME}"
        fi
    fi
    local REPO_DIR
    REPO_DIR="${KEMA_GIT_REPOS_DIR}/${SELECTED_REPO}"
    if [[ ! -d "${KEMA_GIT_REPOS_DIR}/${SELECTED_REPO}" ]]; then
        # shellcheck disable=SC2086
        git clone --recurse-submodules https://"${SELECTED_REPO}" "${REPO_DIR}"
    fi
    if [[ "${CODE_INTO}" -eq 1 ]]; then
        if [[ -n "${BRANCH:-}" ]]; then
            if ! git -C "${REPO_DIR}" branch --show-current | grep -q "^${BRANCH}$"; then
                git -C "${REPO_DIR}" fetch --all
                git -C "${REPO_DIR}" switch "${BRANCH}" || git -C "${REPO_DIR}" checkout "${BRANCH}"
            fi
            git -C "${REPO_DIR}" pull
        fi
        "${VISUAL:-}" "${REUSE_WINDOW:-}" "${REPO_DIR}"
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
