#!/bin/bash

# ============================================================================
# Standalone Package Installation
# ============================================================================
# Installs packages via direct download or custom installers.
# Sourced by bootstrap-mint.sh
# ============================================================================

install_standalone_packages() {
    # Install fnm (Fast Node Manager)
    print_section "Installing fnm (Fast Node Manager)"
    if command -v fnm &> /dev/null; then
        print_info "fnm is already installed."
    else
        print_info "Installing fnm..."
        curl -fsSL https://fnm.vercel.app/install | bash
    fi

    # Install Node.js 22 via fnm
    print_section "Installing Node.js 22"
    if command -v fnm &> /dev/null && fnm list | grep -q "v22"; then
        print_info "Node.js 22 is already installed via fnm."
    else
        print_info "Installing Node.js 22 via fnm..."
        # Load fnm in current shell session
        export PATH="$HOME/.local/share/fnm:$PATH"
        eval "$(fnm env --shell bash)"
        fnm install 22
        fnm default 22
    fi

    # Install Aspire CLI
    print_section "Installing Aspire CLI"
    if command -v aspire &> /dev/null; then
        print_info "Aspire CLI is already installed."
    else
        print_info "Downloading and installing Aspire CLI..."
        curl -fsSL https://aspire.dev/install.sh | bash
    fi

    # Install oh-my-posh
    print_section "Installing oh-my-posh"
    if command -v oh-my-posh &> /dev/null; then
        print_info "oh-my-posh is already installed."
    else
        print_info "Downloading and installing oh-my-posh..."
        # Add oh-my-posh to PATH for current session
        export PATH="$HOME/.local/bin:$PATH"
        curl -fsSL https://ohmyposh.dev/install.sh | bash
    fi

    # Install Meslo Nerd Font
    print_section "Installing Meslo Nerd Font"
    if [[ -d ~/.local/share/fonts/meslolgm-nerd-font ]] || [[ -d ~/.local/share/fonts/meslolgm-nerd-font-mono ]]; then
        print_info "Meslo Nerd Font is already installed."
    else
        print_info "Installing Meslo Nerd Font..."
        oh-my-posh font install meslo
    fi

    # Install Private Internet Access VPN
    print_section "Installing Private Internet Access VPN"
    if command -v piactl &> /dev/null; then
        print_info "Private Internet Access is already installed."
    else
        print_info "Fetching latest version information..."
        local pia_version=$(curl -fsSL "https://www.privateinternetaccess.com/download/linux-vpn" | \
            grep -oP 'pia-linux-\K[0-9.]+-[0-9]+(?=\.run)' | \
            head -n 1)

        if [[ -z "$pia_version" ]]; then
            print_error "Failed to detect latest PIA version, using fallback: ${PIA_FALLBACK_VERSION}"
            pia_version="$PIA_FALLBACK_VERSION"
        else
            print_info "Latest version detected: $pia_version"
        fi

        print_info "Downloading and installing Private Internet Access..."
        local temp_installer=$(mktemp)
        curl -fsSL -o "$temp_installer" "https://installers.privateinternetaccess.com/download/pia-linux-${pia_version}.run"
        chmod +x "$temp_installer"
        "$temp_installer" --accept --noprogress
        rm -f "$temp_installer"
    fi
}
