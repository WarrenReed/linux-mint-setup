#!/bin/bash

# ============================================================================
# APT Package Installation
# ============================================================================
# Installs packages from APT repositories.
# Sourced by bootstrap-mint.sh
# ============================================================================

install_deb_package() {
    local package_name=$1
    local display_name=$2
    local download_url=$3
    
    if dpkg-query -s "$package_name" &> /dev/null; then
        print_info "$display_name is already installed."
    else
        print_info "Downloading and installing $display_name..."
        local temp_deb=$(mktemp --suffix=.deb)
        curl -fsSL -o "$temp_deb" "$download_url"
        sudo apt install -y "$temp_deb"
        rm -f "$temp_deb"
    fi
}

install_apt_packages() {
    print_section "Installing APT Packages"
    
    # Install Google Chrome (downloads .deb which adds repository automatically)
    print_info "Installing Google Chrome..."
    install_deb_package "google-chrome-stable" "Google Chrome" \
        "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
    
    print_info "Installing .NET packages..."
    sudo apt install -y \
        aspnetcore-runtime-8.0 \
        dotnet-sdk-10.0
    
    print_info "Installing Docker packages..."
    sudo apt install -y \
        containerd.io \
        docker-buildx-plugin \
        docker-ce \
        docker-ce-cli \
        docker-compose-plugin
    
    print_info "Installing virtualization packages..."
    sudo apt install -y \
        bridge-utils \
        libvirt-clients \
        libvirt-daemon-system \
        qemu-kvm \
        virt-manager
    
    print_info "Installing Azure tools..."
    sudo apt install -y \
        azure-cli \
        microsoft-azurevpnclient
    
    print_info "Installing development tools..."
    
    # Prevent VS Code from managing its own repository (we manage it via config/repositories.json)
    echo "code code/add-microsoft-repo boolean false" | sudo debconf-set-selections
    
    sudo apt install -y \
        code \
        fish \
        git \
        powershell
    
    print_info "Installing applications..."
    sudo apt install -y \
        remotedesktopmanager \
        steam-installer
}
