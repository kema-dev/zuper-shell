#!/usr/bin/env bash

function select_instance() {
	local NODE_NAMES
	NODE_NAMES="$(kubectl get nodes --no-headers)"
	local SELECTED_INSTANCE_ID
	# TODO Add tags preview for other resources (ecs, ...) not only ec2
	SELECTED_INSTANCE_ID="$(echo "${NODE_NAMES}" | fzf --prompt "Instance to connect to: " --preview-label=" Instance informations " --preview "echo SSM description: && aws ssm describe-instance-information --instance-information-filter-list key=InstanceIds,valueSet='{1}' --output json | jq -r '.[].[]' | yq --colors --input-format json && echo Tags: && aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Tags]' --instance-ids '{1}' --output json | jq -r '.[].[].[]' 2>/dev/null | yq --colors --input-format json" | cut -d' ' -f1)"
	if [ -z "${SELECTED_INSTANCE_ID}" ]; then
		echo "No instance selected"
		exit 1
	fi
	aws ssm start-session --target "${SELECTED_INSTANCE_ID}"
}

function main() {
	set -euo pipefail
	select_instance
}

main "${@}"
