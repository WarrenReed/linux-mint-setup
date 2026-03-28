#!/bin/bash

# ============================================================================
# Standalone Package Installation
# ============================================================================
# Installs packages via direct download or custom installers.
# Configures npm cache inline after Node.js installation.
# Sourced by bootstrap-mint.sh
# ============================================================================

install_aspire() {
    if [[ -f ~/.aspire/bin/aspire ]]; then
        print_info "Aspire CLI is already installed."
    else
        print_info "Installing Aspire CLI..."
        curl -fsSL https://aspire.dev/install.sh | bash
        print_info "Aspire CLI installed."
    fi
}

install_fnm() {
    if [[ -f ~/.local/share/fnm/fnm ]]; then
        print_info "fnm is already installed."
    else
        print_info "Installing fnm..."
        curl -fsSL https://fnm.vercel.app/install | bash
        print_info "fnm installed."
    fi
}

install_meslo_font() {
    if [[ -d ~/.local/share/fonts/meslolgm-nerd-font ]] || [[ -d ~/.local/share/fonts/meslolgm-nerd-font-mono ]]; then
        print_info "Meslo Nerd Font is already installed."
    else
        print_info "Installing Meslo Nerd Font..."
        oh-my-posh font install meslo
        print_info "Meslo Nerd Font installed."
    fi
}

install_nodejs() {
    # Load fnm in current shell session for both check and install
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --shell bash)"

    if fnm list 2>/dev/null | grep -q "v22"; then
        print_info "Node.js 22 is already installed via fnm."
    else
        print_info "Installing Node.js 22 via fnm..."
        fnm install 22
        fnm default 22
        print_info "Node.js 22 installed."
    fi

    # Configure npm cache if PACKAGE_CACHE_DIR is set
    if [[ -n "$PACKAGE_CACHE_DIR" ]]; then
        local npm_cache_dir="$PACKAGE_CACHE_DIR/npm"
        print_info "Configuring npm cache location: $npm_cache_dir"
        mkdir -p "$npm_cache_dir"
        npm config set cache "$npm_cache_dir" --global
        print_info "npm cache configured."
    fi
}

install_oh_my_posh() {
    if command -v oh-my-posh &> /dev/null; then
        print_info "oh-my-posh is already installed."
    else
        print_info "Installing oh-my-posh..."
        # Add oh-my-posh to PATH for current session
        export PATH="$HOME/.local/bin:$PATH"
        curl -fsSL https://ohmyposh.dev/install.sh | bash
        print_info "oh-my-posh installed."
    fi
}

install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        print_info "Oh My Zsh is already installed."
    else
        print_info "Installing Oh My Zsh..."
        # --unattended: skips chsh, skips running zsh, overwrites existing .zshrc without prompting
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_info "Oh My Zsh installed."
    fi
}

install_pia() {
    if command -v piactl &> /dev/null; then
        print_info "Private Internet Access is already installed."
    else
        print_info "Fetching latest Private Internet Access version information..."
        local pia_version=$(curl -fsSL "https://www.privateinternetaccess.com/download/linux-vpn" | \
            grep -oP 'pia-linux-\K[0-9.]+-[0-9]+(?=\.run)' | \
            head -n 1)

        if [[ -z "$pia_version" ]]; then
            print_error "Failed to detect latest PIA version, using fallback: ${PIA_FALLBACK_VERSION}"
            pia_version="$PIA_FALLBACK_VERSION"
        else
            print_info "Latest version detected: $pia_version"
        fi

        print_info "Installing Private Internet Access..."
        local temp_installer=$(mktemp)
        curl -fsSL -o "$temp_installer" "https://installers.privateinternetaccess.com/download/pia-linux-${pia_version}.run"
        chmod +x "$temp_installer"
        "$temp_installer" --accept --noprogress
        rm -f "$temp_installer"
        print_info "Private Internet Access installed."
    fi
}

install_standalone_packages() {
    print_section "Installing Standalone Packages"

    install_aspire
    install_fnm
    install_nodejs
    install_oh_my_posh
    install_oh_my_zsh
    install_meslo_font
    install_pia

    print_info "Standalone package installation completed."
}
