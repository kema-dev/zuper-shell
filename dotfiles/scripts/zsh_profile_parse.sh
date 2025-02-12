#!/usr/bin/env zsh

# Actually copied from GitHub, don't remember where

function main() {
	set -euo pipefail
	typeset -a lines
	typeset -i prev_time=0
	typeset prev_command

	while read line; do
		if [[ $line =~ '^.*\+([0-9]{10})\.([0-9]{6})[0-9]* (.+)' ]]; then
			integer this_time=$match[1]$match[2]
			if [[ $prev_time -gt 0 ]]; then
				time_difference="$(( $this_time - $prev_time ))"
				lines+="$time_difference ns ### prev command = $prev_command"
			fi
			prev_time=$this_time
			local this_command=$match[3]
			if [[ ${#this_command} -le 300 ]]; then
				prev_command=$this_command
			else
				prev_command="${this_command:0:297}..."
			fi
		fi
	done < ${1:-/dev/stdin}
	print -l ${(@On)lines}
}

main "${@}"
