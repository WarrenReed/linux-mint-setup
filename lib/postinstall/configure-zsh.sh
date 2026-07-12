#!/bin/bash

# ============================================================================
# Zsh Configuration
# ============================================================================
# Configures Zsh shell with Oh My Zsh, PATH, oh-my-posh prompt theme, fnm,
# pnpm, Aspire path, SSL_CERT_DIR, optionally NODE_OPTIONS, optionally
# NUGET_PACKAGES, and zsh-syntax-highlighting.
# Sets Zsh as the default shell.
# Sourced by setup-linux-mint.sh
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
        echo 'export PATH="$PNPM_HOME/bin:$PATH"' >> "$zshrc"
        print_info "pnpm added to Zsh PATH."
    fi
}

configure_oh_my_zsh_plugins() {
    local zshrc=~/.zshrc
    # Plugins relevant to installed tools:
    #   azure   - Azure CLI completions
    #   colored-man-pages - adds color syntax to man pages
    #   command-not-found - suggests apt package to install for unknown commands
    #   debian  - apt/apt-get aliases (Linux Mint is Debian/Ubuntu based)
    #   docker  - docker completions
    #   docker-compose - aliases for docker compose (dco, dcup, dcdn, etc.)
    #   dotnet  - .NET SDK completions
    #   fnm     - fnm tab completions (PATH/shell init handled by add_fnm_to_zsh)
    #   git     - git aliases and completions
    #   history-substring-search - Fish-like up/down arrow searches history by prefix
    #   ng      - Angular CLI completions
    #   node    - open Node.js docs from CLI
    #   npm     - npm completions
    #   sudo    - press ESC twice to prepend sudo to the current command
    #   systemd - systemctl aliases
    #   vscode  - VS Code aliases (vsc, vsca, vscr)
    local plugins_line='plugins=(azure colored-man-pages command-not-found debian docker docker-compose dotnet fnm git history-substring-search ng node npm sudo systemd vscode)'

    if [[ -f "$zshrc" ]] && grep -qF "$plugins_line" "$zshrc"; then
        print_info "Oh My Zsh plugins already configured."
    else
        print_info "Configuring Oh My Zsh plugins..."
        sed -i 's/^plugins=(.*/'"$plugins_line"'/' "$zshrc"
        print_info "Oh My Zsh plugins configured."
    fi
}

disable_oh_my_zsh_default_theme() {
    local zshrc=~/.zshrc

    # Oh My Zsh sets ZSH_THEME in .zshrc; disable it since oh-my-posh manages the prompt
    if [[ -f "$zshrc" ]] && grep -q 'ZSH_THEME=""' "$zshrc"; then
        print_info "Oh My Zsh default theme already disabled."
    else
        print_info "Disabling Oh My Zsh default theme (oh-my-posh manages the prompt)..."
        sed -i 's/^ZSH_THEME=.*/ZSH_THEME=""/' "$zshrc"
        print_info "Oh My Zsh default theme disabled."
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
set_zsh_node_options() {
    local zshrc=~/.zshrc

    if [[ -z "$NODE_MAX_OLD_SPACE_SIZE" ]]; then
        return
    fi

    if grep -qF 'NODE_OPTIONS' "$zshrc"; then
        print_info "NODE_OPTIONS already set in Zsh."
    else
        print_info "Setting NODE_OPTIONS in Zsh..."
        echo "" >> "$zshrc"
        echo "# Node.js memory limit for memory-intensive builds" >> "$zshrc"
        echo "export NODE_OPTIONS=\"--max-old-space-size=$NODE_MAX_OLD_SPACE_SIZE\"" >> "$zshrc"
        print_info "NODE_OPTIONS set in Zsh."
    fi
}
set_zsh_nuget_packages() {
    local zshrc=~/.zshrc

    if [[ -z "${NUGET_PACKAGES:-}" ]]; then
        return
    fi

    if [[ -f "$zshrc" ]] && grep -qF 'NUGET_PACKAGES' "$zshrc"; then
        print_info "NUGET_PACKAGES already set in Zsh."
    else
        print_info "Setting NUGET_PACKAGES in Zsh..."
        echo "" >> "$zshrc"
        echo "# NuGet package cache location" >> "$zshrc"
        echo "export NUGET_PACKAGES=\"$NUGET_PACKAGES\"" >> "$zshrc"
        print_info "NUGET_PACKAGES set in Zsh."
    fi
}

configure_zsh_syntax_highlighting() {
    local zshrc=~/.zshrc
    local highlight_script='/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'
    local source_line="source ${highlight_script}"

    # zsh-syntax-highlighting MUST be sourced last in .zshrc
    if [[ -f "$zshrc" ]] && grep -qF "$source_line" "$zshrc"; then
        print_info "zsh-syntax-highlighting already configured."
    elif [[ -f "$highlight_script" ]]; then
        print_info "Configuring zsh-syntax-highlighting..."
        echo "" >> "$zshrc"
        echo "# Syntax highlighting (must be sourced last)" >> "$zshrc"
        echo "$source_line" >> "$zshrc"
        print_info "zsh-syntax-highlighting configured."
    else
        print_info "zsh-syntax-highlighting script not found, skipping."
    fi
}

configure_zsh() {
    print_section "Configuring Zsh"

    # Create .zshrc if it doesn't exist (Oh My Zsh installer may have already created it)
    touch ~/.zshrc

    disable_oh_my_zsh_default_theme
    configure_oh_my_zsh_plugins
    add_aspire_to_zsh_path
    add_fnm_to_zsh
    add_local_bin_to_zsh_path
    add_pnpm_to_zsh_path
    configure_zsh_prompt
    set_zsh_as_default_shell
    set_zsh_ssl_cert_dir
    set_zsh_node_options
    set_zsh_nuget_packages
    configure_zsh_syntax_highlighting

    print_info "Zsh configuration completed."
}
