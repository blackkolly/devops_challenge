# PowerShell script for local development using Docker Compose
param(
    [switch]$Build,
    [switch]$Down,
    [switch]$Logs
)

$ErrorActionPreference = "Stop"

Write-Host "=== Flask E-commerce Local Development (Docker Compose) ===" -ForegroundColor Green

if ($Down) {
    Write-Host "Stopping and removing containers..." -ForegroundColor Yellow
    docker-compose -f docker-compose-local.yml down -v
    Write-Host "Stopped!" -ForegroundColor Green
    exit 0
}

if ($Build) {
    Write-Host "Building and starting with forced rebuild..." -ForegroundColor Blue
    docker-compose -f docker-compose-local.yml up --build -d
} else {
    Write-Host "Starting containers..." -ForegroundColor Blue
    docker-compose -f docker-compose-local.yml up -d
}

if ($Logs) {
    Write-Host "Showing logs..." -ForegroundColor Blue
    docker-compose -f docker-compose-local.yml logs -f
} else {
    Write-Host ""
    Write-Host "=== Application Started Successfully! ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "Access the application at: http://localhost:8080" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Useful commands:" -ForegroundColor Cyan
    Write-Host "  docker-compose -f docker-compose-local.yml logs -f" -ForegroundColor Yellow
    Write-Host "  docker-compose -f docker-compose-local.yml ps" -ForegroundColor Yellow
    Write-Host "  .\local-dev.ps1 -Down" -ForegroundColor Yellow
    Write-Host ""
}
