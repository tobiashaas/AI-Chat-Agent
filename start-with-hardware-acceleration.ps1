# PowerShell script for hardware detection and automatic start
# This script detects available hardware acceleration options and starts the stack with the optimal configuration

# Function for status messages
function Write-Status {
    param (
        [string]$Message,
        [string]$Color = "Cyan"
    )
    Write-Host "==> $Message" -ForegroundColor $Color
}

# Hardware-Erkennung
Write-Status "Detecting hardware acceleration..."

$Hardware = "cpu"
$OS = "Windows"

# Check for NVIDIA GPU
try {
    $nvidia = Get-WmiObject -Class Win32_VideoController | Where-Object { $_.Name -match "NVIDIA" }
    if ($nvidia) {
        Write-Status "NVIDIA GPU detected: $($nvidia.Name)" -Color "Green"
        $Hardware = "nvidia"
    }
}
catch {
    Write-Status "Error detecting NVIDIA GPU: $_" -Color "Yellow"
}

# Check for AMD GPU
if ($Hardware -eq "cpu") {
    try {
        $amd = Get-WmiObject -Class Win32_VideoController | Where-Object { $_.Name -match "AMD|Radeon|ATI" }
        if ($amd) {
            Write-Status "AMD GPU detected: $($amd.Name)" -Color "Green"
            $Hardware = "amd"
        }
    }
    catch {
        Write-Status "Error detecting AMD GPU: $_" -Color "Yellow"
    }
}

# Determine memory limit based on available RAM
$totalMemGB = [math]::Round((Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
$ollamaMemGB = [math]::Round($totalMemGB / 2)

# Limit between 4GB and 16GB
if ($ollamaMemGB -lt 4) { $ollamaMemGB = 4 }
if ($ollamaMemGB -gt 16) { $ollamaMemGB = 16 }

# Update .env file with memory limit
$envContent = Get-Content .env -Raw
if ($envContent -match "OLLAMA_MEMORY_LIMIT=.*G") {
    $envContent = $envContent -replace "OLLAMA_MEMORY_LIMIT=.*G", "OLLAMA_MEMORY_LIMIT=${ollamaMemGB}G"
}
else {
    $envContent += "`nOLLAMA_MEMORY_LIMIT=${ollamaMemGB}G"
}
Set-Content -Path .env -Value $envContent

Write-Status "=============================================="
Write-Status "Hardware Detection: $Hardware"
Write-Status "Operating System: $OS"
Write-Status "Ollama Memory Limit: ${ollamaMemGB}G"
Write-Status "=============================================="

# Stop running containers
Write-Status "Stopping running containers..."
docker compose down

# Start with appropriate compose file
if ($Hardware -eq "nvidia") {
    Write-Status "Starting with NVIDIA GPU acceleration..." -Color "Green"
    try {
        docker compose -f docker-compose.yml -f docker-compose.nvidia.yml up -d --remove-orphans
    }
    catch {
        Write-Status "Ignoring validation warnings" -Color "Yellow"
    }
}
elseif ($Hardware -eq "amd") {
    Write-Status "Starting with AMD GPU acceleration..." -Color "Green"
    try {
        docker compose -f docker-compose.yml -f docker-compose.amd.yml up -d --remove-orphans
    }
    catch {
        Write-Status "Ignoring validation warnings" -Color "Yellow"
    }
}
else {
    Write-Status "Starting without hardware acceleration..." -Color "Yellow"
    try {
        docker compose up -d --remove-orphans
    }
    catch {
        Write-Status "Ignoring validation warnings" -Color "Yellow"
    }
}

Write-Status "Startup completed!" -Color "Green"
Write-Status "Access to services:"
Write-Status "- n8n: http://localhost:5678" -Color "Cyan"
Write-Status "- Open WebUI: http://localhost:3000" -Color "Cyan"
Write-Status "- Ollama API: http://localhost:11434" -Color "Cyan"
