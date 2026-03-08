#!/bin/bash

# ============================================================================
# Fish Shell Configuration
# ============================================================================
# Configures Fish shell with oh-my-posh, fnm, Aspire path, and SSL_CERT_DIR.
# Sourced by bootstrap-mint.sh
# ============================================================================

add_aspire_to_fish_path() {
    local aspire_config=~/.config/fish/conf.d/aspire.fish
    local path_line="fish_add_path \$HOME/.aspire/bin"

    if [[ -f "$aspire_config" ]] && grep -qF "$path_line" "$aspire_config"; then
        print_info "Aspire CLI already added to Fish PATH."
    else
        print_info "Adding Aspire CLI to Fish PATH..."
        echo "$path_line" > "$aspire_config"
        print_info "Aspire CLI added to Fish PATH."
    fi
}

add_fnm_to_fish_path() {
    local fnm_config=~/.config/fish/conf.d/fnm.fish
    local fnm_line='fnm env --use-on-cd --shell fish | source'

    if [[ -f "$fnm_config" ]] && grep -qF "$fnm_line" "$fnm_config"; then
        print_info "fnm already added to Fish PATH."
    else
        print_info "Adding fnm to Fish PATH..."
        printf 'set -gx PATH "$HOME/.local/share/fnm" $PATH\nfnm env --use-on-cd --shell fish | source\n' > "$fnm_config"
        print_info "fnm added to Fish PATH."
    fi
}

add_pnpm_to_fish_path() {
    local pnpm_config=~/.config/fish/conf.d/pnpm.fish
    local path_line='set -gx PNPM_HOME "$HOME/.local/share/pnpm"'
    local pnpm_path_line='fish_add_path $PNPM_HOME'

    if [[ -f "$pnpm_config" ]] && grep -qF "$path_line" "$pnpm_config"; then
        print_info "pnpm already added to Fish PATH."
    else
        print_info "Adding pnpm to Fish PATH..."
        printf '%s\n%s\n' "$path_line" "$pnpm_path_line" > "$pnpm_config"
        print_info "pnpm added to Fish PATH."
    fi
}

configure_fish_prompt() {
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

set_fish_ssl_cert_dir() {
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

    mkdir -p ~/.config/fish/conf.d

    add_aspire_to_fish_path
    add_fnm_to_fish_path
    add_pnpm_to_fish_path
    configure_fish_prompt
    set_fish_ssl_cert_dir

    print_info "Fish shell configuration completed."
}
