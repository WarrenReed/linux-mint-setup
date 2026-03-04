#!/usr/bin/env pwsh

# ============================================================================
# CLI Tools Test Script - PowerShell
# ============================================================================
# Tests availability of CLI tools in PowerShell environment
# Run from PowerShell: pwsh tests/test-cli-tools-powershell.ps1
# ============================================================================

function Test-Tool {
  param($tool)
  if (Get-Command $tool -ErrorAction SilentlyContinue) {
    Write-Host "✓ $tool" -ForegroundColor Green
    return $true
  }
  else {
    Write-Host "✗ $tool" -ForegroundColor Red
    return $false
  }
}

Write-Host "=================================" -ForegroundColor Cyan
Write-Host "PowerShell CLI Tools Test" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

Write-Host ""
Test-Tool aspire
Test-Tool az
Test-Tool code
Test-Tool copilot
Test-Tool docker
Test-Tool dotnet
Test-Tool fnm
Test-Tool git
Test-Tool ng
Test-Tool node
Test-Tool npm
Test-Tool nswag
Test-Tool oh-my-posh
Test-Tool pnpm

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "PowerShell testing complete!" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Cyan
