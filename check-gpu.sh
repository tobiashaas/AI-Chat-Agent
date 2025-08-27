#!/bin/bash
# Script to check and configure GPU support for Ollama

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🔍 GPU Detection for Ollama${NC}"
echo -e "${CYAN}=====================================================${NC}"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

# Check if Ollama container is running
if ! docker ps | grep -q "ollama"; then
    echo -e "${RED}❌ Ollama container is not running. Please start it with 'docker-compose up -d ollama'${NC}"
    exit 1
fi

echo -e "${BLUE}Checking for NVIDIA GPU...${NC}"
if docker exec -it ollama nvidia-smi &> /dev/null; then
    NVIDIA_INFO=$(docker exec -it ollama nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader)
    echo -e "${GREEN}✅ NVIDIA GPU detected:${NC}"
    echo -e "$NVIDIA_INFO" | sed 's/^/   /'
    echo ""
    echo -e "${BLUE}Testing GPU with Ollama...${NC}"
    echo -e "${GRAY}This will check if Ollama can access the GPU${NC}"
    docker exec -it ollama bash -c 'ollama run lionel-wong/verify-gpu 2>&1' | grep -i "gpu\|cuda\|available\|tensor"
    
    # Check if models are using GPU
    echo ""
    echo -e "${BLUE}Current models:${NC}"
    MODELS=$(docker exec -it ollama ollama list | tail -n +2 | awk '{print $1}')
    if [ -z "$MODELS" ]; then
        echo -e "${YELLOW}   No models installed yet. Install models with './install-models.sh'${NC}"
    else
        echo "$MODELS" | while read -r MODEL; do
            echo -e "   ${CYAN}$MODEL${NC}"
        done
    fi
else
    echo -e "${YELLOW}⚠️ NVIDIA GPU not detected or not properly configured.${NC}"
    
    # Check CPU acceleration
    echo -e "${BLUE}Checking for CPU acceleration features...${NC}"
    if docker exec -it ollama grep -q -E 'avx2|avx512' /proc/cpuinfo; then
        echo -e "${GREEN}✅ CPU supports AVX2/AVX512 instructions for acceleration${NC}"
        
        CPU_INFO=$(docker exec -it ollama cat /proc/cpuinfo | grep "model name" | head -1 | cut -d ':' -f2- | sed 's/^[ \t]*//')
        echo -e "${GREEN}   CPU: $CPU_INFO${NC}"
        
        # Check which instructions are supported
        if docker exec -it ollama grep -q 'avx512' /proc/cpuinfo; then
            echo -e "${GREEN}   AVX-512: Supported ✓${NC}"
        else
            echo -e "${YELLOW}   AVX-512: Not supported ✗${NC}"
        fi
        
        if docker exec -it ollama grep -q 'avx2' /proc/cpuinfo; then
            echo -e "${GREEN}   AVX2: Supported ✓${NC}"
        else
            echo -e "${YELLOW}   AVX2: Not supported ✗${NC}"
        fi
    else
        echo -e "${RED}❌ CPU does not support advanced vector instructions (AVX).${NC}"
        echo -e "${YELLOW}   LLM inference will be significantly slower.${NC}"
    fi
fi

echo ""
echo -e "${BLUE}Memory configuration:${NC}"
MEM_CONFIG=$(docker exec -it ollama cat /proc/meminfo | grep -E 'MemTotal|MemAvailable' | awk '{print $1 " " $2/1024/1024 " GB"}')
echo -e "$MEM_CONFIG" | sed 's/^/   /'

echo ""
echo -e "${CYAN}Recommendations:${NC}"
echo -e "1. For NVIDIA GPU support, ensure you have the ${BLUE}NVIDIA Container Toolkit${NC} installed"
echo -e "2. For optimal CPU performance, ensure your models are compiled with ${BLUE}AVX2/AVX512${NC} support"
echo -e "3. Consider smaller models like ${BLUE}phi-2, gemma:2b${NC} for machines with limited resources"
echo ""
echo -e "${GREEN}See HARDWARE-ACCELERATION.md for detailed configuration options${NC}"
