#!/bin/bash

# ============================================================================
# APT Package Uninstallation
# ============================================================================
# Removes unwanted pre-installed APT packages from Linux Mint.
# Sourced by bootstrap-mint.sh
# ============================================================================

uninstall_firefox() {
    # Check if any Firefox packages are installed (simple check for firefox or firefox-locale packages)
    if dpkg-query -s firefox &> /dev/null || dpkg-query -s firefox-locale-en &> /dev/null; then
        print_info "Removing Firefox and all related packages..."
        # Remove all Firefox packages (main, locales, ESR, etc.)
        sudo apt purge -y 'firefox*'
        sudo apt autoremove -y
        print_info "Firefox removed successfully."
    else
        print_info "No Firefox packages found, skipping."
    fi
}

uninstall_apt_packages() {
    print_section "Uninstalling APT Packages"

    uninstall_firefox
}
