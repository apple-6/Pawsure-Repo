# setup-flutter.ps1 - Fixed version
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "`n==================================" -ForegroundColor Cyan
Write-Host "  PAWSURE FLUTTER SETUP" -ForegroundColor Cyan
Write-Host "==================================`n" -ForegroundColor Cyan

# ========================================
# STEP 1: Check Flutter Installation
# ========================================
Write-Host "Checking Flutter installation...`n" -ForegroundColor Yellow

$flutterVersion = (flutter --version 2>$null)
if (-not $flutterVersion) {
    Write-Host "ERROR: Flutter not found!" -ForegroundColor Red
    Write-Host "Please install Flutter from: https://flutter.dev/`n" -ForegroundColor Yellow
    exit 1
}

Write-Host $flutterVersion -ForegroundColor Gray
Write-Host ""

# ========================================
# STEP 2: Clean Old Build Files
# ========================================
Write-Host "Cleaning Flutter build files..." -ForegroundColor Yellow
flutter clean
Write-Host ""

# ========================================
# STEP 3: Regenerate Windows Platform Files
# ========================================
Write-Host "Regenerating Windows platform files..." -ForegroundColor Cyan
flutter create --platforms=windows .
Write-Host ""

# ========================================
# STEP 4: Get Dependencies
# ========================================
Write-Host "Getting Flutter dependencies...`n" -ForegroundColor Cyan
flutter pub get

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n==================================" -ForegroundColor Green
    Write-Host "  Setup Complete!" -ForegroundColor Green
    Write-Host "==================================`n" -ForegroundColor Green
    Write-Host "To start the app, run:" -ForegroundColor Cyan
    Write-Host "  flutter run -d windows`n" -ForegroundColor White
} else {
    Write-Host "`nFlutter setup failed. Check errors above.`n" -ForegroundColor Red
    exit 1
}