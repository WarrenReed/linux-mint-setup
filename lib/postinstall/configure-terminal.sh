#!/bin/bash

# ============================================================================
# GNOME Terminal Configuration
# ============================================================================
# Configures GNOME Terminal to use Meslo Nerd Font.
# Sourced by bootstrap-mint.sh
# ============================================================================

set_terminal_font() {
    PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
    local current_font=$(gsettings get org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ font)

    if [[ "$current_font" == "'MesloLGM Nerd Font 10'" ]]; then
        print_info "Meslo Nerd Font already set for GNOME Terminal."
    else
        print_info "Setting Meslo Nerd Font for GNOME Terminal..."
        gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ use-system-font false
        gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ font 'MesloLGM Nerd Font 10'
        print_info "Meslo Nerd Font set for GNOME Terminal."
    fi
}

configure_terminal() {
    print_section "Configuring GNOME Terminal"

    # Check if GNOME Terminal is available
    if ! command -v gnome-terminal &> /dev/null; then
        print_info "GNOME Terminal not found. Skipping terminal configuration."
        return
    fi

    # Check if gsettings schema exists
    local schemas=$(gsettings list-schemas 2>/dev/null || true)
    if ! echo "$schemas" | grep -q "org.gnome.Terminal.ProfilesList"; then
        print_info "GNOME Terminal gsettings schema not found. Skipping terminal configuration."
        return
    fi

    set_terminal_font
}
