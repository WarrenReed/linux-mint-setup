#!/bin/bash

# ============================================================================
# Fish Shell Configuration
# ============================================================================
# Configures Fish shell with oh-my-posh, fnm, and SSL certificates.
# Sourced by bootstrap-mint.sh
# ============================================================================

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
    if [[ "$SHELL" == "$fish_path" ]]; then
        print_info "Fish is already your default shell."
    else
        print_info "Setting fish as default shell..."
        chsh -s "$fish_path"
        print_info "Fish is now your default shell. Reboot for the change to take effect."
    fi

    # Ensure Fish config directory exists
    print_info "Creating Fish config directory..."
    mkdir -p ~/.config/fish

    # Configure oh-my-posh
    local fish_config=~/.config/fish/config.fish
    local omp_line="oh-my-posh init fish --config ${OMP_THEME_PATH} | source"

    if [[ -f "$fish_config" ]] && grep -qF "$omp_line" "$fish_config"; then
        print_info "oh-my-posh is already configured in Fish config."
    else
        print_info "Setting up oh-my-posh theme..."
        echo "# oh-my-posh prompt theme" >> "$fish_config"
        echo "$omp_line" >> "$fish_config"
        print_info "Fish is now configured to use oh-my-posh."
    fi

    # Configure Aspire CLI
    if [[ -f "$fish_config" ]] && grep -qF "fish_add_path \$HOME/.aspire/bin" "$fish_config"; then
        print_info "Aspire CLI is already configured in Fish config."
    else
        print_info "Setting up Aspire CLI path..."
        echo "" >> "$fish_config"
        echo "fish_add_path \$HOME/.aspire/bin" >> "$fish_config"
        print_info "Aspire CLI is now configured in Fish shell."
    fi

    # Configure fnm
    print_info "Configuring fnm in Fish shell..."
    mkdir -p ~/.config/fish/conf.d
    local fnm_config=~/.config/fish/conf.d/fnm.fish
    local fnm_line='fnm env --use-on-cd --shell fish | source'

    if [[ -f "$fnm_config" ]] && grep -qF "$fnm_line" "$fnm_config"; then
        print_info "fnm is already configured in Fish."
    else
        printf 'set -gx PATH "$HOME/.local/share/fnm" $PATH\nfnm env --use-on-cd --shell fish | source\n' > "$fnm_config"
        print_info "fnm is now configured in Fish shell."
    fi

    # Configure SSL_CERT_DIR for .NET development
    print_info "Configuring SSL_CERT_DIR in Fish shell..."
    local ssl_config=~/.config/fish/conf.d/ssl_cert_dir.fish
    local ssl_line='set -gx SSL_CERT_DIR /etc/ssl/certs:$HOME/.aspnet/dev-certs/trust'

    if [[ -f "$ssl_config" ]] && grep -qF "$ssl_line" "$ssl_config"; then
        print_info "SSL_CERT_DIR is already configured in Fish."
    else
        echo "$ssl_line" > "$ssl_config"
        print_info "SSL_CERT_DIR is now configured in Fish shell."
    fi

    # Trust .NET development certificates
    # Export SSL_CERT_DIR for the dotnet command in this bash session
    export SSL_CERT_DIR="/etc/ssl/certs:$HOME/.aspnet/dev-certs/trust"

    if dotnet dev-certs https --check --trust &> /dev/null; then
        print_info ".NET HTTPS development certificate is already trusted."
    else
        print_info "Trusting .NET HTTPS development certificates..."
        dotnet dev-certs https --trust
    fi
}
