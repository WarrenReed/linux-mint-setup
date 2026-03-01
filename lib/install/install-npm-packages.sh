#!/bin/bash

# ============================================================================
# npm Package Installation
# ============================================================================
# Installs npm packages globally via npm.
# Sourced by bootstrap-mint.sh
# ============================================================================

install_npm_packages() {
    # Ensure fnm environment is loaded
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --shell bash)"

    # Install GitHub Copilot CLI
    print_section "Installing GitHub Copilot CLI"
    if command -v copilot &> /dev/null; then
        print_info "GitHub Copilot CLI is already installed."
    else
        print_info "Installing GitHub Copilot CLI via npm..."
        npm install -g @github/copilot
    fi

    # Install awesome-copilot plugin
    print_info "Installing awesome-copilot plugin..."
    if copilot plugin list 2>/dev/null | grep -q "awesome-copilot"; then
        print_info "awesome-copilot plugin is already installed."
    else
        copilot plugin install awesome-copilot@awesome-copilot
    fi
}
