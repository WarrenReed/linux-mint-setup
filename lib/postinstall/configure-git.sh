#!/bin/bash

# ============================================================================
# Git Configuration
# ============================================================================
# Configures Git and Git Credential Manager.
# Sourced by bootstrap-mint.sh
# ============================================================================

configure_git_identity() {
    # Configure personal (default) git identity
    print_info "Configuring personal git identity..."
    local current_name=$(git config --global user.name 2>/dev/null || echo "")
    local current_email=$(git config --global user.email 2>/dev/null || echo "")

    if [[ "$current_name" != "$GIT_NAME" ]]; then
        git config --global user.name "$GIT_NAME"
        print_info "Set global git name to: $GIT_NAME"
    else
        print_info "Global git name already configured."
    fi

    if [[ "$current_email" != "$GIT_PERSONAL_EMAIL" ]]; then
        git config --global user.email "$GIT_PERSONAL_EMAIL"
        print_info "Set global git email to: $GIT_PERSONAL_EMAIL"
    else
        print_info "Global git email already configured."
    fi

    # Create work-specific git config file
    print_info "Creating work git configuration..."
    local work_config="$HOME/.gitconfig-work"

    if [[ ! -f "$work_config" ]] || ! grep -q "$GIT_WORK_EMAIL" "$work_config" 2>/dev/null; then
        cat > "$work_config" << EOF
[user]
    name = $GIT_NAME
    email = $GIT_WORK_EMAIL
EOF
        print_info "Created $work_config"
    else
        print_info "Work git config already exists."
    fi

    # Add conditional include for work repositories
    print_info "Configuring conditional includes..."

    # Check if conditional include already exists
    if ! git config --global --get-regexp "includeIf\.gitdir:$GIT_WORK_PATH/\.path" &> /dev/null; then
        git config --global "includeIf.gitdir:$GIT_WORK_PATH/.path" "$work_config"
        print_info "Added conditional include for $GIT_WORK_PATH/"
    else
        print_info "Conditional include already configured."
    fi
}

configure_git_credential_manager() {
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

configure_git() {
    print_section "Configuring Git"

    configure_git_identity
    configure_git_credential_manager
}
