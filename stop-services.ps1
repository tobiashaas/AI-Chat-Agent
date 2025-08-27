# PowerShell script to stop all services
# This script stops all running containers in the AI-Chat-Agent stack

# Function for status messages
function Write-Status {
    param (
        [string]$Message,
        [string]$Color = "Cyan"
    )
    Write-Host "==> $Message" -ForegroundColor $Color
}

Write-Status "Stopping all AI-Chat-Agent services..."

# Stop running containers
docker compose down

Write-Status "All services stopped successfully!" -Color "Green"
Write-Status "To start services again, use:"
Write-Host "  .\start-with-hardware-acceleration.ps1" -ForegroundColor Cyan
Write-Host ""
