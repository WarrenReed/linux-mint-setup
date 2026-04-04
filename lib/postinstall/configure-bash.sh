#!/bin/bash

# ============================================================================
# Bash Configuration
# ============================================================================
# Configures Bash shell with PATH, oh-my-posh prompt theme, SSL_CERT_DIR,
# optionally NODE_OPTIONS, and optionally NUGET_PACKAGES.
# Sourced by setup-linux-mint.sh
# ============================================================================

add_local_bin_to_bash_path() {
    local bashrc=~/.bashrc
    local path_check='$HOME/.local/bin'

    if grep -qF "$path_check" "$bashrc"; then
        print_info "~/.local/bin already in Bash PATH."
    else
        print_info "Adding ~/.local/bin to Bash PATH..."
        echo "" >> "$bashrc"
        echo "# Add ~/.local/bin to PATH for user-installed tools" >> "$bashrc"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$bashrc"
        print_info "~/.local/bin added to Bash PATH."
    fi
}

configure_bash_prompt() {
    local bashrc=~/.bashrc
    local omp_line="eval \"\$(oh-my-posh init bash --config ${OMP_THEME_PATH})\""

    if [[ -f "$bashrc" ]] && grep -qF "oh-my-posh init bash" "$bashrc"; then
        print_info "oh-my-posh already configured in Bash."
    else
        print_info "Configuring oh-my-posh prompt theme for Bash..."
        echo "" >> "$bashrc"
        echo "# oh-my-posh prompt theme" >> "$bashrc"
        echo "$omp_line" >> "$bashrc"
        print_info "oh-my-posh theme configured for Bash."
    fi
}

set_bash_ssl_cert_dir() {
    local bashrc=~/.bashrc

    if grep -qF 'SSL_CERT_DIR' "$bashrc"; then
        print_info "SSL_CERT_DIR already set in Bash."
    else
        print_info "Setting SSL_CERT_DIR in Bash..."
        echo "" >> "$bashrc"
        echo "# SSL certificate directory for .NET development" >> "$bashrc"
        echo 'export SSL_CERT_DIR="/etc/ssl/certs:$HOME/.aspnet/dev-certs/trust"' >> "$bashrc"
        print_info "SSL_CERT_DIR set in Bash."
    fi
}

set_bash_node_options() {
    local bashrc=~/.bashrc

    if [[ -z "$NODE_MAX_OLD_SPACE_SIZE" ]]; then
        return
    fi

    if grep -qF 'NODE_OPTIONS' "$bashrc"; then
        print_info "NODE_OPTIONS already set in Bash."
    else
        print_info "Setting NODE_OPTIONS in Bash..."
        echo "" >> "$bashrc"
        echo "# Node.js memory limit for memory-intensive builds" >> "$bashrc"
        echo "export NODE_OPTIONS=\"--max-old-space-size=$NODE_MAX_OLD_SPACE_SIZE\"" >> "$bashrc"
        print_info "NODE_OPTIONS set in Bash."
    fi
}

set_bash_nuget_packages() {
    local bashrc=~/.bashrc

    if [[ -z "${NUGET_PACKAGES:-}" ]]; then
        return
    fi

    if grep -qF 'NUGET_PACKAGES' "$bashrc"; then
        print_info "NUGET_PACKAGES already set in Bash."
    else
        print_info "Setting NUGET_PACKAGES in Bash..."
        echo "" >> "$bashrc"
        echo "# NuGet package cache location" >> "$bashrc"
        echo "export NUGET_PACKAGES=\"$NUGET_PACKAGES\"" >> "$bashrc"
        print_info "NUGET_PACKAGES set in Bash."
    fi
}

configure_bash() {
    print_section "Configuring Bash"

    add_local_bin_to_bash_path
    configure_bash_prompt
    set_bash_ssl_cert_dir
    set_bash_node_options
    set_bash_nuget_packages

    print_info "Bash configuration completed."
}
