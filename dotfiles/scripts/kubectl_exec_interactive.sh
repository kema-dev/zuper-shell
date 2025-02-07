#!/usr/bin/env bash

function select_namespace() {
	NAMESPACE="$(kubectl get namespaces --no-headers | awk '{print $1}' | fzf --prompt "Namespace: " --preview-label=" Namespace pods " --preview-window nowrap --preview 'kubecolor --force-colors get pods --namespace {}')"
}

function select_pod() {
	POD="$(kubectl get pods --namespace "${NAMESPACE}" --no-headers | awk '{print $1}' | fzf --prompt "Pod: " --preview-label=" Pod logs & description " --preview-window nowrap --preview "kubecolor --force-colors logs --namespace ${NAMESPACE} {} | tail -n 5 && echo && kubecolor --force-colors describe pod --namespace ${NAMESPACE} {}")"
}

function select_container() {
	CONTAINER="$(kubectl get pods --namespace "${NAMESPACE}" "${POD}" -o jsonpath='{.spec.containers[*].name}' | tr ' ' '\n' | fzf --prompt "Container: " --preview-label=" Container logs " --preview-window nowrap --preview "kubecolor --force-colors logs --namespace ${NAMESPACE} ${POD} -c {} | tail -n 5")"
}

function exec_into_pod() {
	kubectl exec --namespace "${NAMESPACE}" -it "${POD}" -c "${CONTAINER}" -- bash || kubectl exec --namespace "${NAMESPACE}" -it "${POD}" -c "${CONTAINER}" -- sh
}

function main() {
	set -euo pipefail
	select_namespace
	select_pod
	select_container
	exec_into_pod
}

main
