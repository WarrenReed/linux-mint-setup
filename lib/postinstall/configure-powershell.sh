#!/bin/bash

# ============================================================================
# PowerShell Configuration
# ============================================================================
# Configures PowerShell profile with oh-my-posh prompt theme.
# Sourced by bootstrap-mint.sh
# ============================================================================

configure_powershell_prompt() {
    mkdir -p ~/.config/powershell
    local pwsh_profile=~/.config/powershell/Microsoft.PowerShell_profile.ps1
    local omp_line="oh-my-posh init pwsh --config ${OMP_THEME_PATH} | Invoke-Expression"

    if [[ -f "$pwsh_profile" ]] && grep -qF "$omp_line" "$pwsh_profile"; then
        print_info "oh-my-posh already configured in PowerShell."
    else
        print_info "Configuring oh-my-posh prompt theme for PowerShell..."
        echo "$omp_line" >> "$pwsh_profile"
        print_info "oh-my-posh theme configured for PowerShell."
    fi
}

configure_powershell() {
    print_section "Configuring PowerShell"

    configure_powershell_prompt

    print_info "PowerShell configuration completed."
}
