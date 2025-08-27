# Hardware Acceleration Detection Script for Windows
# This script detects available GPUs and sets the appropriate environment variables in .env

# Function to set a value in the .env file
function Update-EnvVar {
    param (
        [string]$Key,
        [string]$Value
    )

    $envContent = Get-Content .env -Raw
    if ($envContent -match "(?m)^$Key=.*$") {
        $envContent = $envContent -replace "(?m)^$Key=.*$", "$Key=$Value"
    } else {
        $envContent += "`n$Key=$Value"
    }
    Set-Content -Path .env -Value $envContent
}

Write-Host "Detecting hardware acceleration capabilities..."

# Enable GPU by default
Update-EnvVar -Key "ENABLE_GPU" -Value "true"

# Default to none/0/false for all specific hardware
Update-EnvVar -Key "NVIDIA_GPU" -Value "none"
Update-EnvVar -Key "NVIDIA_VISIBLE_DEVICES" -Value "none"
Update-EnvVar -Key "NVIDIA_DRIVER_CAPABILITIES" -Value ""
Update-EnvVar -Key "AMD_GPU" -Value "0"
Update-EnvVar -Key "HSA_OVERRIDE_GFX_VERSION" -Value ""
Update-EnvVar -Key "INTEL_NPU" -Value "0"
Update-EnvVar -Key "APPLE_SILICON" -Value "0"
Update-EnvVar -Key "DYLD_LIBRARY_PATH" -Value ""
Update-EnvVar -Key "METAL_DEVICE_WRAPPER_TYPE" -Value ""

# Check for NVIDIA GPU
try {
    $nvidia = Get-WmiObject -Class Win32_VideoController | Where-Object { $_.Name -match "NVIDIA" }
    if ($nvidia) {
        Write-Host "NVIDIA GPU detected"
        Update-EnvVar -Key "NVIDIA_GPU" -Value "nvidia"
        Update-EnvVar -Key "NVIDIA_VISIBLE_DEVICES" -Value "all"
        Update-EnvVar -Key "NVIDIA_DRIVER_CAPABILITIES" -Value "compute,utility"
    }
} catch {
    Write-Host "Error detecting NVIDIA GPU: $_"
}

# Check for AMD GPU
try {
    $amd = Get-WmiObject -Class Win32_VideoController | Where-Object { $_.Name -match "AMD|Radeon|ATI" }
    if ($amd) {
        Write-Host "AMD GPU detected"
        Update-EnvVar -Key "AMD_GPU" -Value "1"
        Update-EnvVar -Key "HSA_OVERRIDE_GFX_VERSION" -Value "10.3.0"
    }
} catch {
    Write-Host "Error detecting AMD GPU: $_"
}

# Check for Intel NPU (basic check)
try {
    $intelNpu = Get-WmiObject -Class Win32_PnPEntity | Where-Object { $_.Name -match "Intel.*Neural" }
    if ($intelNpu) {
        Write-Host "Intel NPU detected"
        Update-EnvVar -Key "INTEL_NPU" -Value "1"
    }
} catch {
    Write-Host "Error detecting Intel NPU: $_"
}

Write-Host "Hardware detection complete. Updated .env file."
