#!/usr/bin/env bash

function request_sudo() {
	echo -e "${COLOR_REGULAR_BLACK:-}Requesting sudo permissions...${COLOR_RESET:-}"
	sudo echo -e "${COLOR_REGULAR_GREEN:-}Permissions for sudo granted successfully${COLOR_RESET:-}"
}

function parse_args() {
	for arg in "${@}"; do
		requested_updates+=("${arg}")
	done
}

function proceed_with_updates() {
	if [[ ${#requested_updates[@]} -eq 0 ]]; then
		echo -e "${COLOR_REGULAR_BLACK:-}No specific update requested, updating everything...${COLOR_RESET:-}"
		requested_updates=("${available_updates[@]}")
	fi
	requested_updates=("$(printf "%s\n" "${requested_updates[@]}" | sort -u)")
	# shellcheck disable=SC2048
	for requested_update in ${requested_updates[*]}; do
		case "${requested_update}" in
		system)
			update_system_packages || {
				echo -e "${COLOR_REGULAR_YELLOW:-}System packages update failed${COLOR_RESET:-}"
				failed_updates+=("system packages")
			}
			;;
		flatpak)
			update_flatpak || {
				echo -e "${COLOR_REGULAR_YELLOW:-}Flatpak update failed${COLOR_RESET:-}"
				failed_updates+=("flatpak")
			}
			;;
		snap)
			update_snap || {
				echo -e "${COLOR_REGULAR_YELLOW:-}Snap update failed${COLOR_RESET:-}"
				failed_updates+=("snap")
			}
			;;
		gem)
			update_gem || {
				echo -e "${COLOR_REGULAR_YELLOW:-}Gem update failed${COLOR_RESET:-}"
				failed_updates+=("gem")
			}
			;;
		npm)
			update_npm || {
				echo -e "${COLOR_REGULAR_YELLOW:-}Npm update failed${COLOR_RESET:-}"
				failed_updates+=("npm")
			}
			;;
		pip)
			update_pip || {
				echo -e "${COLOR_REGULAR_YELLOW:-}Pip update failed${COLOR_RESET:-}"
				failed_updates+=("pip")
			}
			;;
		go)
			update_go || {
				echo -e "${COLOR_REGULAR_YELLOW:-}Go update failed${COLOR_RESET:-}"
				failed_updates+=("go")
			}
			;;
		cargo)
			# NOTE cargo-update is not working as of 2023-11-01
			update_cargo || {
				echo -e "${COLOR_REGULAR_YELLOW:-}Cargo update failed${COLOR_RESET:-}"
				failed_updates+=("cargo")
			}
			;;
		brew)
			update_brew || {
				echo -e "${COLOR_REGULAR_YELLOW:-}Brew update failed${COLOR_RESET:-}"
				failed_updates+=("brew")
			}
			;;
		gh)
			update_gh || {
				echo -e "${COLOR_REGULAR_YELLOW:-}Gh update failed${COLOR_RESET:-}"
				failed_updates+=("gh")
			}
			;;
		tldr)
			update_tldr || {
				echo -e "${COLOR_REGULAR_YELLOW:-}Tldr update failed${COLOR_RESET:-}"
				failed_updates+=("tldr")
			}
			;;
		git)
			update_git || {
				echo -e "${COLOR_REGULAR_YELLOW:-}Git update failed${COLOR_RESET:-}"
				# NOTE failed_updates is already populated by update_git
			}
			;;
		*)
			echo -e "${COLOR_REGULAR_YELLOW:-}Unknown update requested: ${requested_update}${COLOR_RESET:-}"
			;;
		esac
	done
	echo -e "${COLOR_REGULAR_GREEN:-}All updates completed${COLOR_RESET:-}"
}

function update_system_packages() {
	echo -e "${COLOR_REGULAR_BLACK:-}Updating system packages...${COLOR_RESET:-}"
	if type dnf >/dev/null; then
		sudo dnf upgrade --assumeyes --refresh || return 1
	fi
	echo -e "${COLOR_REGULAR_GREEN:-}System packages updated successfully${COLOR_RESET:-}"
}

function update_flatpak() {
	echo -e "${COLOR_REGULAR_BLACK:-}Updating flatpak...${COLOR_RESET:-}"
	if type flatpak >/dev/null; then
		sudo flatpak update -y || return 1
	fi
	echo -e "${COLOR_REGULAR_GREEN:-}Flatpak updated successfully${COLOR_RESET:-}"
}

