#!/usr/bin/env bash

function main() {
	set -euo pipefail
	local no_scan=false
	local v6=""
	while [[ "${1:-}" == "--no-scan" || "${1:-}" == "-6" ]]; do
		if [[ "${1:-}" == "-6" ]]; then
			v6="-6"
		else
			no_scan=true
		fi
		shift
	done
	local host="${1:-}"
	if [[ -z "${host}" ]]; then
		echo "No host specified"
		return 1
	fi
	local blue="\033[0;34m"
	local reset="\033[0m"
	echo -e "${blue}Testing reachability of ${host}${reset}"
	echo -e "${blue}host ${v6} ${host}${reset}"
	host "${v6}" "${host}" || true
	echo -e "${blue}nslookup ${host}${reset}"
	nslookup "${host}" || true
	echo -e "${blue}dog ${v6} ${host}${reset}"
	doggo "${v6}" "${host}" || true
	echo -e "${blue}traceroute ${v6} -m 15 ${host}${reset}"
	traceroute "${v6}" -m 15 "${host}" || true
	echo -e "${blue}ping ${v6} -c 5 ${host}${reset}"
	ping "${v6}" -c 5 -W 5 "${host}" || true
	if [[ "${no_scan}" == "true" ]]; then
		return 0
	fi
	echo -e "${blue}nmap ${v6} -T5 -sC -sV -Pn --max-retries 3 --host-timeout 15s -p 20,21,22,23,25,53,80,110,143,389,443,465,587,3306,5432,8080,8081,8443,27017 ${host}${reset}"
	nmap "${v6}" -T5 -sC -sV -Pn --max-retries 3 --host-timeout 15s -p 20,21,22,23,25,53,80,110,143,389,443,465,587,3306,5432,8080,8081,8443,27017,51820 "${host}"
}

main "${@}"
