#!/usr/bin/env bash

function main() {
    set -euo pipefail
    local CURRENT_VERSION
    CURRENT_VERSION="$(rpm -E %fedora)"
    local NEXT_VERSION="$((CURRENT_VERSION + 1))"
    echo "Upgrading from Fedora ${CURRENT_VERSION} to Fedora ${NEXT_VERSION}"
    sudo dnf --refresh upgrade --assumeyes
    sudo dnf distro-sync
    sudo dnf autoremove --assumeyes
    sudo dnf clean all
    sudo dnf --refresh upgrade --assumeyes
    sudo dnf install dnf-plugin-system-upgrade --assumeyes
    sudo dnf system-upgrade download --releasever="${NEXT_VERSION}" --assumeyes
    sudo dnf system-upgrade reboot
}

main