function update_pip() {
	echo -e "${COLOR_REGULAR_BLACK:-}Updating pip...${COLOR_RESET:-}"
	if type pip >/dev/null; then
		if ! type pip-review >/dev/null; then
			echo -e "${COLOR_REGULAR_YELLOW:-}pip-review not found, installing...${COLOR_RESET:-}"
			pip install --upgrade pip
			pip install pip-review
			echo -e "${COLOR_REGULAR_GREEN:-}pip-review installed successfully${COLOR_RESET:-}"
		fi
		pip-review --auto || return 1
	fi
	echo -e "${COLOR_REGULAR_GREEN:-}Pip updated successfully${COLOR_RESET:-}"
}

function update_go() {
	echo -e "${COLOR_REGULAR_BLACK:-}Updating go...${COLOR_RESET:-}"
	if type go >/dev/null; then
		if ! type gup >/dev/null; then
			echo -e "${COLOR_REGULAR_YELLOW:-}gup not found, installing...${COLOR_RESET:-}"
			go install github.com/nao1215/gup@latest
			echo -e "${COLOR_REGULAR_GREEN:-}gup installed successfully${COLOR_RESET:-}"
		fi
		gup update || return 1
	fi
	echo -e "${COLOR_REGULAR_GREEN:-}Go updated successfully${COLOR_RESET:-}"
}

function update_cargo() {
	echo -e "${COLOR_REGULAR_BLACK:-}Updating cargo...${COLOR_RESET:-}"
	if type cargo >/dev/null; then
		if ! type cargo-install-update >/dev/null; then
			echo -e "${COLOR_REGULAR_YELLOW:-}cargo-install-update not found, installing...${COLOR_RESET:-}"
			cargo install cargo-update
			echo -e "${COLOR_REGULAR_GREEN:-}cargo-install-update installed successfully${COLOR_RESET:-}"
		fi
		cargo-install-update || return 1
	fi
	echo -e "${COLOR_REGULAR_GREEN:-}Cargo updated successfully${COLOR_RESET:-}"
}

function update_snap() {
	echo -e "${COLOR_REGULAR_BLACK:-}Updating snap...${COLOR_RESET:-}"
	if type snap >/dev/null; then
		sudo snap refresh || return 1
	fi
	echo -e "${COLOR_REGULAR_GREEN:-}Snap updated successfully${COLOR_RESET:-}"
}

function update_gem() {
	echo -e "${COLOR_REGULAR_BLACK:-}Updating gem...${COLOR_RESET:-}"
	if type gem >/dev/null; then
		gem update || return 1
	fi
	echo -e "${COLOR_REGULAR_GREEN:-}Gem updated successfully${COLOR_RESET:-}"
}

function update_npm() {
	echo -e "${COLOR_REGULAR_BLACK:-}Updating npm...${COLOR_RESET:-}"
	if type npm >/dev/null; then
		npm update -g || return 1
	fi
	echo -e "${COLOR_REGULAR_GREEN:-}Npm updated successfully${COLOR_RESET:-}"
}

function update_brew() {
	echo -e "${COLOR_REGULAR_BLACK:-}Updating brew...${COLOR_RESET:-}"
	if type brew >/dev/null; then
		brew update || return 1
		brew upgrade || return 1
	fi
	echo -e "${COLOR_REGULAR_GREEN:-}Brew updated successfully${COLOR_RESET:-}"
}

function update_gh() {
	echo -e "${COLOR_REGULAR_BLACK:-}Updating gh...${COLOR_RESET:-}"
	if type gh >/dev/null; then
		gh extension upgrade --all || return 1
	fi
	echo -e "${COLOR_REGULAR_GREEN:-}Gh updated successfully${COLOR_RESET:-}"
}

function update_tldr() {
	echo -e "${COLOR_REGULAR_BLACK:-}Updating tldr...${COLOR_RESET:-}"
	if type tldr >/dev/null; then
		tldr --update || return 1
	fi
	echo -e "${COLOR_REGULAR_GREEN:-}Tldr updated successfully${COLOR_RESET:-}"
}

