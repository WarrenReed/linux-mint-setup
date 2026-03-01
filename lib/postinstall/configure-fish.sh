#!/bin/bash

# ============================================================================
# Fish Shell Configuration
# ============================================================================
# Configures Fish shell with oh-my-posh, fnm, Aspire path, and SSL_CERT_DIR.
# Sets Fish as the default shell.
# Sourced by bootstrap-mint.sh
# ============================================================================

add_aspire_to_fish_path() {
    mkdir -p ~/.config/fish/conf.d
    local aspire_config=~/.config/fish/conf.d/aspire.fish
    local path_line="fish_add_path \$HOME/.aspire/bin"

    if [[ -f "$aspire_config" ]] && grep -qF "$path_line" "$aspire_config"; then
        print_info "Aspire CLI path already configured in Fish."
    else
        print_info "Adding Aspire CLI to Fish PATH..."
        echo "$path_line" > "$aspire_config"
        print_info "Aspire CLI path configured in Fish."
    fi
}

add_fnm_to_fish_path() {
    mkdir -p ~/.config/fish/conf.d
    local fnm_config=~/.config/fish/conf.d/fnm.fish
    local fnm_line='fnm env --use-on-cd --shell fish | source'

    if [[ -f "$fnm_config" ]] && grep -qF "$fnm_line" "$fnm_config"; then
        print_info "fnm already configured in Fish."
    else
        print_info "Adding fnm to Fish PATH..."
        printf 'set -gx PATH "$HOME/.local/share/fnm" $PATH\nfnm env --use-on-cd --shell fish | source\n' > "$fnm_config"
        print_info "fnm configured in Fish."
    fi
}

configure_fish_prompt() {
    mkdir -p ~/.config/fish/conf.d
    local omp_config=~/.config/fish/conf.d/oh-my-posh.fish
    local omp_line="oh-my-posh init fish --config ${OMP_THEME_PATH} | source"

    if [[ -f "$omp_config" ]] && grep -qF "$omp_line" "$omp_config"; then
        print_info "oh-my-posh already configured in Fish."
    else
        print_info "Configuring oh-my-posh prompt theme for Fish..."
        echo "$omp_line" > "$omp_config"
        print_info "oh-my-posh theme configured for Fish."
    fi
}

set_fish_as_default_shell() {
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
}

set_fish_ssl_cert_dir() {
    mkdir -p ~/.config/fish/conf.d
    local ssl_config=~/.config/fish/conf.d/ssl_cert_dir.fish
    local ssl_line='set -gx SSL_CERT_DIR /etc/ssl/certs:$HOME/.aspnet/dev-certs/trust'

    if [[ -f "$ssl_config" ]] && grep -qF "$ssl_line" "$ssl_config"; then
        print_info "SSL_CERT_DIR already set in Fish."
    else
        print_info "Setting SSL_CERT_DIR in Fish..."
        echo "$ssl_line" > "$ssl_config"
        print_info "SSL_CERT_DIR set in Fish."
    fi
}

configure_fish() {
    print_section "Configuring Fish Shell"

    add_aspire_to_fish_path
    add_fnm_to_fish_path
    configure_fish_prompt
    set_fish_as_default_shell
    set_fish_ssl_cert_dir
}
