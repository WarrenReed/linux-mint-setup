#!/bin/bash

# ============================================================================
# Virtualization Configuration
# ============================================================================
# Configures KVM/libvirt by adding user to required groups.
# Sourced by bootstrap-mint.sh
# ============================================================================

add_user_to_virtualization_groups() {
    local groups_added=false

    if groups $USER | grep -q '\blibvirt\b'; then
        print_info "User is already in libvirt group."
    else
        print_info "Adding current user to libvirt group..."
        sudo usermod -aG libvirt $USER
        groups_added=true
    fi

    if groups $USER | grep -q '\bkvm\b'; then
        print_info "User is already in kvm group."
    else
        print_info "Adding current user to kvm group..."
        sudo usermod -aG kvm $USER
        groups_added=true
    fi

    if [[ "$groups_added" == true ]]; then
        print_info "You'll need to reboot for virtualization group membership to take effect."
    fi
}

configure_virtualization() {
    print_section "Configuring Virtualization"

    add_user_to_virtualization_groups
}
