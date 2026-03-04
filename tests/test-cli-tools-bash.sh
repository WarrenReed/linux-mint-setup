#!/bin/bash

# ============================================================================
# CLI Tools Test Script - Bash
# ============================================================================
# Tests availability of CLI tools in Bash environment
# Run from Bash: bash tests/test-cli-tools-bash.sh
# ============================================================================

set -euo pipefail

# Source bash profile
if [[ -f ~/.bashrc ]]; then
    source ~/.bashrc
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

test_tool() {
    local tool="$1"
    if command -v "$tool" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $tool"
        return 0
    else
        echo -e "${RED}✗${NC} $tool"
        return 1
    fi
}

echo -e "${CYAN}=================================${NC}"
echo -e "${CYAN}Bash CLI Tools Test${NC}"
echo -e "${CYAN}=================================${NC}"

echo ""
test_tool aspire
test_tool az
test_tool code
test_tool copilot
test_tool docker
test_tool dotnet
test_tool fnm
test_tool git
test_tool ng
test_tool node
test_tool npm
test_tool nswag
test_tool oh-my-posh
test_tool pnpm

echo ""
echo -e "${CYAN}=================================${NC}"
echo -e "${GREEN}Bash testing complete!${NC}"
echo -e "${CYAN}=================================${NC}"
