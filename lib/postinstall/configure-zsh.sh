#!/bin/bash

# ============================================================================
# Zsh Configuration
# ============================================================================
# Configures Zsh shell with PATH, oh-my-posh prompt theme, fnm, pnpm,
# Aspire path, and SSL_CERT_DIR.
# Sets Zsh as the default shell.
# Sourced by bootstrap-mint.sh
# ============================================================================

add_aspire_to_zsh_path() {
    local zshrc=~/.zshrc
    local aspire_check='.aspire/bin'

    if [[ -f "$zshrc" ]] && grep -qF "$aspire_check" "$zshrc"; then
        print_info "Aspire CLI already added to Zsh PATH."
    else
        print_info "Adding Aspire CLI to Zsh PATH..."
        echo "" >> "$zshrc"
        echo "# Aspire CLI" >> "$zshrc"
        echo 'export PATH="$HOME/.aspire/bin:$PATH"' >> "$zshrc"
        print_info "Aspire CLI added to Zsh PATH."
    fi
}

add_fnm_to_zsh() {
    local zshrc=~/.zshrc
    local fnm_check='fnm env --use-on-cd --shell zsh'

    if [[ -f "$zshrc" ]] && grep -qF "$fnm_check" "$zshrc"; then
        print_info "fnm already configured in Zsh."
    else
        print_info "Configuring fnm for Zsh..."
        echo "" >> "$zshrc"
        echo "# fnm (Fast Node Manager)" >> "$zshrc"
        echo 'export PATH="$HOME/.local/share/fnm:$PATH"' >> "$zshrc"
        echo 'eval "$(fnm env --use-on-cd --shell zsh)"' >> "$zshrc"
        print_info "fnm configured for Zsh."
    fi
}

add_local_bin_to_zsh_path() {
    local zshrc=~/.zshrc
    local path_check='$HOME/.local/bin'

    if grep -qF "$path_check" "$zshrc"; then
        print_info "~/.local/bin already in Zsh PATH."
    else
        print_info "Adding ~/.local/bin to Zsh PATH..."
        echo "" >> "$zshrc"
        echo "# Add ~/.local/bin to PATH for user-installed tools" >> "$zshrc"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$zshrc"
        print_info "~/.local/bin added to Zsh PATH."
    fi
}

add_pnpm_to_zsh_path() {
    local zshrc=~/.zshrc
    local pnpm_check='PNPM_HOME'

    if [[ -f "$zshrc" ]] && grep -qF "$pnpm_check" "$zshrc"; then
        print_info "pnpm already added to Zsh PATH."
    else
        print_info "Adding pnpm to Zsh PATH..."
        echo "" >> "$zshrc"
        echo "# pnpm" >> "$zshrc"
        echo 'export PNPM_HOME="$HOME/.local/share/pnpm"' >> "$zshrc"
        echo 'export PATH="$PNPM_HOME:$PATH"' >> "$zshrc"
        print_info "pnpm added to Zsh PATH."
    fi
}

configure_zsh_prompt() {
    local zshrc=~/.zshrc
    local omp_line="eval \"\$(oh-my-posh init zsh --config ${OMP_THEME_PATH})\""

    if [[ -f "$zshrc" ]] && grep -qF "oh-my-posh init zsh" "$zshrc"; then
        print_info "oh-my-posh already configured in Zsh."
    else
        print_info "Configuring oh-my-posh prompt theme for Zsh..."
        echo "" >> "$zshrc"
        echo "# oh-my-posh prompt theme" >> "$zshrc"
        echo "$omp_line" >> "$zshrc"
        print_info "oh-my-posh theme configured for Zsh."
    fi
}

set_zsh_as_default_shell() {
    local zsh_path
    zsh_path=$(command -v zsh)

    # Add zsh to /etc/shells if not already present
    if grep -qF "$zsh_path" /etc/shells; then
        print_info "Zsh is already in /etc/shells."
    else
        print_info "Adding Zsh to list of valid shells..."
        echo "$zsh_path" | sudo tee -a /etc/shells > /dev/null
        print_info "Zsh added to list of valid shells."
    fi

    # Set zsh as default shell if not already
    if [[ "$SHELL" == "$zsh_path" ]]; then
        print_info "Zsh is already your default shell."
    else
        print_info "Setting Zsh as default shell..."
        chsh -s "$zsh_path"
        print_info "Zsh set as default shell. Log out and log back in for the change to take effect."
    fi
}

set_zsh_ssl_cert_dir() {
    local zshrc=~/.zshrc

    if [[ -f "$zshrc" ]] && grep -qF 'SSL_CERT_DIR' "$zshrc"; then
        print_info "SSL_CERT_DIR already set in Zsh."
    else
        print_info "Setting SSL_CERT_DIR in Zsh..."
        echo "" >> "$zshrc"
        echo "# SSL certificate directory for .NET development" >> "$zshrc"
        echo 'export SSL_CERT_DIR="/etc/ssl/certs:$HOME/.aspnet/dev-certs/trust"' >> "$zshrc"
        print_info "SSL_CERT_DIR set in Zsh."
    fi
}

configure_zsh() {
    print_section "Configuring Zsh"

    # Create .zshrc if it doesn't exist
    touch ~/.zshrc

    add_aspire_to_zsh_path
    add_fnm_to_zsh
    add_local_bin_to_zsh_path
    add_pnpm_to_zsh_path
    configure_zsh_prompt
    set_zsh_as_default_shell
    set_zsh_ssl_cert_dir

    print_info "Zsh configuration completed."
}
