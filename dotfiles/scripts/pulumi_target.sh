#!/usr/bin/env bash

function parse_args() {
	while [[ "${#}" -gt 0 ]]; do
		case "${1:-}" in
		--no-deps)
			export NO_DEPS=0
			shift
			;;
		*)
			echo "Invalid argument: ${1:-}" >&2
			exit 1
			;;
		esac
	done
	export NO_DEPS_ARG
	if [[ -n "${NO_DEPS:-}" ]]; then
		NO_DEPS_ARG=""
	else
		NO_DEPS_ARG="--target-dependents"
	fi
}

function get_preview_json() {
	export TARGETS_FILE
	TARGETS_FILE="$(mktemp)"
	trap 'rm -f "${TARGETS_FILE}"' EXIT
	pulumi preview --json > "${TARGETS_FILE}"
}

function select_targets() {
	export SELECTED_TARGETS
	SELECTED_TARGETS="$(jq -r '.steps[] | select(.diffReasons != null) | .urn' <"${TARGETS_FILE}" | fzf --prompt "Targets: " --preview-label=" Target infos " --delimiter : --with-nth=7.. --preview "jq '.steps[] | select(.urn == \"{}\") | {diffs: .diffReasons, old: .oldState.outputs, new: .newState.outputs}' ${TARGETS_FILE} | yq --input-format json --output-format yaml --colors")"
}

function run_pulumi_up() {
	local TAREGTS_ARGS
	TAREGTS_ARGS="$(echo -n "${SELECTED_TARGETS}" | sed "s|^| --target |g")"
	# shellcheck disable=SC2086
	echo pulumi up "${NO_DEPS_ARG}" ${TAREGTS_ARGS}
}

function main() {
	set -euo pipefail
	parse_args "${@}"
	get_preview_json
	select_targets
	run_pulumi_up
}

main "${@}"
