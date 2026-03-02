#!/bin/bash

# ============================================================================
# .NET Global Tools Installation
# ============================================================================
# Installs .NET global tools via dotnet CLI.
# Sourced by bootstrap-mint.sh
# ============================================================================

install_dotnet_tool() {
    local tool_id=$1
    local display_name=$2

    print_info "Installing/updating $display_name..."
    dotnet tool update -g "$tool_id"
    print_info "$display_name installed."
}

install_dotnet_tools() {
    print_section "Installing .NET Global Tools"

    # Ensure .NET tools are in PATH for this session
    export PATH="$PATH:$HOME/.dotnet/tools"

    install_dotnet_tool "NSwag.ConsoleCore" "NSwag CLI"
    install_dotnet_tool "Microsoft.Artifacts.CredentialProvider.NuGet.Tool" "Azure Artifacts Credential Provider"
    install_dotnet_tool "git-credential-manager" "Git Credential Manager"

    print_info ".NET global tools installation completed."
}
