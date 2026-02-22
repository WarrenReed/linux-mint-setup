#!/bin/bash

################################################################################
# Linux Mint Bootstrap Script
# 
# Purpose: Initial setup script for bootstrapping a fresh Linux Mint installation
# 
# This script installs essential applications and packages including:
#   - ASP.NET Core Runtime 8.0
#   - Aspire CLI
#   - Azure Artifacts Credential Provider
#   - Azure CLI
#   - Azure Storage Explorer
#   - Azure VPN Client
#   - Devolutions Remote Desktop Manager
#   - Discord
#   - Docker Engine
#   - Fish Shell
#   - Git Credential Manager
#   - Git and development tools
#   - Google Chrome
#   - KVM/QEMU with virt-manager
#   - linux-dev-certs
#   - Meslo Nerd Font
#   - .NET SDK 10.0
#   - Node.js 22
#   - NSwag CLI
#   - oh-my-posh
#   - PowerShell
#   - Private Internet Access VPN
#   - Slack
#   - Steam
#   - VS Code
#
# Usage: bash bootstrap-mint.sh
# Prerequisites: Fresh Linux Mint installation with internet connection
# Note: Script will request sudo privileges when needed
# Post-install: Bash is configured with oh-my-posh
#               Fish shell is configured with oh-my-posh and fnm
#               PowerShell is configured with oh-my-posh
#               GNOME Terminal is configured to use Meslo Nerd Font
#               oh-my-posh theme: configurable via OMP_THEME_PATH variable
#               Hosts file configured with: 127.0.0.1 sql-server
################################################################################

set -e          # Exit immediately if a command exits with a non-zero status
set -u          # Treat unset variables as an error
set -o pipefail # Catch failures in pipes

# Cleanup handler
cleanup() {
    # Future-proofing for any temporary resources
    :
}

trap cleanup EXIT

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Configuration
# Old convention (compatible with Linux Mint UI): /etc/apt/trusted.gpg.d
# Modern convention: /usr/share/keyrings
# Note: Linux Mint 22 is based on Ubuntu 24.04 LTS (noble)
export KEYRING_DIR="/etc/apt/trusted.gpg.d"
export UBUNTU_DISTRO="noble"  # noble=24.04, jammy=22.04, focal=20.04
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly OMP_THEME_PATH="~/.cache/oh-my-posh/themes/atomic.omp.json"
readonly PIA_FALLBACK_VERSION="3.7-08412"

# Helper functions
print_section() {
    echo -e "\n${GREEN}==== $1 ====${NC}\n"
}

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

################################################################################
# Core Setup Functions
################################################################################

check_prerequisites() {
    # Check if running with sudo privileges
    if [ "$EUID" -eq 0 ]; then
        print_error "Please do not run this script as root. It will request sudo when needed."
        exit 1
    fi
    
    # Check if repos.json exists
    if [ ! -f "${SCRIPT_DIR}/repos.json" ]; then
        print_error "repos.json not found in ${SCRIPT_DIR}"
        exit 1
    fi
    
    # Check if preferences directory exists
    if [ ! -d "${SCRIPT_DIR}/preferences" ]; then
        print_error "preferences/ directory not found in ${SCRIPT_DIR}"
        exit 1
    fi
}

install_required_utilities() {
    print_section "Installing Required Utilities"
    sudo apt update
    sudo apt install -y curl gettext-base jq
}

install_repository_keys() {
    print_section "Installing Repository GPG Keys"
    declare -A installed_keys
    
    while IFS= read -r key_name; do
        if [ -z "${installed_keys[$key_name]:-}" ]; then
            local key_file="${KEYRING_DIR}/${key_name}.gpg"
            
            if [ -f "$key_file" ]; then
                print_info "$key_name GPG key already exists."
            else
                local key_url=$(jq -r ".keys[] | select(.name == \"$key_name\") | .url" "${SCRIPT_DIR}/repos.json")
                print_info "Installing $key_name GPG key..."
                curl -fsSL "$key_url" | gpg --dearmor | sudo tee "$key_file" > /dev/null
            fi
            installed_keys[$key_name]=1
        fi
    done < <(jq -r '.repositories[].key' "${SCRIPT_DIR}/repos.json" | sort -u)
}

