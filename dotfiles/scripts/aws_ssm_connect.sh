#!/usr/bin/env bash

function select_instance() {
	local AVAILABLE_INSTANCES_JSON
	AVAILABLE_INSTANCES_JSON="$(aws ssm describe-instance-information --query "InstanceInformationList[?PingStatus=='Online']" --output json)"
	local SELECTED_INSTANCE_ID
	# TODO Add tags preview for other resources (ecs, ...) not only ec2
	SELECTED_INSTANCE_ID="$(echo "${AVAILABLE_INSTANCES_JSON}" | jq -r '.[].InstanceId' | fzf --prompt "Instance to connect to: " --preview-label=" Instance informations " --preview "echo SSM description: &&	aws ssm describe-instance-information --instance-information-filter-list key=InstanceIds,valueSet='{}' --output yaml | yq --colors -r '.[].[]' && echo Tags: && aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Tags]' --instance-ids {} --output yaml | yq --colors -r '.[].[].[]' 2>/dev/null")"
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
