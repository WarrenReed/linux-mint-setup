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
        print_info "Installing $display_name..."
        local temp_deb=$(mktemp --suffix=.deb)
        curl -fsSL -o "$temp_deb" "$download_url"
        sudo apt install -y "$temp_deb"
        rm -f "$temp_deb"
        print_info "$display_name installed."
    fi
}

install_applications() {
    print_info "Installing applications..."
    sudo apt install -y \
        microsoft-azurevpnclient \
        pavucontrol \
        remotedesktopmanager \
        steam-installer

    install_deb_package "google-chrome-stable" "Google Chrome" \
        "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

    print_info "Applications installed."
}

install_development_tools() {
    print_info "Installing development tools..."

    # Prevent VS Code from managing its own repository (we manage it via config/repositories.json)
    echo "code code/add-microsoft-repo boolean false" | sudo debconf-set-selections

    sudo apt install -y \
        azure-cli \
        code \
        fish \
        git \
        powershell \
        sourcegit
    print_info "Development tools installed."
}

install_docker_packages() {
    print_info "Installing Docker packages..."
    sudo apt install -y \
        containerd.io \
        docker-buildx-plugin \
        docker-ce \
        docker-ce-cli \
        docker-compose-plugin
    print_info "Docker packages installed."
}

install_dotnet_packages() {
    print_info "Installing .NET packages..."
    sudo apt install -y \
        aspnetcore-runtime-8.0 \
        dotnet-sdk-10.0 \
        libnss3-tools  # Required for certutil (used to trust .NET dev certificates)
    print_info ".NET packages installed."
}

install_virtualization_packages() {
    print_info "Installing virtualization packages..."
    sudo apt install -y \
        bridge-utils \
        libvirt-clients \
        libvirt-daemon-system \
        qemu-kvm \
        virt-manager
    print_info "Virtualization packages installed."
}

install_apt_packages() {
    print_section "Installing APT Packages"

    install_applications
    install_development_tools
    install_docker_packages
    install_dotnet_packages
    install_virtualization_packages

    print_info "APT package installation completed."
}
