#!/usr/bin/env bash

function parse_arguments() {
	while [[ "${#}" -gt 0 ]]; do
		case "${1:-}" in
		--skip-service)
			SKIP_SERVICE="true"
			shift
			;;
		--cluster)
			if [[ -z "${2:-}" ]]; then
				echo "No cluster specified, exiting..."
				exit 1
			fi
			SELECTED_CLUSTER="${2}"
			shift 2
			;;
		--service)
			if [[ -z "${2:-}" ]]; then
				echo "No service specified, exiting..."
				exit 1
			fi
			SELECTED_SERVICE="${2}"
			shift 2
			;;
		--task)
			if [[ -z "${2:-}" ]]; then
				echo "No task specified, exiting..."
				exit 1
			fi
			SELECTED_TASK="${2}"
			shift 2
			;;
		--container)
			if [[ -z "${2:-}" ]]; then
				echo "No container specified, exiting..."
				exit 1
			fi
			SELECTED_CONTAINER="${2}"
			shift 2
			;;
		*)
			COMMAND="${*}"
			shift
			;;
		esac
	done
	if [[ -z "${COMMAND:-}" ]]; then
		echo -e "${COLOR_REGULAR_YELLOW:-}No command selected, defaulting to sh${COLOR_RESET:-}"
		COMMAND="sh"
	fi
}

function select_cluster() {
	local CLUSTERS
	CLUSTERS="$(aws ecs list-clusters --output json --query clusterArns)"
	SELECTED_CLUSTER="$(echo "${CLUSTERS}" | jq -r '.[]' | fzf \
		--prompt "Cluster to search tasks in: " \
		--delimiter ':cluster/' \
		--with-nth 2 \
		--preview-label=" Cluster description " \
		--preview "aws ecs describe-clusters --clusters {} --output yaml | yq --colors -r '.clusters[] | {
		\"ARN\": .clusterArn,
		\"Status\": .status,
		\"Active Services\": .activeServicesCount,
		\"Running tasks\": .runningTasksCount,
		\"Pending tasks\": .pendingTasksCount,
		\"Registered tasks\": .registeredTasksCount,
		\"Registered container instances\": .registeredContainerInstancesCount,
		\"Tags\": .tags,
		\"Statistics\": .statistics,
		\"Capacity providers\": .capacityProviders,
		\"Settings\": .settings
	}'")"
	if [[ -z "${SELECTED_CLUSTER}" ]]; then
		echo "No cluster selected, exiting..."
		exit 1
	fi
}

function select_service() {
	local SERVICES
	SERVICES="$(aws ecs list-services --cluster "${SELECTED_CLUSTER}" --output json --query serviceArns)"
	SELECTED_SERVICE="$(echo "${SERVICES}" | jq -r '.[]' | fzf \
		--prompt "Service to search tasks in: " \
		--delimiter ":service/${SLECTED_CLUSTER_NAME}/" \
		--with-nth 2 \
		--preview-label=" Service description " \
		--preview "aws ecs describe-services --cluster ${SELECTED_CLUSTER} --services {} --output yaml | yq --colors -r '
	.services[] | {
		\"ARN\": .serviceArn,
		\"Status\": .status,
		\"Desired count\": .desiredCount,
		\"Running count\": .runningCount,
		\"Pending count\": .pendingCount,
		\"Created at\": .createdAt,
		\"Created by\": .createdBy,
		\"Task definition\": .taskDefinition,
		\"Deployments\": .deployments[] | {
			\"Status\": .status,
			\"Desired count\": .desiredCount,
			\"Running count\": .runningCount,
			\"Pending count\": .pendingCount,
			\"Failed tasks\": .failedTasks,
			\"Created at\": .createdAt,
			\"Updated at\": .updatedAt,
			\"Rollout state\": .rolloutState,
			\"Rollout state reason\": .rolloutStateReason
		},
		\"Scheduling strategy\": .schedulingStrategy,
		\"Role ARN\": .roleArn,
		\"Launch type\": .launchType,
		\"Capacity provider strategy\": .capacityProviderStrategy,
		\"Platform family\": .platformFamily,
		\"Platform version\": .platformVersion,
		\"Placement constraints\": .placementConstraints,
		\"Placement strategy\": .placementStrategy,
		\"Network configuration\": .networkConfiguration,
		\"Load balancers\": .loadBalancers,
		\"Deployment configuration\": .deploymentConfiguration,
		\"Deployment controller\": .deploymentController
	}'")"
	if [[ -z "${SELECTED_SERVICE}" ]]; then
		echo "No service selected, exiting..."
		exit 1
	fi
}

