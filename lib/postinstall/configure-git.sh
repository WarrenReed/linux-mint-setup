#!/bin/bash

# ============================================================================
# Git Configuration
# ============================================================================
# Configures Git and Git Credential Manager.
# Sourced by bootstrap-mint.sh
# ============================================================================

configure_git() {
    print_section "Configuring Git"
    
    # Configure Git Credential Manager
    if command -v git-credential-manager &> /dev/null; then
        print_info "Configuring Git Credential Manager..."
        git-credential-manager configure
        
        # Set credential store to secretservice for Linux desktop environment
        local current_store=$(git config --global credential.credentialStore 2>/dev/null || echo "")
        if [[ "$current_store" != "secretservice" ]]; then
            print_info "Setting credential store to secretservice (GNOME Keyring)..."
            git config --global credential.credentialStore secretservice
        else
            print_info "Credential store already configured to secretservice."
        fi
    else
        print_info "Git Credential Manager not found, skipping configuration."
    fi
}