add_third_party_repositories() {
    print_section "Adding Third-Party Repositories"
    
    jq -c '.repositories[]' "${SCRIPT_DIR}/repos.json" | while IFS= read -r repo; do
        local name=$(echo "$repo" | jq -r '.name')
        local filename=$(echo "$repo" | jq -r '.filename')
        local key=$(echo "$repo" | jq -r '.key')
        local sources_file="/etc/apt/sources.list.d/${filename}"
        
        if [ -f "$sources_file" ]; then
            print_info "$name repository already exists."
        else
            print_info "Adding $name repository..."
            
            # Generate .sources file content
            {
                echo "X-Repolib-Name: $name"
                echo "Types: $(echo "$repo" | jq -r '.types')"
                echo "URIs: $(echo "$repo" | jq -r '.uris')"
                echo "Suites: $(echo "$repo" | jq -r '.suites')"
                echo "Components: $(echo "$repo" | jq -r '.components')"
                
                # Optional architectures field
                local arch=$(echo "$repo" | jq -r '.architectures // empty')
                if [ -n "$arch" ]; then
                    echo "Architectures: $arch"
                fi
                
                echo "Signed-by: \${KEYRING_DIR}/${key}.gpg"
                echo "Enabled: yes"
            } | envsubst | sudo tee "$sources_file" > /dev/null
        fi
    done
}

add_ppa_repositories() {
    print_section "Adding PPA Repositories"
    
    # Check if Fish Shell PPA is already added
    if grep -qr "^deb .*ppa.launchpad.net/fish-shell/release-4" /etc/apt/sources.list.d/ 2>/dev/null; then
        print_info "Fish Shell PPA repository already exists."
    else
        print_info "Adding Fish Shell PPA repository..."
        sudo add-apt-repository -y ppa:fish-shell/release-4
    fi
}

configure_apt_preferences() {
    print_section "Configuring APT Preferences"
    
    # Copy all preference files from preferences/ directory
    for pref_file in "${SCRIPT_DIR}/preferences/"*; do
        # Skip if no files found (glob doesn't match)
        [ -e "$pref_file" ] || continue
        
        local filename=$(basename "$pref_file")
        local dest_file="/etc/apt/preferences.d/${filename}"
        
        if [ -f "$dest_file" ]; then
            print_info "APT preferences file ${filename} already exists."
        else
            print_info "Installing APT preferences file ${filename}..."
            sudo cp "$pref_file" "$dest_file"
        fi
    done
}

update_apt_cache() {
    print_section "Updating Package Lists"
    sudo apt update
}

install_apt_packages() {
    print_section "Installing APT Packages"
    
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
    sudo apt install -y \
        code \
        fish \
        git \
        powershell
    
    print_info "Installing applications..."
    sudo apt install -y \
        google-chrome-stable \
        remotedesktopmanager \
        steam-installer
    
    print_info "Installing libraries..."
    sudo apt install -y \
        libnss3-tools
}

configure_docker() {
    print_section "Configuring Docker"
    
    if groups $USER | grep -q '\bdocker\b'; then
        print_info "User is already in docker group."
    else
        print_info "Adding current user to docker group..."
        sudo usermod -aG docker $USER
        print_info "You'll need to log out and back in for docker group membership to take effect."
    fi
}

configure_virtualization() {
    print_section "Configuring Virtualization"
    
    local groups_added=false
    
    if groups $USER | grep -q '\blibvirt\b'; then
        print_info "User is already in libvirt group."
    else
        print_info "Adding current user to libvirt group..."
        sudo usermod -aG libvirt $USER
        groups_added=true
    fi
    
    if groups $USER | grep -q '\bkvm\b'; then
        print_info "User is already in kvm group."
    else
        print_info "Adding current user to kvm group..."
        sudo usermod -aG kvm $USER
        groups_added=true
    fi
    
    if [ "$groups_added" = true ]; then
        print_info "You'll need to log out and back in for virtualization group membership to take effect."
    fi
}

