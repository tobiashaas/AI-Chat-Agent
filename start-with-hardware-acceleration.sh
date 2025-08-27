#!/bin/bash
# Hardware-Erkennung und automatischer Start mit optimaler Konfiguration
# Dieses Skript erkennt die verfügbare Hardware-Beschleunigung und startet den Stack mit passender Konfiguration

# Farbdefinitionen
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Funktion für Status-Meldungen
print_status() {
    echo -e "${CYAN}==> $1${NC}"
}

print_success() {
    echo -e "${GREEN}==> $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}==> $1${NC}"
}

# Detect OS
if [ "$(uname)" == "Darwin" ]; then
    OS="MacOS"
    if [ "$(uname -m)" == "arm64" ]; then
        print_success "Apple Silicon erkannt"
        HARDWARE="apple"
    else
        print_warning "Intel Mac erkannt"
        HARDWARE="cpu"
    fi
elif [ "$(uname)" == "Linux" ]; then
    OS="Linux"
    if command -v nvidia-smi &> /dev/null; then
        NVIDIA_INFO=$(nvidia-smi --query-gpu=name --format=csv,noheader)
        print_success "NVIDIA GPU erkannt: $NVIDIA_INFO"
        HARDWARE="nvidia"
    elif command -v lspci &> /dev/null && lspci | grep -i amd | grep -i vga &> /dev/null; then
        AMD_INFO=$(lspci | grep -i amd | grep -i vga | head -n1)
        print_success "AMD GPU erkannt: $AMD_INFO"
        HARDWARE="amd"
    else
        print_warning "Keine GPU erkannt unter Linux"
        HARDWARE="cpu"
    fi
else
    OS="Unknown"
    HARDWARE="cpu"
    print_warning "Unbekanntes Betriebssystem, verwende CPU-Modus"
fi

# Bestimme Speicherlimit basierend auf verfügbarem RAM
if [ "$(uname)" == "Darwin" ]; then
    TOTAL_MEM_KB=$(sysctl hw.memsize | awk '{print $2}')
    TOTAL_MEM_GB=$((TOTAL_MEM_KB / 1024 / 1024 / 1024))
elif [ "$(uname)" == "Linux" ]; then
    TOTAL_MEM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    TOTAL_MEM_GB=$((TOTAL_MEM_KB / 1024 / 1024))
else
    TOTAL_MEM_GB=8
fi

# Verwende 50% des Systemspeichers, aber nicht weniger als 4GB und nicht mehr als 16GB
OLLAMA_MEM=$((TOTAL_MEM_GB / 2))
if [ $OLLAMA_MEM -lt 4 ]; then
    OLLAMA_MEM=4
elif [ $OLLAMA_MEM -gt 16 ]; then
    OLLAMA_MEM=16
fi

# Aktualisiere .env Datei mit Speicherlimit
sed -i.bak "s/OLLAMA_MEMORY_LIMIT=.*/OLLAMA_MEMORY_LIMIT=${OLLAMA_MEM}G/" .env 2>/dev/null || \
echo "OLLAMA_MEMORY_LIMIT=${OLLAMA_MEM}G" >> .env

echo ""
print_status "=============================================="
print_status "Hardware-Erkennung: $HARDWARE"
print_status "Betriebssystem: $OS"
print_status "Ollama Speicherlimit: ${OLLAMA_MEM}G"
print_status "=============================================="
echo ""

# Stoppe laufende Container
print_status "Stoppe laufende Container..."
docker compose down

# Starte mit passender Compose-Datei
if [ "$HARDWARE" == "nvidia" ]; then
    print_success "Starte mit NVIDIA GPU-Beschleunigung..."
    docker compose -f docker-compose.yml -f docker-compose.nvidia.yml up -d --remove-orphans || echo "Ignoriere Validierungswarnungen"
elif [ "$HARDWARE" == "amd" ]; then
    print_success "Starte mit AMD GPU-Beschleunigung..."
    docker compose -f docker-compose.yml -f docker-compose.amd.yml up -d --remove-orphans || echo "Ignoriere Validierungswarnungen"
elif [ "$HARDWARE" == "apple" ]; then
    print_success "Starte mit Apple Silicon-Beschleunigung..."
    docker compose -f docker-compose.yml -f docker-compose.apple.yml up -d --remove-orphans || echo "Ignoriere Validierungswarnungen"
else
    print_warning "Starte ohne Hardware-Beschleunigung..."
    docker compose up -d --remove-orphans || echo "Ignoriere Validierungswarnungen"
fi

echo ""
print_success "Start abgeschlossen!"
print_status "Zugriff auf die Dienste:"
echo -e "${CYAN}- n8n: http://localhost:5678${NC}"
echo -e "${CYAN}- Open WebUI: http://localhost:3000${NC}"
echo -e "${CYAN}- Ollama API: http://localhost:11434${NC}"
echo ""
