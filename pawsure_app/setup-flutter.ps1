# setup-flutter.ps1 - Complete Multi-Platform Setup
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "`n==================================" -ForegroundColor Cyan
Write-Host "  PAWSURE FLUTTER SETUP" -ForegroundColor Cyan
Write-Host "  (All Platforms)" -ForegroundColor Cyan
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
# STEP 2: Deep Clean - Remove ALL Build Artifacts
# ========================================
Write-Host "Performing deep clean of all build files...`n" -ForegroundColor Yellow

# Standard Flutter clean
Write-Host "  - Running flutter clean..." -ForegroundColor Gray
flutter clean | Out-Null

# Delete build directories for ALL platforms
Write-Host "  - Deleting platform-specific build folders..." -ForegroundColor Gray
$foldersToDelete = @(
    "build",
    "android\build",
    "android\.gradle",
    "android\app\build",
    "ios\build",
    "ios\.symlinks",
    "ios\Pods",
    "windows\build",
    "linux\build",
    "macos\build",
    ".dart_tool"
)

foreach ($folder in $foldersToDelete) {
    if (Test-Path $folder) {
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $folder
        Write-Host "    * Deleted: $folder" -ForegroundColor DarkGray
    }
}

# Delete generated plugin files
Write-Host "  - Deleting generated plugin files..." -ForegroundColor Gray
$filesToDelete = @(
    ".flutter-plugins",
    ".flutter-plugins-dependencies",
    ".packages"
)

foreach ($file in $filesToDelete) {
    if (Test-Path $file) {
        Remove-Item -Force -ErrorAction SilentlyContinue $file
        Write-Host "    * Deleted: $file" -ForegroundColor DarkGray
    }
}

Write-Host "`n  Deep clean complete!`n" -ForegroundColor Green

# ========================================
# STEP 3: Regenerate Platform Files
# ========================================
Write-Host "Regenerating platform files for all targets..." -ForegroundColor Cyan

# Regenerate for multiple platforms
Write-Host "  - Regenerating Windows..." -ForegroundColor Gray
flutter create --platforms=windows . 2>&1 | Out-Null

Write-Host "  - Regenerating Web (Chrome)..." -ForegroundColor Gray
flutter create --platforms=web . 2>&1 | Out-Null

Write-Host "  - Regenerating Android..." -ForegroundColor Gray
flutter create --platforms=android . 2>&1 | Out-Null

Write-Host "  - Regenerating iOS..." -ForegroundColor Gray
flutter create --platforms=ios . 2>&1 | Out-Null

Write-Host "  - Regenerating Linux..." -ForegroundColor Gray
flutter create --platforms=linux . 2>&1 | Out-Null

Write-Host "  - Regenerating macOS..." -ForegroundColor Gray
flutter create --platforms=macos . 2>&1 | Out-Null

Write-Host "`n  Platform files regenerated!`n" -ForegroundColor Green

# ========================================
# STEP 4: Get Dependencies
# ========================================
Write-Host "Getting Flutter dependencies...`n" -ForegroundColor Cyan
flutter pub get

# ========================================
# STEP 5: Verify Setup
# ========================================
Write-Host "`nVerifying setup..." -ForegroundColor Yellow
$dartToolExists = Test-Path ".dart_tool"

if ($dartToolExists) {
    Write-Host "  * .dart_tool regenerated" -ForegroundColor Green
} else {
    Write-Host "  ! Warning: .dart_tool not found" -ForegroundColor Yellow
}

# ========================================
# FINAL STATUS
# ========================================
if ($LASTEXITCODE -eq 0) {
    Write-Host "`n==================================" -ForegroundColor Green
    Write-Host "  Setup Complete!" -ForegroundColor Green
    Write-Host "==================================`n" -ForegroundColor Green
    Write-Host "You can now run on any platform:" -ForegroundColor Cyan
    Write-Host "  - Windows:  flutter run -d windows" -ForegroundColor White
    Write-Host "  - Chrome:   flutter run -d chrome" -ForegroundColor White
    Write-Host "  - Android:  flutter run -d android" -ForegroundColor White
    Write-Host "  - Emulator: flutter run`n" -ForegroundColor White
} else {
    Write-Host "`nFlutter setup failed. Check errors above.`n" -ForegroundColor Red
    exit 1
}