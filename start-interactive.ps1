# Interactive startup script for AI Chat Agent
# This script guides the user through starting the stack with custom options

# Function for section headers
function Write-Header {
    param (
        [string]$Title,
        [string]$Description
    )
    Write-Host "`n=== $Title ===" -ForegroundColor Cyan -BackgroundColor Black
    Write-Host "$Description`n" -ForegroundColor Gray
}

# Function for status messages
function Write-Status {
    param (
        [string]$Message,
        [string]$Color = "Cyan"
    )
    Write-Host "==> $Message" -ForegroundColor $Color
}

# Banner
Write-Host "🚀 AI Chat Agent - Interactive Startup" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "This script will help you start the AI Chat Agent with your preferences.`n" -ForegroundColor Gray

# Hardware detection
Write-Header "Hardware Detection" "Detecting your system configuration..."

$Hardware = "cpu"
$OS = "Windows"

# Detect NVIDIA GPU
try {
    $nvidia = Get-WmiObject -Class Win32_VideoController | Where-Object { $_.Name -match "NVIDIA" }
    if ($nvidia) {
        Write-Status "NVIDIA GPU detected: $($nvidia.Name)" -Color "Green"
        $DetectedHardware = "nvidia"
    }
}
catch {
    Write-Status "Error detecting NVIDIA GPU: $_" -Color "Yellow"
    $DetectedHardware = "cpu"
}

# Detect AMD GPU
if (-not $DetectedHardware -or $DetectedHardware -eq "cpu") {
    try {
        $amd = Get-WmiObject -Class Win32_VideoController | Where-Object { $_.Name -match "AMD|Radeon|ATI" }
        if ($amd) {
            Write-Status "AMD GPU detected: $($amd.Name)" -Color "Green"
            $DetectedHardware = "amd"
        }
        else {
            $DetectedHardware = "cpu"
            Write-Status "No supported GPU detected, using CPU mode" -Color "Yellow"
        }
    }
    catch {
        Write-Status "Error detecting AMD GPU: $_" -Color "Yellow"
        $DetectedHardware = "cpu"
    }
}

