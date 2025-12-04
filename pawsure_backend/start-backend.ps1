# PowerShell script to start the backend server
# This script sets the DATABASE_URL and starts the NestJS server

$env:DATABASE_URL = 'postgresql://postgres:Apple_3x2%3D6@[2406:da18:243:741f:5f4:55:22bf:6af2]:5432/postgres'

Write-Host "Starting backend server..." -ForegroundColor Green
Write-Host "DATABASE_URL is set" -ForegroundColor Yellow

# Build the project first
Write-Host "Building TypeScript..." -ForegroundColor Yellow
npm run build

# Start the server
Write-Host "Starting NestJS server..." -ForegroundColor Green
npm run start