install_standalone_packages() {
    # Ensure .NET tools are in PATH for this session
    export PATH="$PATH:$HOME/.dotnet/tools"
    
    # Install fnm (Fast Node Manager)
    print_section "Installing fnm (Fast Node Manager)"
    if command -v fnm &> /dev/null; then
        print_info "fnm is already installed."
    else
        print_info "Installing fnm..."
        curl -o- https://fnm.vercel.app/install | bash
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
        curl -fsSL https://ohmyposh.dev/install.sh | bash -s
    fi
    
    # Install Meslo Nerd Font
    print_section "Installing Meslo Nerd Font"
    if [ -d ~/.local/share/fonts/meslolgm-nerd-font ] || [ -d ~/.local/share/fonts/meslolgm-nerd-font-mono ]; then
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
        
        if [ -z "$pia_version" ]; then
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
    
    # Install NSwag CLI (.NET global tool)
    print_section "Installing NSwag CLI"
    print_info "Installing/updating NSwag CLI as .NET global tool..."
    dotnet tool update -g NSwag.ConsoleCore
    
    # Install linux-dev-certs (.NET global tool)
    print_section "Installing linux-dev-certs"
    print_info "Installing/updating linux-dev-certs as .NET global tool..."
    dotnet tool update -g linux-dev-certs
    
    # Configure HTTPS development certificates
    print_info "Configuring HTTPS development certificates..."
    dotnet linux-dev-certs install
    
    # Install Azure Artifacts Credential Provider (.NET global tool)
    print_section "Installing Azure Artifacts Credential Provider"
    print_info "Installing/updating Azure Artifacts Credential Provider as .NET global tool..."
    dotnet tool update -g Microsoft.Artifacts.CredentialProvider.NuGet.Tool
    
    # Install Git Credential Manager (.NET global tool)
    print_section "Installing Git Credential Manager"
    print_info "Installing/updating Git Credential Manager as .NET global tool..."
    dotnet tool update -g git-credential-manager
    
    # Configure Git Credential Manager
    print_info "Configuring Git Credential Manager..."
    git-credential-manager configure
    
    # Set credential store to secretservice for Linux desktop environment
    local current_store=$(git config --global credential.credentialStore 2>/dev/null || echo "")
    if [ "$current_store" != "secretservice" ]; then
        print_info "Setting credential store to secretservice (GNOME Keyring)..."
        git config --global credential.credentialStore secretservice
    else
        print_info "Credential store already configured to secretservice."
    fi
}

install_flatpak_apps() {
    print_section "Installing Flatpak Applications"
    
    # Install Azure Storage Explorer
    if flatpak list | grep -q "com.microsoft.AzureStorageExplorer"; then
        print_info "Azure Storage Explorer is already installed."
    else
        print_info "Installing Azure Storage Explorer..."
        flatpak install -y flathub com.microsoft.AzureStorageExplorer
    fi
    
    # Install Discord
    if flatpak list | grep -q "com.discordapp.Discord"; then
        print_info "Discord is already installed."
    else
        print_info "Installing Discord..."
        flatpak install -y flathub com.discordapp.Discord
    fi
    
    # Install Slack
    if flatpak list | grep -q "com.slack.Slack"; then
        print_info "Slack is already installed."
    else
        print_info "Installing Slack..."
        flatpak install -y flathub com.slack.Slack
    fi
}

configure_fish() {
    print_section "Configuring Fish Shell"
    
    local fish_path=$(command -v fish)
    
    # Add fish to /etc/shells if not already present
    if grep -qF "$fish_path" /etc/shells; then
        print_info "Fish is already in /etc/shells."
    else
        print_info "Adding fish to list of valid shells..."
        echo "$fish_path" | sudo tee -a /etc/shells > /dev/null
    fi
    
    # Set fish as default shell if not already
    if [ "$SHELL" = "$fish_path" ]; then
        print_info "Fish is already your default shell."
    else
        print_info "Setting fish as default shell..."
        chsh -s "$fish_path"
        print_info "Fish is now your default shell. Log out and back in for the change to take effect."
    fi
    
    # Configure oh-my-posh
    print_info "Creating Fish config directory..."
    mkdir -p ~/.config/fish
    
    local fish_config=~/.config/fish/config.fish
    local omp_line="oh-my-posh init fish --config ${OMP_THEME_PATH} | source"
    
    if [ -f "$fish_config" ] && grep -qF "$omp_line" "$fish_config"; then
        print_info "oh-my-posh is already configured in Fish config."
    else
        print_info "Setting up oh-my-posh theme..."
        echo "# oh-my-posh prompt theme" >> "$fish_config"
        echo "$omp_line" >> "$fish_config"
        print_info "Fish is now configured to use oh-my-posh."
    fi
    
    # Configure fnm
    print_info "Configuring fnm in Fish shell..."
    mkdir -p ~/.config/fish/conf.d
    local fnm_config=~/.config/fish/conf.d/fnm.fish
    local fnm_line='fnm env --use-on-cd --shell fish | source'
    
    if [ -f "$fnm_config" ] && grep -qF "$fnm_line" "$fnm_config"; then
        print_info "fnm is already configured in Fish."
    else
        printf 'set -gx PATH "$HOME/.local/share/fnm" $PATH\nfnm env --use-on-cd --shell fish | source\n' > "$fnm_config"
        print_info "fnm is now configured in Fish shell."
    fi
}

