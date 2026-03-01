#!/bin/bash

# ============================================================================
# .NET Configuration
# ============================================================================
# Configures .NET development certificate.
# Sourced by bootstrap-mint.sh
# ============================================================================

trust_dotnet_dev_certificate() {
    # Export SSL_CERT_DIR for the dotnet command in this bash session
    export SSL_CERT_DIR="/etc/ssl/certs:$HOME/.aspnet/dev-certs/trust"

    if dotnet dev-certs https --check --trust &> /dev/null; then
        print_info ".NET HTTPS development certificate is already trusted."
    else
        print_info "Trusting .NET development certificate..."
        dotnet dev-certs https --trust
        print_info ".NET development certificate trusted."
    fi
}

configure_dotnet() {
    print_section "Configuring .NET"

    trust_dotnet_dev_certificate
}
