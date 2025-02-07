#!/usr/bin/env bash

function main() {
	set -euo pipefail
  if [[ -z "${1:-}" ]]; then
    echo "Usage: date_from_timestamp <timestamp>"
    return 1
  fi
  local LC_TIME="en_US.UTF-8"
  local TIME_FORMAT="%A %Y %m %d - %H:%M:%S"
  local UTC_DATE
  UTC_DATE="$(date -u -d "@${1:-}" +"${TIME_FORMAT}")"
  local LOCAL_DATE
  LOCAL_DATE="$(date -d "@${1:-}" +"${TIME_FORMAT}")"
  echo "${LOCAL_DATE} (UTC: ${UTC_DATE})"
}

main "${@}"