function get_git_repos() {
	git_repos=()
	if [[ -n "${ZSH}" ]]; then
		if [[ -d "${ZSH}" ]]; then
			if [[ -d "${ZSH}/.git" ]]; then
				git_repos+=("${ZSH}")
			fi
			for plugin in "${ZSH_CUSTOM:-${ZSH}/custom}"/plugins/*; do
				if [[ -d "${plugin}" ]]; then
					if [[ -d "${plugin}/.git" ]]; then
						git_repos+=("${plugin}")
					fi
				fi
			done
		fi
	fi
	if [[ -d "${HOME}/.config/nvim" ]]; then
		if [[ -d "${HOME}/.config/nvim/.git" ]]; then
			git_repos+=("${HOME}/.config/nvim")
		fi
	fi
	if [[ -d "${HOME}/.local/share/gnome-shell/extensions/repositories" ]]; then
		for extension in "${HOME}/.local/share/gnome-shell/extensions/repositories"/*; do
			if [[ -d "${extension}" ]]; then
				if [[ -d "${extension}/.git" ]]; then
					git_repos+=("${extension}")
				fi
			fi
		done
	fi
	if [[ -n "${KEMA_DOTFILES_DIR}" ]]; then
		if [[ -d "${KEMA_DOTFILES_DIR}" ]]; then
			if [[ -d "${KEMA_DOTFILES_DIR}/.git" ]]; then
				git_repos+=("${KEMA_DOTFILES_DIR}")
			fi
		fi
	fi
	if [[ -n "${KEMA_DOTFILES_DIR_PUBLIC}" ]]; then
		if [[ -d "${KEMA_DOTFILES_DIR_PUBLIC}" ]]; then
			if [[ -d "${KEMA_DOTFILES_DIR_PUBLIC}/.git" ]]; then
				git_repos+=("${KEMA_DOTFILES_DIR_PUBLIC}")
			fi
		fi
	fi
}

function update_git() {
	echo -e "${COLOR_REGULAR_BLACK:-}Updating git...${COLOR_RESET:-}"
	get_git_repos
	local git_repo_failed=()
	if type git >/dev/null; then
		for repo in "${git_repos[@]}"; do
			echo -e "${COLOR_REGULAR_BLACK:-}Updating git repo located at ${COLOR_REGULAR_BLUE:-}${repo}${COLOR_REGULAR_BLACK:-}...${COLOR_RESET:-}"
			git -C "${repo}" pull || {
				git_repo_failed+=("$(basename "${repo}")")
				echo -e "${COLOR_REGULAR_YELLOW:-}Git repo located at ${COLOR_REGULAR_BLUE:-}${repo}${COLOR_REGULAR_YELLOW:-} failed to update${COLOR_RESET:-}"
			}
		done
	fi
	if [[ ${#git_repo_failed[@]} -gt 0 ]]; then
		echo -e "${COLOR_REGULAR_YELLOW:-}The following git repos failed to update:${COLOR_RESET:-}"
		for failed_repo in "${git_repo_failed[@]}"; do
			echo -e "${COLOR_REGULAR_YELLOW:-} - ${COLOR_REGULAR_RED:-}${failed_repo}${COLOR_RESET:-}"
			failed_updates+=("git - ${failed_repo}")
		done
		return 1
	else
		echo -e "${COLOR_REGULAR_GREEN:-}Git repos updated successfully${COLOR_RESET:-}"
	fi
}

function print_failed_updates() {
	if [[ ${#failed_updates[@]} -gt 0 ]]; then
		echo -e "${COLOR_REGULAR_YELLOW:-}The following updates failed:${COLOR_RESET:-}"
		for failed_update in "${failed_updates[@]}"; do
			echo -e "${COLOR_REGULAR_YELLOW:-} - ${failed_update}${COLOR_RESET:-}"
		done
	fi
}

function check_variables() {
	if [ -z "${KEMA_DOTFILES_DIR:-}" ]; then
		echo -e "${COLOR_REGULAR_RED:-}KEMA_DOTFILES_DIR not set${COLOR_RESET:-}" >&2
		exit 1
	fi
	if [ -z "${KEMA_DOTFILES_DIR_PUBLIC:-}" ]; then
		echo -e "${COLOR_REGULAR_RED:-}KEMA_DOTFILES_DIR_PUBLIC not set${COLOR_RESET:-}" >&2
		exit 1
	fi
}

function main() {
	set -euo pipefail
	check_variables
	failed_updates=()
	# NOTE npm and cargo disabled as not used
	# available_updates=("system" "flatpak" "snap" "gem" "npm" "pip" "go" "cargo" "brew" "gh" "tldr" "git")
	available_updates=("system" "flatpak" "snap" "gem" "pip" "go" "brew" "gh" "tldr" "git")
	requested_updates=()
	request_sudo
	parse_args "${@}"
	proceed_with_updates
	print_failed_updates
}

main "${@}"
