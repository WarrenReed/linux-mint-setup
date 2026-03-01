#!/bin/bash

# ============================================================================
# GRUB Bootloader Configuration
# ============================================================================
# Configures GRUB bootloader settings via Linux Mint's configuration file.
# Copies pre-configured file to /etc/default/grub.d/98_mintsysadm.cfg which is used by:
#   - Linux Mint System Settings UI
#   - GRUB bootloader (overrides main /etc/default/grub)
# Sourced by bootstrap-mint.sh
# ============================================================================

configure_grub() {
    print_section "Configuring GRUB Bootloader"

    local source_file="$SCRIPT_DIR/assets/etc/default/grub.d/98_mintsysadm.cfg"
    local target_file="/etc/default/grub.d/98_mintsysadm.cfg"

    # Check if source file exists
    if [[ ! -f "$source_file" ]]; then
        print_error "GRUB configuration file not found: $source_file"
        return 1
    fi

    # Ensure target directory exists
    sudo mkdir -p /etc/default/grub.d

    # Check if file needs to be copied (compare checksums if target exists)
    if [[ -f "$target_file" ]] && cmp -s "$source_file" "$target_file"; then
        print_info "GRUB bootloader already configured."
        return
    fi

    # Copy configuration file
    print_info "Installing GRUB configuration..."
    sudo cp "$source_file" "$target_file"

    # Update GRUB
    print_info "Updating GRUB configuration..."
    sudo update-grub > /dev/null 2>&1

    print_info "GRUB bootloader configured."
}
