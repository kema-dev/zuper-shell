#!/usr/bin/env bash

# IMPROVE lower the number of env vars needed to run this script in system-wide shortcut (= when .zshrc is not sourced)

export COLOR_REGULAR_BLACK='\033[0;30m'
export COLOR_REGULAR_GREEN='\033[0;32m'
export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/home/linuxbrew/.linuxbrew/opt/go/libexec/bin:${HOME}/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:${GOPATH}/bin:${HOME}/.cargo/bin:${HOME}/.npm-global/bin:${HOME}/.pub-cache/bin:${NVM_DIR}/bin:${GEM_HOME}/bin:${HOME}/.krew/bin:/var/lib/snapd/snap/bin"
# Global options
export FZF_DEFAULT_OPTS="
--exit-0
--select-1
--extended
--tiebreak=begin,length
--ansi
--layout=reverse
--cycle
--multi
--walker=file,dir,follow,hidden
-i
--info=inline-right
--header-first
--no-scrollbar
--height=100%
--preview-window=':default:wrap:right:60%'
--bind 'ctrl-r:toggle-sort'
--bind 'change:top'
--bind 'ctrl-\:toggle-preview'
--bind 'alt-\:toggle-preview-wrap'
--bind 'alt-enter:transform:echo print-query'
--bind 'ctrl-space:toggle'
--header 'ctrl-r : toggle sort | ctrl-\ : toggle preview | alt-\ toggle wrap | alt-enter : print query | ctrl-space : select'
--color=border:#808080,spinner:#E6DB74,hl:#F7EF54,fg:#F8F8F2,header:#b7815d,info:#A6E22E,pointer:#A6E22E,marker:#F92672,fg+:#F8F8F2,prompt:#F92672,hl+:#F92672
"
# Custom options specific to this script
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --bind 'ctrl-b:execute(rm {1})+abort+execute(${0})' --header 'ctrl-r : toggle sort | ctrl-\ : toggle preview | alt-\ toggle wrap | ctrl-b delete entry | alt-enter : print query | ctrl-space : select'"
export KEMA_CLIPBOARD_MANAGER_DIR="${HOME}/.kema_clipboard_manager"
export KEMA_SCRIPTS_DIR="${HOME}/.dotfiles/dotfiles/scripts"
export KEMA_SCRIPTS_DIR_PUBLIC="${HOME}/dev/git/github.com/kema-dev/zuper-shell/dotfiles/scripts"

function main() {
	set -euo pipefail
	if [[ -z "${KEMA_CLIPBOARD_MANAGER_DIR:-}" ]]; then
		echo "KEMA_CLIPBOARD_MANAGER_DIR is not set"
		exit 1
	fi
	cd "${KEMA_CLIPBOARD_MANAGER_DIR}"
	local desired_file
	# avoid failing on early exit of fzf
	desired_file="$("${KEMA_SCRIPTS_DIR_PUBLIC}/find_fzf.sh" -f)" || true
	if [[ -z "${desired_file}" ]]; then
		exit 1
	elif [[ -f "${desired_file}" ]]; then
		xsel --input --clipboard <"${desired_file}"
	else
		echo "${desired_file}" | tr -d '\n' | xsel --input --clipboard
	fi
}

main
