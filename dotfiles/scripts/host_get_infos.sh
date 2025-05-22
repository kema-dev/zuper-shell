#!/usr/bin/env bash

function main() {
	set -euo pipefail
	local no_scan=false
	if [[ "${1:-}" == "--no-scan" ]]; then
		shift
		no_scan=true
	fi
	local host="${1:-}"
	if [[ -z "${host}" ]]; then
		echo "No host specified"
		return 1
	fi
	local blue="\033[0;34m"
	local reset="\033[0m"
	echo -e "${blue}Testing reachability of ${host}${reset}"
	echo -e "${blue}host ${host}${reset}"
	host "${host}" || true
	echo -e "${blue}nslookup ${host}${reset}"
	nslookup "${host}" || true
	echo -e "${blue}dog ${host}${reset}"
	doggo "${host}" || true
	echo -e "${blue}traceroute -m 15 ${host}${reset}"
	traceroute -m 15 "${host}" || true
	echo -e "${blue}ping -c 5 ${host}${reset}"
	ping -c 5 -W 5 "${host}" || true
	if [[ "${no_scan}" == "true" ]]; then
		return 0
	fi
	echo -e "${blue}nmap -T5 -sC -sV -Pn --max-retries 3 --host-timeout 15s -p 20,21,22,23,25,53,80,110,143,389,443,465,587,3306,5432,8080,8081,8443,27017 ${host}${reset}"
	nmap -T5 -sC -sV -Pn --max-retries 3 --host-timeout 15s -p 20,21,22,23,25,53,80,110,143,389,443,465,587,3306,5432,8080,8081,8443,27017,51820 "${host}"
}

main "${@}"
