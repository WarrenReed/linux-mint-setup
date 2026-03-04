#!/usr/bin/env fish

# ============================================================================
# CLI Tools Test Script - Fish
# ============================================================================
# Tests availability of CLI tools in Fish environment
# Run from Fish: fish tests/test-cli-tools-fish.fish
# ============================================================================

# Colors
set GREEN '\033[0;32m'
set RED '\033[0;31m'
set CYAN '\033[0;36m'
set NC '\033[0m'

function test_tool
    set tool $argv[1]
    if command -v $tool > /dev/null 2>&1
        echo -e "$GREEN✓$NC $tool"
        return 0
    else
        echo -e "$RED✗$NC $tool"
        return 1
    end
end

echo -e "$CYAN=================================$NC"
echo -e "$CYAN""Fish CLI Tools Test$NC"
echo -e "$CYAN=================================$NC"

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
echo -e "$CYAN=================================$NC"
echo -e "$GREEN""Fish testing complete!$NC"
echo -e "$CYAN=================================$NC"
