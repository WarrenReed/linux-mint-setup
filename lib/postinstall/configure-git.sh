#!/bin/bash

# ============================================================================
# Git Configuration
# ============================================================================
# Configures Git and Git Credential Manager.
# Sourced by bootstrap-mint.sh
# ============================================================================

configure_git_identity() {
    # Configure personal (default) git identity
    local current_name=$(git config --global user.name 2>/dev/null || echo "")
    local current_email=$(git config --global user.email 2>/dev/null || echo "")

    if [[ "$current_name" != "$GIT_NAME" ]]; then
        print_info "Setting global git name..."
        git config --global user.name "$GIT_NAME"
        print_info "Global git name set."
    else
        print_info "Global git name already configured."
    fi

    if [[ "$current_email" != "$GIT_PERSONAL_EMAIL" ]]; then
        print_info "Setting global git email..."
        git config --global user.email "$GIT_PERSONAL_EMAIL"
        print_info "Global git email set."
    else
        print_info "Global git email already configured."
    fi

    # Create work-specific git config file
    local work_config="$HOME/.gitconfig-work"

    if [[ ! -f "$work_config" ]] || ! grep -q "$GIT_WORK_EMAIL" "$work_config" 2>/dev/null; then
        print_info "Creating work git configuration..."
        cat > "$work_config" << EOF
[user]
    name = $GIT_NAME
    email = $GIT_WORK_EMAIL
EOF
        print_info "Work git config created."
    else
        print_info "Work git config already exists."
    fi

    # Add conditional include for work repositories
    if ! git config --global --get-regexp "includeIf\.gitdir:$GIT_WORK_PATH/\.path" &> /dev/null; then
        print_info "Adding conditional include for work repositories..."
        git config --global "includeIf.gitdir:$GIT_WORK_PATH/.path" "$work_config"
        print_info "Conditional include added."
    else
        print_info "Conditional include already configured."
    fi
}

configure_git_credential_manager() {
    if command -v git-credential-manager &> /dev/null; then
        print_info "Configuring Git Credential Manager..."
        git-credential-manager configure
        print_info "Git Credential Manager configured."

        # Set credential store to secretservice for Linux desktop environment
        local current_store=$(git config --global credential.credentialStore 2>/dev/null || echo "")
        if [[ "$current_store" != "secretservice" ]]; then
            print_info "Setting credential store to secretservice..."
            git config --global credential.credentialStore secretservice
            print_info "Credential store set to secretservice."
        else
            print_info "Credential store already set to secretservice."
        fi

        # Disable Bitbucket credential validation to prevent re-authentication prompts
        # GCM validation fails due to Email/Username mismatch between API and Git operations
        local bitbucket_validate=$(git config --global credential.bitbucketValidateStoredCredentials 2>/dev/null || echo "")
        if [[ "$bitbucket_validate" != "false" ]]; then
            print_info "Disabling Bitbucket credential validation..."
            git config --global credential.bitbucketValidateStoredCredentials false
            print_info "Bitbucket credential validation disabled."
        else
            print_info "Bitbucket credential validation already disabled."
        fi
    else
        print_info "Git Credential Manager not found, skipping configuration."
    fi
}

configure_git() {
    print_section "Configuring Git"

    configure_git_identity
    configure_git_credential_manager

    print_info "Git configuration completed."
}
