#!/bin/bash

# ============================================================================
# Environment Configuration
# ============================================================================
# Configures system-wide environment variables for desktop session.
# Sets up .profile for variables needed by desktop-launched applications.
# Sourced by setup-linux-mint.sh
# ============================================================================

set_profile_ssl_cert_dir() {
    local profile=~/.profile

    if [[ -f "$profile" ]] && grep -qF 'SSL_CERT_DIR' "$profile"; then
        print_info "SSL_CERT_DIR already set in .profile."
    else
        print_info "Setting SSL_CERT_DIR in .profile for desktop session..."
        echo "" >> "$profile"
        echo "# SSL certificate directory for .NET development" >> "$profile"
        echo 'export SSL_CERT_DIR="/etc/ssl/certs:$HOME/.aspnet/dev-certs/trust"' >> "$profile"
        print_info "SSL_CERT_DIR set for desktop-launched applications."
    fi
}

set_profile_nuget_packages() {
    local profile=~/.profile

    if [[ -z "${NUGET_PACKAGES:-}" ]]; then
        return
    fi

    if [[ -f "$profile" ]] && grep -qF 'NUGET_PACKAGES' "$profile"; then
        print_info "NUGET_PACKAGES already set in .profile."
    else
        print_info "Setting NUGET_PACKAGES in .profile for desktop session..."
        echo "" >> "$profile"
        echo "# NuGet package cache location" >> "$profile"
        echo "export NUGET_PACKAGES=\"$NUGET_PACKAGES\"" >> "$profile"
        print_info "NUGET_PACKAGES set for desktop-launched applications."
    fi
}

configure_environment() {
    print_section "Configuring Environment"

    set_profile_ssl_cert_dir
    set_profile_nuget_packages

    print_info "Environment configuration completed."
}