function select_task() {
	local TASKS
	# shellcheck disable=SC2086
	TASKS="$(aws ecs list-tasks --cluster "${SELECTED_CLUSTER}" ${SELECT_SERVICE_ARGS:-} --output json --query taskArns)"
	SELECTED_TASK="$(echo "${TASKS}" | jq -r '.[]' | fzf \
		--prompt "Task to execute command in: " \
		--delimiter ":task/${SLECTED_CLUSTER_NAME}/" \
		--with-nth 2 \
		--preview-label=" Task description " \
		--preview "echo 'Task:' && aws ecs describe-tasks --cluster ${SELECTED_CLUSTER} --tasks {} --output yaml | yq --colors -r '
	.tasks[] | {
		\"ARN\": .taskArn,
		\"Health status\": .healthStatus,
		\"Last status\": .lastStatus,
		\"Desired status\": .desiredStatus,
		\"Version\": .version,
		\"Created at\": .createdAt,
		\"Started at\": .startedAt,
		\"Started by\": .startedBy,
		\"CPU\": .cpu,
		\"Memory\": .memory,
		\"Availability zone\": .availabilityZone,
		\"Launch type\": .launchType,
		\"Overrides\": .overrides,
		\"Tags\": .tags,
		\"Connectivity\": .connectivity,
		\"Connectivity at\": .connectivityAt,
		\"Pull started at\": .pullStartedAt,
		\"Pull stopped at\": .pullStoppedAt
	}' && echo 'Task definition:' && TASK_DEFINITION_ARN=\"\$(aws ecs describe-tasks --cluster ${SELECTED_CLUSTER} --tasks {} --output json | jq -r '.tasks[].taskDefinitionArn')\" && aws ecs describe-task-definition --task-definition \"\${TASK_DEFINITION_ARN}\" --output yaml | yq --colors -r '.taskDefinition | {
		\"ARN\": .taskDefinitionArn,
		\"Family\": .family,
		\"Revision\": .revision,
		\"Task execution role\": .executionRoleArn,
		\"Status\": .status,
		\"Network mode\": .networkMode,
		\"Container definitions\": .containerDefinitions,
		\"Volumes\": .volumes,
		\"CPU\": .cpu,
		\"Memory\": .memory,
		\"Task role ARN\": .taskRoleArn,
		\"Tags\": .tags
	}' && echo 'Log tail:' \
		&& TASK_DEFINITION_ARN=\"\$(aws ecs describe-tasks --cluster ${SELECTED_CLUSTER} --tasks {} --output json | jq -r '.tasks[].taskDefinitionArn')\" \
		&& LOG_GROUP=\"\$(aws ecs describe-task-definition --task-definition \${TASK_DEFINITION_ARN} --output json | jq -r '.taskDefinition.containerDefinitions[0] | .logConfiguration.options.[\"awslogs-group\"]')\" \
		&& aws logs tail --color on \"\${LOG_GROUP}\"
	")"
	if [[ -z "${SELECTED_TASK}" ]]; then
		echo "No task selected, exiting..."
		exit 1
	fi
}

function select_container() {
	local CONTAINERS
	CONTAINERS="$(aws ecs describe-tasks --cluster "${SELECTED_CLUSTER}" --tasks "${SELECTED_TASK}" --output json --query 'tasks[].containers[].name')"
	SELECTED_CONTAINER="$(echo "${CONTAINERS}" | jq -r '.[]' | fzf \
		--prompt "Container to execute command in: " \
		--preview-label=" Container description " \
		--preview "echo 'Container:' &&
		aws ecs describe-tasks --cluster ${SELECTED_CLUSTER} --tasks ${SELECTED_TASK} --output yaml | yq --colors -r '.tasks[].containers[] | select(.name == \"{}\") | {
		\"Name\": .name,
		\"Last status\": .lastStatus,
		\"Health status\": .healthStatus,
		\"Image\": .image,
		\"CPU\": .cpu,
		\"Memory\": .memory
	}' && echo 'Log tail:' \
		&& TASK_DEFINITION_ARN=\"\$(aws ecs describe-tasks --cluster ${SELECTED_CLUSTER} --tasks ${SELECTED_TASK} --output json | jq -r '.tasks[].taskDefinitionArn')\" \
		&& LOG_GROUP=\"\$(aws ecs describe-task-definition --task-definition \${TASK_DEFINITION_ARN} --output json | jq -r '.taskDefinition.containerDefinitions[] | select(.name == \"{}\") | .logConfiguration.options.[\"awslogs-group\"]')\" \
		&& LOG_STREAM_PREFIX=\"\$(aws ecs describe-task-definition --task-definition \${TASK_DEFINITION_ARN} --output json | jq -r '.taskDefinition.containerDefinitions[] | select(.name == \"{}\") | .logConfiguration.options.[\"awslogs-stream-prefix\"]')\" \
		&& aws logs tail --color on \"\${LOG_GROUP}\" --log-stream-name-prefix \"\${LOG_STREAM_PREFIX}\"
	")"
	if [[ -z "${SELECTED_CONTAINER}" ]]; then
		echo "No container selected, exiting..."
		exit 1
	fi
}

function execute_command() {
	aws ecs execute-command --cluster "${SELECTED_CLUSTER}" --task "${SELECTED_TASK}" --container "${SELECTED_CONTAINER}" --interactive --command "${COMMAND}"
}

function main() {
	set -euo pipefail
	parse_arguments "${@}"
	if [[ -z "${SELECTED_CLUSTER:-}" ]]; then
		select_cluster
	fi
	SLECTED_CLUSTER_NAME="$(echo "${SELECTED_CLUSTER}" | cut -d'/' -f2)"
	if [[ -z "${SKIP_SERVICE:-}" && -z "${SELECTED_TASK:-}" ]]; then
		if [[ -z "${SELECTED_SERVICE:-}" ]]; then
			select_service
			SELECT_SERVICE_ARGS="--service-name ${SELECTED_SERVICE}"
		fi
	fi
	if [[ -z "${SELECTED_TASK:-}" ]]; then
		select_task
	fi
	if [[ -z "${SELECTED_CONTAINER:-}" ]]; then
		select_container
	fi
	execute_command
}

main "${@}"
