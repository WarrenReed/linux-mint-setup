#!/bin/bash

# ============================================================================
# pnpm Package Installation
# ============================================================================
# Enables pnpm via corepack, configures pnpm store, and installs pnpm packages.
# Sourced by setup-linux-mint.sh
# ============================================================================

install_angular_cli() {
    if command -v ng &> /dev/null; then
        print_info "Angular CLI is already installed."
    else
        print_info "Installing Angular CLI..."
        pnpm add -g @angular/cli
        print_info "Angular CLI installed."
    fi
}

install_awesome_copilot_plugin() {
    if copilot plugin list 2>/dev/null | grep -q "awesome-copilot"; then
        print_info "awesome-copilot plugin is already installed."
    else
        print_info "Installing awesome-copilot plugin..."
        copilot plugin install awesome-copilot@awesome-copilot
        print_info "awesome-copilot plugin installed."
    fi
}

install_copilot_cli() {
    if command -v copilot &> /dev/null; then
        print_info "GitHub Copilot CLI is already installed."
    else
        print_info "Installing GitHub Copilot CLI..."
        pnpm add -g @github/copilot
        print_info "GitHub Copilot CLI installed."
    fi
}

install_pnpm_packages() {
    print_section "Installing pnpm Packages"

    # Ensure fnm environment is loaded
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --shell bash)"

    # Enable corepack for pnpm (comes with Node.js)
    if ! command -v pnpm &> /dev/null; then
        print_info "Enabling pnpm via corepack..."
        corepack enable
        corepack prepare pnpm@latest --activate
        print_info "pnpm enabled."
    fi

    # Configure pnpm store if PACKAGE_CACHE_DIR is set
    if [[ -n "$PACKAGE_CACHE_DIR" ]]; then
        local pnpm_store_dir="$PACKAGE_CACHE_DIR/pnpm"
        print_info "Configuring pnpm store location: $pnpm_store_dir"
        mkdir -p "$pnpm_store_dir"
        pnpm config set store-dir "$pnpm_store_dir" --global
        print_info "pnpm store configured."
    fi

    # Set up pnpm global bin directory if not already configured
    if [ ! -d "$HOME/.local/share/pnpm" ]; then
        print_info "Configuring pnpm global bin directory..."
        pnpm setup
        print_info "pnpm global bin directory configured."
    fi

    # Export PNPM_HOME for current session
    export PNPM_HOME="$HOME/.local/share/pnpm"
    export PATH="$PNPM_HOME:$PATH"

    install_angular_cli
    install_copilot_cli
    install_awesome_copilot_plugin

    print_info "pnpm package installation completed."
}
