# Auto-detect hardware acceleration and start the appropriate Docker Compose configuration

# Detect hardware
$HARDWARE = "cpu"
$GPU_DETECTED = $false

# Check for NVIDIA GPU
try {
    $nvidia = Get-WmiObject -Class Win32_VideoController | Where-Object { $_.Name -match "NVIDIA" }
    if ($nvidia) {
        Write-Host "NVIDIA GPU detected"
        $HARDWARE = "nvidia"
        $GPU_DETECTED = $true
    }
} catch {
    Write-Host "Error detecting NVIDIA GPU: $_"
}

# Check for AMD GPU if no NVIDIA GPU found
if (-not $GPU_DETECTED) {
    try {
        $amd = Get-WmiObject -Class Win32_VideoController | Where-Object { $_.Name -match "AMD|Radeon|ATI" }
        if ($amd) {
            Write-Host "AMD GPU detected"
            $HARDWARE = "amd"
            $GPU_DETECTED = $true
        }
    } catch {
        Write-Host "Error detecting AMD GPU: $_"
    }
}

# Get system memory
try {
    $memory = Get-WmiObject -Class Win32_ComputerSystem
    $TOTAL_MEM_GB = [math]::Round($memory.TotalPhysicalMemory / 1GB)
} catch {
    Write-Host "Error detecting system memory: $_"
    $TOTAL_MEM_GB = 8
}

# Use 50% of system memory, but not less than 4GB and not more than 16GB
$OLLAMA_MEM = [math]::Round($TOTAL_MEM_GB / 2)
if ($OLLAMA_MEM -lt 4) {
    $OLLAMA_MEM = 4
} elseif ($OLLAMA_MEM -gt 16) {
    $OLLAMA_MEM = 16
}

# Update .env file with memory limit
$envContent = Get-Content .env -Raw
$envContent = $envContent -replace "OLLAMA_MEMORY_LIMIT=.*", "OLLAMA_MEMORY_LIMIT=${OLLAMA_MEM}G"
Set-Content -Path .env -Value $envContent

Write-Host "=============================================="
Write-Host "Hardware detection: $HARDWARE"
Write-Host "Ollama memory limit: ${OLLAMA_MEM}G"
Write-Host "=============================================="

# Stop any running containers
Write-Host "Stopping any running containers..."
docker compose down

# Start with appropriate compose file
if ($HARDWARE -eq "nvidia") {
    Write-Host "Starting with NVIDIA GPU acceleration..."
    try {
        docker compose -f docker-compose.yml -f docker-compose.nvidia.yml up -d --remove-orphans
    } catch {
        Write-Host "Ignoring validation warnings"
    }
} elseif ($HARDWARE -eq "amd") {
    Write-Host "Starting with AMD GPU acceleration..."
    try {
        docker compose -f docker-compose.yml -f docker-compose.amd.yml up -d --remove-orphans
    } catch {
        Write-Host "Ignoring validation warnings"
    }
} else {
    Write-Host "Starting without hardware acceleration..."
    try {
        docker compose up -d --remove-orphans
    } catch {
        Write-Host "Ignoring validation warnings"
    }
}

Write-Host "Startup complete!"
