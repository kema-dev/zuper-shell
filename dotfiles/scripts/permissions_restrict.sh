#!/usr/bin/env bash

function ask_for_confirmation() {
	read -p "Are you sure that you want to change the permissions of all files and directories in the current directory? [y/n] " -n 1 -r
	echo
	if [[ ! "${REPLY}" =~ ^[Yy]$ ]]; then
		echo "Exiting..."
		exit 1
	fi
	read -p "Really sure? [y/n] " -n 1 -r
	echo
	if [[ ! "${REPLY}" =~ ^[Yy]$ ]]; then
		echo "Exiting..."
		exit 1
	fi
}

function change_files_permissions() {
	find . -depth -type f -exec chmod 600 {} \;
	find . -depth -type f -name "*.sh" -exec chmod 700 {} \;
}

function change_directories_permissions() {
	find . -depth -type d -exec chmod 700 {} \;
}

function main() {
	set -euo pipefail
	ask_for_confirmation
	change_files_permissions
	change_directories_permissions
}

main
