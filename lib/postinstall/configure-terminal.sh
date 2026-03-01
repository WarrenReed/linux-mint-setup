#!/bin/bash

# ============================================================================
# GNOME Terminal Configuration
# ============================================================================
# Configures GNOME Terminal to use Meslo Nerd Font.
# Sourced by bootstrap-mint.sh
# ============================================================================

configure_terminal() {
    print_section "Configuring GNOME Terminal"

    # Check if GNOME Terminal is available
    if ! command -v gnome-terminal &> /dev/null; then
        print_info "GNOME Terminal not found. Skipping terminal configuration."
        return
    fi

    # Check if gsettings schema exists (pipefail-safe)
    local schemas=$(gsettings list-schemas 2>/dev/null || true)
    if ! echo "$schemas" | grep -q "org.gnome.Terminal.ProfilesList"; then
        print_info "GNOME Terminal gsettings schema not found. Skipping terminal configuration."
        return
    fi

    print_info "Setting Meslo Nerd Font for GNOME Terminal..."
    PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ use-system-font false
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ font 'MesloLGM Nerd Font 10'
    print_info "GNOME Terminal is now configured to use Meslo Nerd Font."
}
