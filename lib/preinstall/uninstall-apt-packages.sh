#!/bin/bash

# ============================================================================
# APT Package Uninstallation
# ============================================================================
# Removes unwanted pre-installed APT packages from Linux Mint.
# Sourced by bootstrap-mint.sh
# ============================================================================

uninstall_apt_packages() {
    print_section "Uninstalling APT Packages"
    
    # Check if Firefox is installed
    if dpkg-query -s firefox &> /dev/null; then
        print_info "Removing Firefox..."
        sudo apt purge -y firefox
        sudo apt autoremove -y
        print_info "Firefox removed successfully"
    else
        print_info "Firefox is not installed, skipping"
    fi
}
