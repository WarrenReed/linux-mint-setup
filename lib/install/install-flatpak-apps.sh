#!/bin/bash

# ============================================================================
# Flatpak Application Installation
# ============================================================================
# Installs Flatpak applications from Flathub.
# Sourced by bootstrap-mint.sh
# ============================================================================

install_flatpak_app() {
    local app_id=$1
    local display_name=$2

    if flatpak list | grep -q "$app_id"; then
        print_info "$display_name is already installed."
    else
        print_info "Installing $display_name..."
        flatpak install -y flathub "$app_id"
        print_info "$display_name installed."
    fi
}

install_flatpak_apps() {
    print_section "Installing Flatpak Applications"

    install_flatpak_app "com.microsoft.AzureStorageExplorer" "Azure Storage Explorer"
    install_flatpak_app "com.slack.Slack" "Slack"

    print_info "Flatpak application installation completed."
}
