# PowerShell-Skript für Hardware-Erkennung und automatischen Start
# Dieses Skript erkennt die verfügbaren Hardware-Beschleunigungsoptionen und startet den Stack mit der optimalen Konfiguration

# Funktion für Status-Meldungen
function Write-Status {
    param (
        [string]$Message,
        [string]$Color = "Cyan"
    )
    Write-Host "==> $Message" -ForegroundColor $Color
}

# Hardware-Erkennung
Write-Status "Erkenne Hardware-Beschleunigung..."

$Hardware = "cpu"
$OS = "Windows"

# Überprüfe für NVIDIA GPU
try {
    $nvidia = Get-WmiObject -Class Win32_VideoController | Where-Object { $_.Name -match "NVIDIA" }
    if ($nvidia) {
        Write-Status "NVIDIA GPU erkannt: $($nvidia.Name)" -Color "Green"
        $Hardware = "nvidia"
    }
}
catch {
    Write-Status "Fehler bei der Erkennung der NVIDIA GPU: $_" -Color "Yellow"
}

# Überprüfe für AMD GPU
if ($Hardware -eq "cpu") {
    try {
        $amd = Get-WmiObject -Class Win32_VideoController | Where-Object { $_.Name -match "AMD|Radeon|ATI" }
        if ($amd) {
            Write-Status "AMD GPU erkannt: $($amd.Name)" -Color "Green"
            $Hardware = "amd"
        }
    }
    catch {
        Write-Status "Fehler bei der Erkennung der AMD GPU: $_" -Color "Yellow"
    }
}

# Bestimme Speicherlimit basierend auf verfügbarem RAM
$totalMemGB = [math]::Round((Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
$ollamaMemGB = [math]::Round($totalMemGB / 2)

# Begrenzen zwischen 4GB und 16GB
if ($ollamaMemGB -lt 4) { $ollamaMemGB = 4 }
if ($ollamaMemGB -gt 16) { $ollamaMemGB = 16 }

# Aktualisiere .env Datei mit Speicherlimit
$envContent = Get-Content .env -Raw
if ($envContent -match "OLLAMA_MEMORY_LIMIT=.*G") {
    $envContent = $envContent -replace "OLLAMA_MEMORY_LIMIT=.*G", "OLLAMA_MEMORY_LIMIT=${ollamaMemGB}G"
}
else {
    $envContent += "`nOLLAMA_MEMORY_LIMIT=${ollamaMemGB}G"
}
Set-Content -Path .env -Value $envContent

Write-Status "=============================================="
Write-Status "Hardware-Erkennung: $Hardware"
Write-Status "Betriebssystem: $OS"
Write-Status "Ollama Speicherlimit: ${ollamaMemGB}G"
Write-Status "=============================================="

# Stoppe laufende Container
Write-Status "Stoppe laufende Container..."
docker compose down

# Starte mit passender Compose-Datei
if ($Hardware -eq "nvidia") {
    Write-Status "Starte mit NVIDIA GPU-Beschleunigung..." -Color "Green"
    try {
        docker compose -f docker-compose.yml -f docker-compose.nvidia.yml up -d --remove-orphans
    }
    catch {
        Write-Status "Ignoriere Validierungswarnungen" -Color "Yellow"
    }
}
elseif ($Hardware -eq "amd") {
    Write-Status "Starte mit AMD GPU-Beschleunigung..." -Color "Green"
    try {
        docker compose -f docker-compose.yml -f docker-compose.amd.yml up -d --remove-orphans
    }
    catch {
        Write-Status "Ignoriere Validierungswarnungen" -Color "Yellow"
    }
}
else {
    Write-Status "Starte ohne Hardware-Beschleunigung..." -Color "Yellow"
    try {
        docker compose up -d --remove-orphans
    }
    catch {
        Write-Status "Ignoriere Validierungswarnungen" -Color "Yellow"
    }
}

Write-Status "Start abgeschlossen!" -Color "Green"
Write-Status "Zugriff auf die Dienste:"
Write-Status "- n8n: http://localhost:5678" -Color "Cyan"
Write-Status "- Open WebUI: http://localhost:3000" -Color "Cyan"
Write-Status "- Ollama API: http://localhost:11434" -Color "Cyan"
