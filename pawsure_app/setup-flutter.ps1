# setup-flutter.ps1
Write-Host "`n🎯 PAWSURE FLUTTER SETUP" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Check Flutter
Write-Host "📋 Checking Flutter installation..." -ForegroundColor Yellow
flutter --version

# Clean
Write-Host "`n🧹 Cleaning Flutter build files..." -ForegroundColor Yellow
flutter clean

# Regenerate Windows platform files
Write-Host "`n🪟 Regenerating Windows platform files..." -ForegroundColor Cyan
flutter create --platforms=windows .

# Get dependencies
Write-Host "`n📦 Getting Flutter dependencies..." -ForegroundColor Cyan
flutter pub get

Write-Host "`n✅ Setup complete!" -ForegroundColor Green
Write-Host "`nRun 'flutter run -d windows' to start the app`n" -ForegroundColor White