configure_bash() {
    print_section "Configuring Bash"
    
    local bashrc=~/.bashrc
    local omp_line="eval \"\$(oh-my-posh init bash --config ${OMP_THEME_PATH})\""
    
    if [ -f "$bashrc" ] && grep -qF "oh-my-posh init bash" "$bashrc"; then
        print_info "oh-my-posh is already configured in .bashrc."
    else
        print_info "Setting up oh-my-posh theme..."
        echo "" >> "$bashrc"
        echo "# oh-my-posh prompt theme" >> "$bashrc"
        echo "$omp_line" >> "$bashrc"
        print_info "Bash is now configured to use oh-my-posh."
    fi
}

configure_powershell() {
    print_section "Configuring PowerShell"
    
    print_info "Creating PowerShell config directory..."
    mkdir -p ~/.config/powershell
    
    local pwsh_profile=~/.config/powershell/Microsoft.PowerShell_profile.ps1
    local omp_line="oh-my-posh init pwsh --config ${OMP_THEME_PATH} | Invoke-Expression"
    
    if [ -f "$pwsh_profile" ] && grep -qF "$omp_line" "$pwsh_profile"; then
        print_info "oh-my-posh is already configured in PowerShell profile."
    else
        print_info "Setting up oh-my-posh theme..."
        echo "$omp_line" >> "$pwsh_profile"
        print_info "PowerShell is now configured to use oh-my-posh."
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
    if ! gsettings list-schemas | grep -q "org.gnome.Terminal.ProfilesList"; then
        print_info "GNOME Terminal gsettings schema not found. Skipping terminal configuration."
        return
    fi
    
    print_info "Setting Meslo Nerd Font for GNOME Terminal..."
    PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ use-system-font false
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ font 'MesloLGM Nerd Font 10'
    print_info "GNOME Terminal is now configured to use Meslo Nerd Font."
}

configure_hosts() {
    print_section "Configuring Hosts File"
    
    local hosts_file="/etc/hosts"
    
    if grep -qF "sql-server" "$hosts_file"; then
        print_info "sql-server entry already exists in hosts file."
    else
        print_info "Adding sql-server to hosts file..."
        {
            echo ""
            echo "# SQL Server container orchestrated by Aspire"
            echo -e "127.0.0.1\tsql-server"
        } | sudo tee -a "$hosts_file" > /dev/null
        print_info "sql-server entry added to hosts file."
    fi
}

################################################################################
# Main Execution
################################################################################

main() {
    print_section "Starting Linux Mint Setup"
    
    # Prerequisites
    check_prerequisites
    install_required_utilities
    
    # Repository Setup
    install_repository_keys
    add_third_party_repositories
    add_ppa_repositories
    configure_apt_preferences
    update_apt_cache
    
    # Package Installation
    install_apt_packages
    install_flatpak_apps
    
    # Standalone Packages
    install_standalone_packages
    
    # Configuration
    configure_docker
    configure_virtualization
    configure_bash
    configure_fish
    configure_powershell
    configure_terminal
    configure_hosts
    
    # Completion
    print_section "Installation Complete!"
    print_info "All packages have been successfully installed."
    echo -e "\n${GREEN}Setup finished!${NC}"
    echo "You may need to log out and back in for some changes to take effect."
}

# Run main function
main