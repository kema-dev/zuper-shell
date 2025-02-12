#!/usr/bin/env bash

function set_multi_region_arg() {
	export -a REGIONS=()
	if [[ "${#}" -gt 0 ]]; then
		for region in "${@}"; do
			REGIONS+=("${region}")
		done
	fi
	if [[ "${#REGIONS[@]}" -eq 0 ]]; then
		local configured_region
		configured_region="$(aws configure get region || true)"
		if [[ -n "${configured_region}" ]]; then
			REGIONS+=("${configured_region}")
		else
			REGIONS+=("${AWS_DEFAULT_REGION}")
		fi
	fi
}

function discover_aws_eks_clusters() {
	export -a CLUSTERS=()
	export -a CLUSTERS_REGIONS=()
	for region in "${REGIONS[@]}"; do
		for cluster in $(aws eks list-clusters --region "${region}" --output json | jq -r '.clusters[]'); do
			CLUSTERS+=("${cluster}")
			CLUSTERS_REGIONS+=("${region}")
		done
	done
}

function select_cluster_and_update_kube_context() {
	if [[ "${#CLUSTERS[@]}" -eq 0 ]]; then
		echo "No EKS clusters found in regions: ${REGIONS[*]}"
		exit 1
	fi
	if [[ "${#CLUSTERS[@]}" -eq 1 ]]; then
		aws eks update-kubeconfig --name "${CLUSTERS[0]}" --region "${CLUSTERS_REGIONS[0]}"
		exit 0
	fi
	local CLUSTERS_AND_REGIONS_ARRAY=()
	for i in "${!CLUSTERS[@]}"; do
		CLUSTERS_AND_REGIONS_ARRAY+=("${CLUSTERS[i]} ${CLUSTERS_REGIONS[i]}_")
	done
	local CLUSTERS_AND_REGIONS_FORMATTED
	CLUSTERS_AND_REGIONS_FORMATTED="$(echo "${CLUSTERS_AND_REGIONS_ARRAY[*]}" | tr '_' '\n' | column -t)"
	local SELECTED_CLUSTER
	SELECTED_CLUSTER="$(echo "${CLUSTERS_AND_REGIONS_FORMATTED}" | tr '_' '\n' | fzf --prompt "Cluster to set kube context to: " --preview-label=" Cluster informations " --preview "aws eks describe-cluster --name {1} --region {2} --output json | jq -r '.cluster' | yq --colors --input-format json || echo error")"
	if [ -z "${SELECTED_CLUSTER}" ]; then
		echo "No cluster selected"
		exit 1
	fi
	SELECTED_CLUSTER="$(echo "${SELECTED_CLUSTER}" | tr --squeeze-repeats ' ')"
	local SELECTED_CLUSTER_NAME
	SELECTED_CLUSTER_NAME="$(echo "${SELECTED_CLUSTER}" | cut -d' ' -f1)"
	local SELECTED_CLUSTER_REGION
	SELECTED_CLUSTER_REGION="$(echo "${SELECTED_CLUSTER}" | cut -d' ' -f2)"
	aws eks update-kubeconfig --name "${SELECTED_CLUSTER_NAME}" --region "${SELECTED_CLUSTER_REGION}"
	echo -e "${COLOR_REGULAR_BLACK:-}Kube context set to ${COLOR_REGULAR_GREEN:-}${SELECTED_CLUSTER_NAME}${COLOR_REGULAR_BLACK:-} in ${COLOR_REGULAR_GREEN:-}${SELECTED_CLUSTER_REGION}${COLOR_RESET:-}"
}

function main() {
	set -euo pipefail
	set_multi_region_arg "${@}"
	discover_aws_eks_clusters
	select_cluster_and_update_kube_context
}

main "${@}"
