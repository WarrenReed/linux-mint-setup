#!/bin/bash

# ============================================================================
# npm Package Installation
# ============================================================================
# Installs npm packages globally via npm.
# Sourced by bootstrap-mint.sh
# ============================================================================

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
        print_info "Installing GitHub Copilot CLI via npm..."
        npm install -g @github/copilot
        print_info "GitHub Copilot CLI installed."
    fi
}

install_npm_packages() {
    print_section "Installing npm Packages"

    # Ensure fnm environment is loaded
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --shell bash)"

    install_copilot_cli
    install_awesome_copilot_plugin

    print_info "npm package installation completed."
}
