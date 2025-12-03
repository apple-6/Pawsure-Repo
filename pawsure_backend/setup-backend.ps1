# setup-backend.ps1 - Fixed version
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "`n==================================" -ForegroundColor Cyan
Write-Host "  PAWSURE BACKEND SETUP" -ForegroundColor Cyan
Write-Host "==================================`n" -ForegroundColor Cyan

# ========================================
# STEP 1: Check System Requirements
# ========================================
Write-Host "Checking system versions...`n" -ForegroundColor Yellow

$nodeVersion = (node -v 2>$null)
$npmVersion = (npm -v 2>$null)
$requiredNode = "v22.21.0"

if ($nodeVersion) {
    Write-Host "  Node.js:  $nodeVersion" -ForegroundColor White
    Write-Host "  Required: $requiredNode`n" -ForegroundColor Gray
} else {
    Write-Host "  ERROR: Node.js not found!" -ForegroundColor Red
    Write-Host "  Please install Node.js from: https://nodejs.org/`n" -ForegroundColor Yellow
    exit 1
}

$hasError = $false

if ($nodeVersion -ne $requiredNode) {
    Write-Host "Node.js version mismatch!" -ForegroundColor Red
    Write-Host "  You have: $nodeVersion" -ForegroundColor Red
    Write-Host "  Need:     $requiredNode`n" -ForegroundColor Red
    Write-Host "To fix:" -ForegroundColor Yellow
    Write-Host "  1. Download Node.js $requiredNode from: https://nodejs.org/" -ForegroundColor White
    Write-Host "  2. Install it" -ForegroundColor White
    Write-Host "  3. Restart terminal" -ForegroundColor White
    Write-Host "  4. Run this script again`n" -ForegroundColor White
    $hasError = $true
}

if ($hasError) {
    Write-Host "Please fix version mismatches above, then run this script again.`n" -ForegroundColor Red
    exit 1
}

Write-Host "System versions look good!`n" -ForegroundColor Green

# ========================================
# STEP 2: Clean Old Files
# ========================================
Write-Host "Cleaning old build files..." -ForegroundColor Yellow
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue dist
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue node_modules
Remove-Item -Force -ErrorAction SilentlyContinue package-lock.json
Write-Host "  Deleted: dist/, node_modules/, package-lock.json`n" -ForegroundColor Gray

# ========================================
# STEP 3: Install Dependencies
# ========================================
Write-Host "Installing npm packages...`n" -ForegroundColor Cyan

npm install --legacy-peer-deps

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n==================================" -ForegroundColor Green
    Write-Host "  Setup Complete!" -ForegroundColor Green
    Write-Host "==================================`n" -ForegroundColor Green
    Write-Host "To start the backend, run:" -ForegroundColor Cyan
    Write-Host "  npm run start:dev`n" -ForegroundColor White
} else {
    Write-Host "`nnpm install failed. Check errors above.`n" -ForegroundColor Red
    exit 1
}