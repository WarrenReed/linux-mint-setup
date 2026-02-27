#!/bin/bash

################################################################################
# Linux Mint Bootstrap Script
# 
# Purpose: Initial setup script for bootstrapping a fresh Linux Mint installation
# 
# This script removes unwanted packages (Firefox) and installs essential 
# applications and packages including:
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
#   - GitHub Copilot CLI
#   - Google Chrome
#   - KVM/QEMU with virt-manager
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
#               Fish shell is configured with oh-my-posh, fnm, and SSL_CERT_DIR
#               PowerShell is configured with oh-my-posh
#               GNOME Terminal is configured to use Meslo Nerd Font
#               oh-my-posh theme: configurable via OMP_THEME_PATH variable
#               Hosts file configured with: 127.0.0.1 sql-server
#               Cinnamon desktop configured (dark theme, centered panel, slideshow, centered login)
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
    install_npm_packages
    
    # Postinstall Phase
    configure_bash
    configure_docker
    configure_fish
    configure_git
    configure_grub
    configure_hosts
    configure_cinnamon
    configure_powershell
    configure_terminal
    configure_virtualization
    
    # Completion
    print_section "Installation Complete!"
    print_info "All packages have been successfully installed."
    echo -e "\n${GREEN}Setup finished!${NC}"
    echo "Please reboot your system for all changes to take effect."
}

# Run main function
main
