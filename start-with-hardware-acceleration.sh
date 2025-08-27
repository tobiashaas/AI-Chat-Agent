#!/bin/bash
# Hardware detection and automatic start with optimal configuration
# This script detects available hardware acceleration and starts the stack with appropriate configuration

# Color definitions
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function for status messages
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
        print_success "Apple Silicon detected"
        HARDWARE="apple"
    else
        print_warning "Intel Mac detected"
        HARDWARE="cpu"
    fi
elif [ "$(uname)" == "Linux" ]; then
    OS="Linux"
    if command -v nvidia-smi &> /dev/null; then
        NVIDIA_INFO=$(nvidia-smi --query-gpu=name --format=csv,noheader)
        print_success "NVIDIA GPU detected: $NVIDIA_INFO"
        HARDWARE="nvidia"
    elif command -v lspci &> /dev/null && lspci | grep -i amd | grep -i vga &> /dev/null; then
        AMD_INFO=$(lspci | grep -i amd | grep -i vga | head -n1)
        print_success "AMD GPU detected: $AMD_INFO"
        HARDWARE="amd"
    else
        print_warning "No GPU detected on Linux"
        HARDWARE="cpu"
    fi
else
    OS="Unknown"
    HARDWARE="cpu"
    print_warning "Unknown operating system, using CPU mode"
fi

# Determine memory limit based on available RAM
if [ "$(uname)" == "Darwin" ]; then
    TOTAL_MEM_KB=$(sysctl hw.memsize | awk '{print $2}')
    TOTAL_MEM_GB=$((TOTAL_MEM_KB / 1024 / 1024 / 1024))
elif [ "$(uname)" == "Linux" ]; then
    TOTAL_MEM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    TOTAL_MEM_GB=$((TOTAL_MEM_KB / 1024 / 1024))
else
    TOTAL_MEM_GB=8
fi

# Use 50% of system memory, but not less than 4GB and not more than 16GB
OLLAMA_MEM=$((TOTAL_MEM_GB / 2))
if [ $OLLAMA_MEM -lt 4 ]; then
    OLLAMA_MEM=4
elif [ $OLLAMA_MEM -gt 16 ]; then
    OLLAMA_MEM=16
fi

# Update .env file with memory limit
sed -i.bak "s/OLLAMA_MEMORY_LIMIT=.*/OLLAMA_MEMORY_LIMIT=${OLLAMA_MEM}G/" .env 2>/dev/null || \
echo "OLLAMA_MEMORY_LIMIT=${OLLAMA_MEM}G" >> .env

echo ""
print_status "=============================================="
print_status "Hardware Detection: $HARDWARE"
print_status "Operating System: $OS"
print_status "Ollama Memory Limit: ${OLLAMA_MEM}G"
print_status "=============================================="
echo ""

# Stop running containers
print_status "Stopping running containers..."
docker compose down

# Start with appropriate compose file
if [ "$HARDWARE" == "nvidia" ]; then
    print_success "Starting with NVIDIA GPU acceleration..."
    docker compose -f docker-compose.yml -f docker-compose.nvidia.yml up -d --remove-orphans || echo "Ignoriere Validierungswarnungen"
elif [ "$HARDWARE" == "amd" ]; then
    print_success "Starting with AMD GPU acceleration..."
    docker compose -f docker-compose.yml -f docker-compose.amd.yml up -d --remove-orphans || echo "Ignoriere Validierungswarnungen"
elif [ "$HARDWARE" == "apple" ]; then
    print_success "Starting with Apple Silicon acceleration..."
    docker compose -f docker-compose.yml -f docker-compose.apple.yml up -d --remove-orphans || echo "Ignoriere Validierungswarnungen"
else
    print_warning "Starting without hardware acceleration..."
    docker compose up -d --remove-orphans || echo "Ignoriere Validierungswarnungen"
fi

echo ""
print_success "Startup completed!"
print_status "Access to services:"
echo -e "${CYAN}- n8n: http://localhost:5678${NC}"
echo -e "${CYAN}- Open WebUI: http://localhost:3000${NC}"
echo -e "${CYAN}- Ollama API: http://localhost:11434${NC}"
echo ""
