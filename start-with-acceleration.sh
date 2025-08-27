#!/bin/bash
# Auto-detect hardware acceleration and start the appropriate Docker Compose configuration

# Detect OS
if [ "$(uname)" == "Darwin" ]; then
    OS="MacOS"
    if [ "$(uname -m)" == "arm64" ]; then
        echo "Apple Silicon detected"
        HARDWARE="apple"
    else
        echo "Intel Mac detected"
        HARDWARE="cpu"
    fi
elif [ "$(uname)" == "Linux" ]; then
    OS="Linux"
    if command -v nvidia-smi &> /dev/null; then
        echo "NVIDIA GPU detected on Linux"
        HARDWARE="nvidia"
    elif lspci | grep -i amd | grep -i vga &> /dev/null; then
        echo "AMD GPU detected on Linux"
        HARDWARE="amd"
    else
        echo "No GPU detected on Linux"
        HARDWARE="cpu"
    fi
else
    OS="Unknown"
    HARDWARE="cpu"
    echo "Unknown OS, using CPU mode"
fi

# Set memory limit based on total system memory
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
sed -i.bak "s/OLLAMA_MEMORY_LIMIT=.*/OLLAMA_MEMORY_LIMIT=${OLLAMA_MEM}G/" .env

echo "=============================================="
echo "Hardware detection: $HARDWARE"
echo "Operating System: $OS"
echo "Ollama memory limit: ${OLLAMA_MEM}G"
echo "=============================================="

# Stop any running containers
echo "Stopping any running containers..."
docker compose down

# Start with appropriate compose file
if [ "$HARDWARE" == "nvidia" ]; then
    echo "Starting with NVIDIA GPU acceleration..."
    docker compose -f docker-compose.yml -f docker-compose.nvidia.yml up -d --remove-orphans || echo "Ignoring validation warnings"
elif [ "$HARDWARE" == "amd" ]; then
    echo "Starting with AMD GPU acceleration..."
    docker compose -f docker-compose.yml -f docker-compose.amd.yml up -d --remove-orphans || echo "Ignoring validation warnings"
elif [ "$HARDWARE" == "apple" ]; then
    echo "Starting with Apple Silicon acceleration..."
    docker compose -f docker-compose.yml -f docker-compose.apple.yml up -d --remove-orphans || echo "Ignoring validation warnings"
else
    echo "Starting without hardware acceleration..."
    docker compose up -d --remove-orphans || echo "Ignoring validation warnings"
fi

echo "Startup complete!"
