#!/usr/bin/env bash

function check_dependencies() {
	if ! type gh >/dev/null; then
		echo "gh is not installed"
		exit 1
	fi
	if ! type jq >/dev/null; then
		echo "jq is not installed"
		exit 1
	fi
	if ! type fzf >/dev/null; then
		echo "fzf is not installed"
		exit 1
	fi
}

function get_user_and_repo() {
	USERNAME="$(gh api /user --jq '.login')"
	REPO="$(gh repo list --source --json name --jq '.[].name' | fzf --prompt "Repo to delete all artifacts from: " --ansi --preview-label=" Repository informations " --preview "gh repo view {} --json name,description,updatedAt,visibility,owner,languages,licenseInfo,latestRelease,createdAt,homepageUrl,forkCount,id,issues --template '\
{{ if .name }}Repository: {{ .name  }}{{\"\n\"}}{{ end }}\
{{ if .id }}id: {{ .id  }}{{\"\n\"}}{{ end }}\
{{ if .description }}Description: {{ .description  }}{{\"\n\"}}{{ end }}\
{{ if .owner }}Owner: {{ .owner.login }}{{\"\n\"}}{{ end }}\
{{ if .issues }}Issues: {{ .issues.totalCount }}{{\"\n\"}}{{ end }}\
{{ if .forkCount }}Forks: {{ .forkCount  }}{{\"\n\"}}{{ end }}\
{{ if .createdAt }}Created: {{ timeago .createdAt }}{{\"\n\"}}{{ end }}\
{{ if .updatedAt }}Updated: {{ timeago .updatedAt }}{{\"\n\"}}{{ end }}\
{{ if .latestRelease }}Latest Release: {{ .latestRelease.name }} on {{ .latestRelease.publishedAt }}{{\"\n\"}}{{ end }}\
{{ if .languages }}Languages: {{range \$key, \$value := .languages}}{{\$value.node.name }} {{end}}{{\"\n\"}}{{ end }}\
{{ if .visibility }}Visibility: {{ .visibility  }}{{\"\n\"}}{{ end }}\
{{ if .licenseInfo }}License: {{ .licenseInfo.name  }}{{\"\n\"}}{{ end }}\
' | bat -p --color always -l yaml")"
}

function get_artifacts_from_repo() {
	ARTIFACTS="$(gh api "/repos/${USERNAME}/${REPO}/actions/artifacts" --jq '.artifacts[].id')"
	if [[ -z ${ARTIFACTS} ]]; then
		echo -e "${COLOR_REGULAR_RED:-}No artifact found in ${USERNAME}/${REPO}${COLOR_RESET:-}"
		exit 1
	fi
	NUMBER_OF_ARTIFACTS="$(echo "${ARTIFACTS}" | wc -l)"
	echo -e "${COLOR_REGULAR_RED:-}Found ${NUMBER_OF_ARTIFACTS} artifact$(if [[ $NUMBER_OF_ARTIFACTS -gt 1 ]]; then echo "s"; fi) to delete in ${USERNAME}/${REPO}${COLOR_RESET:-}"
}

function ask_for_confirmation() {
	read -p "Are you sure you want to delete all artifacts from ${REPO}? [y/N] " -n 1 -r
	echo
	if [[ ! ${REPLY} =~ ^[Yy]$ ]]; then
		echo "Aborted"
		exit 1
	fi
}

function delete_all_artifacts_from_repo() {
	for ARTIFACT in ${ARTIFACTS}; do
		echo -e "${COLOR_REGULAR_BLACK:-}Deleting artifact ${COLOR_REGULAR_RED:-}${ARTIFACT}${COLOR_REGULAR_BLACK:-} from ${USERNAME}/${REPO}${COLOR_RESET:-}"
		gh api --method DELETE "/repos/${USERNAME}/${REPO}/actions/artifacts/${ARTIFACT}"
	done
}

function main() {
	set -euo pipefail
	check_dependencies
	get_user_and_repo
	get_artifacts_from_repo
	ask_for_confirmation
	delete_all_artifacts_from_repo
}

main
