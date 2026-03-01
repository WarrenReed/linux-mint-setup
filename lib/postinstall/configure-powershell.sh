#!/bin/bash

# ============================================================================
# PowerShell Configuration
# ============================================================================
# Configures PowerShell profile with oh-my-posh prompt theme.
# Sourced by bootstrap-mint.sh
# ============================================================================

configure_powershell() {
    print_section "Configuring PowerShell"

    print_info "Creating PowerShell config directory..."
    mkdir -p ~/.config/powershell

    local pwsh_profile=~/.config/powershell/Microsoft.PowerShell_profile.ps1
    local omp_line="oh-my-posh init pwsh --config ${OMP_THEME_PATH} | Invoke-Expression"

    if [[ -f "$pwsh_profile" ]] && grep -qF "$omp_line" "$pwsh_profile"; then
        print_info "oh-my-posh is already configured in PowerShell profile."
    else
        print_info "Setting up oh-my-posh theme..."
        echo "$omp_line" >> "$pwsh_profile"
        print_info "PowerShell is now configured to use oh-my-posh."
    fi
}
