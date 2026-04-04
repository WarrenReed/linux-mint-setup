#!/bin/bash

################################################################################
# Linux Mint Setup Script
#
# Purpose: Initial setup script for a fresh Linux Mint installation
#
# This script removes unwanted packages (Firefox) and installs essential
# applications and packages including:
#   - Angular CLI
#   - ASP.NET Core Runtime 8.0
#   - Aspire CLI
#   - Azure Artifacts Credential Provider
#   - Azure CLI
#   - Azure Storage Explorer
#   - Azure VPN Client
#   - Devolutions Remote Desktop Manager
#   - Docker Engine
#   - fnm (Fast Node Manager)
#   - Git Credential Manager
#   - Git and development tools
#   - Git-flow
#   - GitHub Copilot CLI
#   - Google Chrome
#   - KVM/QEMU with virt-manager
#   - Meslo Nerd Font
#   - .NET SDK 10.0
#   - Node.js 22
#   - NSwag CLI
#   - Oh My Zsh
#   - oh-my-posh
#   - pnpm
#   - Portainer
#   - PowerShell
#   - Private Internet Access VPN
#   - Slack
#   - SourceGit
#   - Steam
#   - VS Code
#   - Zsh
#
# Usage: bash setup-linux-mint.sh
# Prerequisites: Fresh Linux Mint installation with internet connection
# Note: Script will request sudo privileges when needed
# Post-install: Bash is configured with oh-my-posh, SSL_CERT_DIR, optionally NODE_OPTIONS, and optionally NUGET_PACKAGES
#               Zsh shell is configured with Oh My Zsh, oh-my-posh, fnm, pnpm, SSL_CERT_DIR, optionally NODE_OPTIONS, optionally NUGET_PACKAGES, and zsh-syntax-highlighting (default shell)
#               PowerShell is configured with oh-my-posh, SSL_CERT_DIR, optionally NODE_OPTIONS, and optionally NUGET_PACKAGES
#               GNOME Terminal is configured to use Meslo Nerd Font
#               oh-my-posh theme: configurable via OMP_THEME_PATH variable
#               Hosts file configured with: 127.0.0.1 sql-server
#               Desktop environment configured (dark theme, centered panel, slideshow)
#               .NET development certificates trusted
################################################################################

set -euo pipefail

# Cleanup handler
cleanup() {
    # Future-proofing for any temporary resources
    :
}

trap cleanup EXIT

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

################################################################################
# Configuration
################################################################################

# Load default configuration
source "$SCRIPT_DIR/.env"

# Load local overrides if they exist (gitignored)
if [[ -f "$SCRIPT_DIR/.env.local" ]]; then
    source "$SCRIPT_DIR/.env.local"
fi

# Derived variables
if [[ -n "$PACKAGE_CACHE_DIR" ]]; then
    readonly NUGET_PACKAGES="$PACKAGE_CACHE_DIR/nuget"
    # Create NuGet cache directory structure
    mkdir -p "$NUGET_PACKAGES"
    # Export for current session (dotnet tools will use it)
    export NUGET_PACKAGES
fi

################################################################################
# Source Library Modules
################################################################################

# Enable recursive globbing and source all lib modules
shopt -s globstar
for lib_file in "$SCRIPT_DIR/lib/"**/*.sh; do
    source "$lib_file"
done
shopt -u globstar

################################################################################
# Main Execution
################################################################################

main() {
    print_section "Starting Linux Mint Setup"

    # Preinstall Phase
    check_prerequisites
    uninstall_apt_packages
    install_required_utilities
    add_repository_keys
    add_third_party_repositories
    add_ppa_repositories
    configure_apt_preferences
    update_apt_cache

    # Install Phase
    install_apt_packages
    install_dotnet_tools
    install_flatpak_apps
    install_standalone_packages
    install_pnpm_packages
    install_docker_containers

    # Postinstall Phase
    configure_environment
    configure_bash
    configure_docker
    configure_zsh
    configure_dotnet
    configure_git
    configure_grub
    configure_hosts
    configure_powershell
    configure_virtualization
    configure_desktop
    configure_terminal

    # Completion
    print_section "Installation Complete!"
    print_info "All packages have been successfully installed."
    echo -e "\n${GREEN}Setup finished!${NC}"
    echo "Please reboot your system for all changes to take effect."
}

# Run main function
main