# Calculate memory recommendations
$totalMemGB = [math]::Round((Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
$ollamaMemGB = [math]::Round($totalMemGB / 2)

# Limit between 4GB and 16GB
if ($ollamaMemGB -lt 4) { $ollamaMemGB = 4 }
if ($ollamaMemGB -gt 16) { $ollamaMemGB = 16 }

# Display detected information
Write-Host "Detected System:" -ForegroundColor Cyan
Write-Host "  • Operating System: Windows" 
Write-Host "  • Hardware: $DetectedHardware"
Write-Host "  • Total Memory: $totalMemGB GB"
Write-Host "  • Recommended Ollama Memory: $ollamaMemGB GB`n"

# Ask for hardware preferences
Write-Header "Hardware Selection" "Choose acceleration options for AI models"

Write-Host "Detected hardware: $DetectedHardware" -ForegroundColor Yellow
Write-Host "Available options:"
Write-Host "  1. Auto-detect (recommended, currently: $DetectedHardware)"
Write-Host "  2. NVIDIA GPU - CUDA acceleration"
Write-Host "  3. AMD GPU - DirectML acceleration"
Write-Host "  4. CPU only - No hardware acceleration"

$hardwareChoice = Read-Host "Select hardware option [1-4] (default: 1)"
if (-not $hardwareChoice) { $hardwareChoice = "1" }

switch ($hardwareChoice) {
    "1" { 
        $Hardware = $DetectedHardware
        Write-Status "Using auto-detected hardware: $Hardware"
    }
    "2" { 
        $Hardware = "nvidia"
        Write-Status "Selected NVIDIA GPU acceleration"
    }
    "3" { 
        $Hardware = "amd"
        Write-Status "Selected AMD GPU acceleration"
    }
    "4" { 
        $Hardware = "cpu"
        Write-Status "Selected CPU-only mode (no acceleration)"
    }
    default { 
        $Hardware = $DetectedHardware
        Write-Status "Invalid choice, using auto-detected hardware: $Hardware" -Color "Yellow"
    }
}

# Ask for memory limit
$memoryInput = Read-Host "Enter Ollama memory limit in GB (recommended: $ollamaMemGB)"
if (-not $memoryInput) { $ollamaMemory = $ollamaMemGB } else { $ollamaMemory = $memoryInput }
Write-Host "Setting Ollama memory limit to: ${ollamaMemory}GB"

# Update .env file with memory limit
$envContent = Get-Content .env -Raw -ErrorAction SilentlyContinue
if ($envContent -match "OLLAMA_MEMORY_LIMIT=.*G") {
    $envContent = $envContent -replace "OLLAMA_MEMORY_LIMIT=.*G", "OLLAMA_MEMORY_LIMIT=${ollamaMemory}G"
}
else {
    $envContent += "`nOLLAMA_MEMORY_LIMIT=${ollamaMemory}G"
}
Set-Content -Path .env -Value $envContent

# Components selection
Write-Header "Component Selection" "Choose which components to start"

# Ask about Supabase
Write-Host "Do you want to start the Supabase UI?"
Write-Host "  The Supabase UI provides a visual interface to manage your database."
Write-Host "  • Studio interface at http://localhost:3001"
Write-Host "  • API endpoint at http://localhost:8000"
$startSupabase = Read-Host "Start Supabase UI? [y/N]"
if (-not $startSupabase) { $startSupabase = "n" }

# Ask if they want to install models
Write-Host "`nDo you want to install AI models after startup?"
Write-Host "  Common models include llama2, mistral, codellama, etc."
$installModels = Read-Host "Install AI models? [y/N]"
if (-not $installModels) { $installModels = "n" }

# Summary and confirmation
Write-Header "Summary" "Review your selections before starting"

Write-Host "  • Hardware: $Hardware"
Write-Host "  • Ollama Memory: ${ollamaMemory}GB"
Write-Host "  • Supabase UI: $(if ($startSupabase -eq 'y') { 'Yes' } else { 'No' })"
Write-Host "  • Install Models: $(if ($installModels -eq 'y') { 'Yes' } else { 'No' })`n"

$startConfirm = Read-Host "Start the stack with these settings? [Y/n]"
if (-not $startConfirm) { $startConfirm = "y" }

if ($startConfirm -ne "y" -and $startConfirm -ne "Y") {
    Write-Status "Startup cancelled." -Color "Red"
    exit 1
}

# Stop any running containers
Write-Status "Stopping any running containers..."
docker compose down

# Start with the appropriate configuration
Write-Header "Starting Services" "Initializing your AI stack"

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

# Start Supabase UI if requested
if ($startSupabase -eq 'y' -or $startSupabase -eq 'Y') {
    Write-Status "Starting Supabase UI..."
    # Wait a moment for the main stack to initialize
    Start-Sleep -Seconds 5
    try {
        docker compose -f docker-compose-supabase.yml up -d
    }
    catch {
        Write-Status "Failed to start Supabase UI: $_" -Color "Red"
    }
}

# Install models if requested
if ($installModels -eq 'y' -or $installModels -eq 'Y') {
    Write-Status "Installing AI models..."
    # Wait a moment for Ollama to initialize
    Start-Sleep -Seconds 5
    if (Test-Path -Path ".\install-models.ps1") {
        & .\install-models.ps1
    }
    else {
        Write-Status "Model installation script not found. You can manually install models later." -Color "Red"
    }
}

# Final summary
Write-Header "Startup Complete" "Your AI stack is now running"

Write-Host "📋 Access Information:" -ForegroundColor Cyan
Write-Host " - n8n: http://localhost:5678"
Write-Host " - Open WebUI: http://localhost:3000"
Write-Host " - Ollama API: http://localhost:11434"

if ($startSupabase -eq 'y' -or $startSupabase -eq 'Y') {
    Write-Host " - Supabase Studio: http://localhost:3001"
    Write-Host " - Supabase API: http://localhost:8000"
}

Write-Host "`nYou can stop all services with: .\stop-services.ps1" -ForegroundColor Gray
Write-Host "To view logs: docker compose logs -f" -ForegroundColor Gray
Write-Host "`nEnjoy your local AI stack! 🚀" -ForegroundColor Green
