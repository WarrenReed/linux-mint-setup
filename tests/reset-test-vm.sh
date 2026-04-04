#!/bin/bash

# ============================================================================
# VM Test Reset Script
# ============================================================================
# This script resets the test environment by:
# 1. Deleting the linuxmint-baseline VM if it exists
# 2. Cloning linuxmint-22.3 to create a new linuxmint-baseline VM
# 3. Starting the linuxmint-baseline VM for testing
#
# Requires virsh (KVM/libvirt) to be installed.
# ============================================================================

set -euo pipefail

# Get script directory and source output utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/output.sh"

# VM names
readonly SOURCE_VM="linuxmint-22.3"
readonly BASELINE_VM="linuxmint-baseline"

# Functions

check_virsh() {
    if ! command -v virsh &> /dev/null; then
        print_error "virsh not found. Please install libvirt."
        exit 1
    fi
}

verify_source_vm_exists() {
    print_section "Verifying source VM exists"

    if ! virsh list --all --name | grep -q "^$SOURCE_VM$"; then
        print_error "Source VM '$SOURCE_VM' not found"
        exit 1
    fi

    print_info "Source VM '$SOURCE_VM' found"
}

delete_baseline_vm() {
    print_section "Checking for existing baseline VM"

    if virsh list --all --name | grep -q "^$BASELINE_VM$"; then
        print_info "Deleting existing VM '$BASELINE_VM'"

        # Destroy (stop) if running
        if virsh list --name | grep -q "^$BASELINE_VM$"; then
            virsh destroy "$BASELINE_VM" 2>/dev/null || true
            sleep 2
        fi

        # Undefine and remove storage
        virsh undefine "$BASELINE_VM" --remove-all-storage

        print_info "Deleted existing VM '$BASELINE_VM'"
    else
        print_info "No existing VM '$BASELINE_VM' found"
    fi
}

clone_vm() {
    print_section "Cloning VM '$SOURCE_VM' to '$BASELINE_VM'"

    virt-clone \
        --original "$SOURCE_VM" \
        --name "$BASELINE_VM" \
        --auto-clone

    print_info "Successfully cloned VM"
}

start_vm() {
    print_section "Starting VM '$BASELINE_VM'"

    virsh start "$BASELINE_VM"

    print_info "VM '$BASELINE_VM' started"
}

main() {
    print_section "VM Test Reset Script"

    check_virsh
    verify_source_vm_exists
    delete_baseline_vm
    clone_vm
    start_vm

    print_section "Test environment ready"
    print_info "You can now run setup-linux-mint.sh in the VM"
}

# Execute main function
main
