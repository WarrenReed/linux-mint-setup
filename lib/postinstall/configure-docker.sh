#!/bin/bash

# ============================================================================
# Docker Configuration
# ============================================================================
# Configures Docker by adding user to docker group.
# Sourced by bootstrap-mint.sh
# ============================================================================

configure_docker() {
    print_section "Configuring Docker"
    
    if groups $USER | grep -q '\bdocker\b'; then
        print_info "User is already in docker group."
    else
        print_info "Adding current user to docker group..."
        sudo usermod -aG docker $USER
        print_info "You'll need to reboot for docker group membership to take effect."
    fi
}
