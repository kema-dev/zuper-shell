#!/usr/bin/env bash

# Derived from https://stackoverflow.com/questions/40447295/how-to-configure-kubectl-with-cluster-information-from-a-conf-file
# Merge multiple kubernetes config files into ~/.kube/config, and backup the original file
function main() {
	set -euo pipefail
	local kubeconfig_dir="${HOME}/.kube"
	# check if there is at least one argument
	if [[ "$#" -lt 1 ]]; then
		echo -e "${COLOR_REGULAR_RED:-}ERROR! No arguments provided${COLOR_RESET:-}"
		echo -e "${COLOR_REGULAR_RED:-}Usage: kubernetes_config_merge.sh <config 1> (<config 2> <config 3> ...)${COLOR_RESET:-}"
		return 1
	fi
	# Get all config files as a PATH string
	local configs_to_merge=""
	for config in "${@}"; do
		configs_to_merge+="${config}:"
	done
	configs_to_merge="${configs_to_merge%:}"
	if [[ -z "${KUBECONFIG}" ]]; then
		KUBECONFIG="${configs_to_merge}"
	else
		KUBECONFIG+=":${configs_to_merge}"
	fi
	if [[ -f "${kubeconfig_dir}/config" ]]; then
		KUBECONFIG+=":${kubeconfig_dir}/config"
	fi
	export KUBECONFIG
	# Backup original file
	if [[ -f "${kubeconfig_dir}/config" ]]; then
		local backup_file
		backup_file="${kubeconfig_dir}/config.backup.$(date +%Y_%m_%d_%H_%M_%S)"
		echo -e "${COLOR_REGULAR_BLACK:-}Backing up ${kubeconfig_dir}/config to ${backup_file}${COLOR_RESET:-}"
		cp "${kubeconfig_dir}/config" "${backup_file}"
		chmod 600 "${backup_file}"
	else
		echo -e "${COLOR_REGULAR_BLACK:-}${kubeconfig_dir}/config does not exist, and will be created${COLOR_RESET:-}"
	fi
	# Merge all files into a single file
	echo -e "${COLOR_REGULAR_BLACK:-}Merging ${KUBECONFIG} into ${kubeconfig_dir}/config${COLOR_RESET:-}"
	kubectl config view --merge --flatten >"${kubeconfig_dir}/config.merged"
	# Replace original file and set appropriate permissions
	if [[ -f "${kubeconfig_dir}/config" ]]; then
		rm "${kubeconfig_dir}/config"
	fi
	mv "${kubeconfig_dir}/config.merged" "${kubeconfig_dir}/config"
	chmod 600 "${kubeconfig_dir}/config"
	echo -e "${COLOR_REGULAR_GREEN:-}SUCCESS! Merged ${KUBECONFIG} into ${kubeconfig_dir}/config${COLOR_RESET:-}"
	unset KUBECONFIG
}

main "${@}"
