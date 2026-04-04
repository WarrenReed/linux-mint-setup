#!/bin/bash

# ============================================================================
# Prerequisites
# ============================================================================
# Checks prerequisites and installs required utilities.
# Sourced by setup-linux-mint.sh
# ============================================================================

check_prerequisites() {
    print_section "Checking Prerequisites"

    # Check if running with sudo privileges
    if [[ "$EUID" -eq 0 ]]; then
        print_error "Please do not run this script as root. It will request sudo when needed."
        exit 1
    fi

    # Check if repositories.json exists
    if [[ ! -f "${SCRIPT_DIR}/config/repositories.json" ]]; then
        print_error "config/repositories.json not found"
        exit 1
    fi

    print_info "All prerequisites satisfied"
}

install_required_utilities() {
    print_section "Installing Required Utilities"
    sudo apt update
    sudo apt install -y curl gettext-base jq
    print_info "Required utilities installed."
}
