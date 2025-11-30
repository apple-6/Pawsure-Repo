# PowerShell script to start the Flutter app
# This script runs the Flutter application

Write-Host "Starting Flutter app..." -ForegroundColor Green

# Get dependencies first
Write-Host "Getting Flutter dependencies..." -ForegroundColor Yellow
flutter pub get

# Run the app
Write-Host "Running Flutter app..." -ForegroundColor Green
flutter run

