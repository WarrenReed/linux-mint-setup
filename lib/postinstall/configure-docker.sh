#!/bin/bash

# ============================================================================
# Docker Configuration
# ============================================================================
# Configures Docker by adding user to docker group.
# Sourced by bootstrap-mint.sh
# ============================================================================

add_user_to_docker_group() {
    if groups $USER | grep -q '\bdocker\b'; then
        print_info "User is already in docker group."
    else
        print_info "Adding current user to docker group..."
        sudo usermod -aG docker $USER
        print_info "User added to docker group."
        print_info "You'll need to reboot for docker group membership to take effect."
    fi
}

configure_docker() {
    print_section "Configuring Docker"

    add_user_to_docker_group

    print_info "Docker configuration completed."
}
