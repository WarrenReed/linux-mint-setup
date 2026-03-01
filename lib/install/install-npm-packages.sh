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
    fi
}

install_copilot_cli() {
    print_section "Installing GitHub Copilot CLI"

    if command -v copilot &> /dev/null; then
        print_info "GitHub Copilot CLI is already installed."
    else
        print_info "Installing GitHub Copilot CLI via npm..."
        npm install -g @github/copilot
    fi
}

install_npm_packages() {
    # Ensure fnm environment is loaded
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --shell bash)"

    install_copilot_cli
    install_awesome_copilot_plugin
}
