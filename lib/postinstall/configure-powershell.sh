#!/bin/bash

# ============================================================================
# PowerShell Configuration
# ============================================================================
# Configures PowerShell profile with oh-my-posh, fnm, pnpm, Aspire, and SSL_CERT_DIR.
# Sourced by bootstrap-mint.sh
# ============================================================================

add_aspire_to_powershell_path() {
    local pwsh_profile=~/.config/powershell/Microsoft.PowerShell_profile.ps1
    local aspire_path_check='$env:ASPIRE_PATH'

    if [[ -f "$pwsh_profile" ]] && grep -qF "$aspire_path_check" "$pwsh_profile"; then
        print_info "Aspire already added to PowerShell PATH."
    else
        print_info "Adding Aspire to PowerShell PATH..."
        echo "" >> "$pwsh_profile"
        echo "# Aspire CLI" >> "$pwsh_profile"
        echo '$env:ASPIRE_PATH = "$env:HOME/.aspire/bin"' >> "$pwsh_profile"
        echo '$env:PATH = $env:ASPIRE_PATH + [System.IO.Path]::PathSeparator + $env:PATH' >> "$pwsh_profile"
        print_info "Aspire added to PowerShell PATH."
    fi
}

add_fnm_to_powershell_path() {
    local pwsh_profile=~/.config/powershell/Microsoft.PowerShell_profile.ps1
    local fnm_path_check='fnm env --use-on-cd'

    if [[ -f "$pwsh_profile" ]] && grep -qF "$fnm_path_check" "$pwsh_profile"; then
        print_info "fnm already added to PowerShell PATH."
    else
        print_info "Adding fnm to PowerShell PATH..."
        echo "" >> "$pwsh_profile"
        echo "# fnm" >> "$pwsh_profile"
        echo '$env:FNM_PATH = "$env:HOME/.local/share/fnm"' >> "$pwsh_profile"
        echo '& "$env:FNM_PATH/fnm" env --use-on-cd --shell powershell | Out-String | Invoke-Expression' >> "$pwsh_profile"
        echo '$env:PATH = $env:FNM_PATH + [System.IO.Path]::PathSeparator + $env:PATH' >> "$pwsh_profile"
        print_info "fnm added to PowerShell PATH."
    fi
}

add_pnpm_to_powershell_path() {
    local pwsh_profile=~/.config/powershell/Microsoft.PowerShell_profile.ps1
    local pnpm_path_check='$env:PNPM_HOME'

    if [[ -f "$pwsh_profile" ]] && grep -qF "$pnpm_path_check" "$pwsh_profile"; then
        print_info "pnpm already added to PowerShell PATH."
    else
        print_info "Adding pnpm to PowerShell PATH..."
        echo "" >> "$pwsh_profile"
        echo "# pnpm" >> "$pwsh_profile"
        echo '$env:PNPM_HOME = "$env:HOME/.local/share/pnpm"' >> "$pwsh_profile"
        echo '$env:PATH = $env:PNPM_HOME + [System.IO.Path]::PathSeparator + $env:PATH' >> "$pwsh_profile"
        print_info "pnpm added to PowerShell PATH."
    fi
}

configure_powershell_prompt() {
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

set_powershell_ssl_cert_dir() {
    local pwsh_profile=~/.config/powershell/Microsoft.PowerShell_profile.ps1
    local ssl_check='$env:SSL_CERT_DIR'

    if [[ -f "$pwsh_profile" ]] && grep -qF "$ssl_check" "$pwsh_profile"; then
        print_info "SSL_CERT_DIR already set in PowerShell."
    else
        print_info "Setting SSL_CERT_DIR in PowerShell..."
        echo "" >> "$pwsh_profile"
        echo "# SSL certificate directory for .NET development" >> "$pwsh_profile"
        echo '$env:SSL_CERT_DIR = "/etc/ssl/certs:$env:HOME/.aspnet/dev-certs/trust"' >> "$pwsh_profile"
        print_info "SSL_CERT_DIR set in PowerShell."
    fi
}

configure_powershell() {
    print_section "Configuring PowerShell"

    mkdir -p ~/.config/powershell

    add_aspire_to_powershell_path
    add_fnm_to_powershell_path
    add_pnpm_to_powershell_path
    configure_powershell_prompt
    set_powershell_ssl_cert_dir

    print_info "PowerShell configuration completed."
}
