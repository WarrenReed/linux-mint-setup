#!/bin/bash

# ============================================================================
# Output Utilities
# ============================================================================
# Shared output formatting functions and color constants.
# Sourced by bootstrap-mint.sh
# ============================================================================

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly CYAN='\033[0;36m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Print functions
print_section() {
    echo -e "\n${GREEN}==== $1 ====${NC}\n"
}

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}
