#!/usr/bin/env zsh

# ============================================================================
# CLI Tools Test Script - Zsh
# ============================================================================
# Tests availability of CLI tools in Zsh environment
# Run from Zsh: zsh tests/test-cli-tools-zsh.sh
# ============================================================================

# Source zsh profile
if [[ -f ~/.zshrc ]]; then
    source ~/.zshrc
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
echo -e "${CYAN}Zsh CLI Tools Test${NC}"
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
echo -e "${GREEN}Zsh testing complete!${NC}"
echo -e "${CYAN}=================================${NC}"
