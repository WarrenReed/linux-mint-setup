#!/bin/bash

# ============================================================================
# Bash Configuration
# ============================================================================
# Configures Bash shell with oh-my-posh prompt theme.
# Sourced by bootstrap-mint.sh
# ============================================================================

configure_bash() {
    print_section "Configuring Bash"

    local bashrc=~/.bashrc
    local omp_line="eval \"\$(oh-my-posh init bash --config ${OMP_THEME_PATH})\""

    if [[ -f "$bashrc" ]] && grep -qF "oh-my-posh init bash" "$bashrc"; then
        print_info "oh-my-posh is already configured in .bashrc."
    else
        print_info "Setting up oh-my-posh theme..."
        echo "" >> "$bashrc"
        echo "# oh-my-posh prompt theme" >> "$bashrc"
        echo "$omp_line" >> "$bashrc"
        print_info "Bash is now configured to use oh-my-posh."
    fi
}
