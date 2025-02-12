#!/usr/bin/env bash

function usage() {
	if [[ "${#}" -ne 0 ]]; then
		echo "Usage: ${0:-}"
		exit 1
	fi
	if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
		echo "Usage: ${0:-}"
		exit 0
	fi
}

function check_dependencies() {
	if ! command -v arm-image-installer &>/dev/null; then
		echo "arm-image-installer could not be found"
		exit 1
	fi
	if ! command -v lsblk &>/dev/null; then
		echo "lsblk could not be found"
		exit 1
	fi
}

function select_ssh_key() {
	AVAILABLE_SSH_KEYS="$(find "${KEMA_SSH_KEYS_DIR}" -type f -name "*.pub" -exec basename {} \;)"
	SSH_KEY="$(echo "${AVAILABLE_SSH_KEYS}" | fzf --prompt "SSH key to add: " --preview-label=" Fingerprint " --preview "ssh-keygen -l -f ${KEMA_SSH_KEYS_DIR}/{}" | tail -n 1)"
	SSH_KEY="$(echo "${SSH_KEY}" | tr -d '[:space:]')"
	if [[ -z "${SSH_KEY}" ]]; then
		echo "No SSH key chosen. You can generate a new one with \`ssh_key_create\`"
		exit 1
	fi
	SSH_KEY="${KEMA_SSH_KEYS_DIR}/${SSH_KEY}"
	echo -e "${COLOR_REGULAR_BLACK:-}Selected SSH key: ${COLOR_REGULAR_GREEN:-}${SSH_KEY}${COLOR_RESET:-}"
	if [[ ! -f "${SSH_KEY}" ]]; then
		echo "SSH key does not exist"
		exit 1
	fi
	echo -ne "${COLOR_REGULAR_RED:-}"
	read -p "Are you sure that you want to add ${SSH_KEY}? [y/N] " -n 1 -r
	echo
	if [[ ! "${REPLY}" =~ ^[Yy]$ ]]; then
		echo "Exiting..."
		exit 1
	fi
}

function select_device() {
	AVAILABLE_DISKS="$(lsblk | grep disk | awk '{print $1}')"
	DISK_TO_FLASH="$(echo "${AVAILABLE_DISKS}" | fzf --prompt "Block device to flash: " --preview-label=" Block device informations " --preview "lsblk -d -o NAME,MODEL,SIZE,TYPE -f /dev/{}" | tail -n 1)"
	DISK_TO_FLASH="$(echo "${DISK_TO_FLASH}" | tr -d '[:space:]')"
	if [[ -z "${DISK_TO_FLASH}" ]]; then
		echo "No disk chosen"
		exit 1
	fi
	DISK_TO_FLASH="/dev/${DISK_TO_FLASH}"
	echo -e "${COLOR_REGULAR_BLACK:-}Selected disk: ${COLOR_REGULAR_GREEN:-}${DISK_TO_FLASH}${COLOR_RESET:-}"
	if [[ ! -b "${DISK_TO_FLASH}" ]]; then
		echo "Block device does not exist"
		exit 1
	fi
	echo -ne "${COLOR_REGULAR_RED:-}"
	read -p "Are you sure that you want to flash ${DISK_TO_FLASH}? [y/N] " -n 1 -r
	echo
	if [[ ! "${REPLY}" =~ ^[Yy]$ ]]; then
		echo "Exiting..."
		exit 1
	fi
}

function select_image() {
	OS_IMAGES_DIR="${KEMA_DEV_DIR}/virtualization/images/"
	AVAILABLE_IMAGES="$(find "${OS_IMAGES_DIR}" -type f -name "*.raw.xz")"
	IMAGE_TO_FLASH="$(echo "${AVAILABLE_IMAGES}" | fzf --prompt "Image to flash: " | tail -n 1)"
	IMAGE_TO_FLASH="$(echo "${IMAGE_TO_FLASH}" | tr -d '[:space:]')"
	if [[ -z "${IMAGE_TO_FLASH}" ]]; then
		echo "No image chosen. Place a \`.raw.xz\` image in ${OS_IMAGES_DIR}"
		exit 1
	fi
	echo -e "${COLOR_REGULAR_BLACK:-}Selected image: ${COLOR_REGULAR_GREEN:-}${IMAGE_TO_FLASH}${COLOR_RESET:-}"
	if [[ ! -f "${IMAGE_TO_FLASH}" ]]; then
		echo "Image does not exist"
		exit 1
	fi
	echo -ne "${COLOR_REGULAR_RED:-}"
	read -p "Are you sure that you want to flash ${IMAGE_TO_FLASH}? [y/N] " -n 1 -r
	echo
	if [[ ! "${REPLY}" =~ ^[Yy]$ ]]; then
		echo "Exiting..."
		exit 1
	fi
}

function select_target() {
	AVAILABLE_TARGET_TYPES="rpi4"
	TARGET_TYPE="$(echo "${AVAILABLE_TARGET_TYPES}" | fzf --prompt "Target type: " | tail -n 1)"
	TARGET_TYPE="$(echo "${TARGET_TYPE}" | tr -d '[:space:]')"
	echo -e "${COLOR_REGULAR_BLACK:-}Selected target: ${COLOR_REGULAR_GREEN:-}${TARGET_TYPE}${COLOR_RESET:-}"
	echo -ne "${COLOR_REGULAR_RED:-}"
	read -p "Are you sure that you want to flash for target ${TARGET_TYPE}? [y/N] " -n 1 -r
	echo
	if [[ ! "${REPLY}" =~ ^[Yy]$ ]]; then
		echo "Exiting..."
		exit 1
	fi
}

function flash_media() {
	echo -e "${COLOR_REGULAR_BLACK:-}Flashing media...${COLOR_RESET:-}"
	sudo arm-image-installer -y --resizefs --target="${TARGET_TYPE}" --addkey="${SSH_KEY}" --media="${DISK_TO_FLASH}" --image="${IMAGE_TO_FLASH}"
	echo -e "${COLOR_REGULAR_GREEN:-}Media flash successful!${COLOR_RESET:-}"
}

function check_variables() {
	if [ -z "${KEMA_DEV_DIR:-}" ]; then
		echo -e "${COLOR_REGULAR_RED:-}KEMA_DEV_DIR not set${COLOR_RESET:-}" >&2
		exit 1
	fi
}

function main() {
	set -euo pipefail
	check_variables
	usage "${@}"
	check_dependencies
	select_ssh_key
	select_device
	select_image
	select_target
	flash_media
}

main "${@}"
