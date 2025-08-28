#!/bin/bash
# Interactive startup script for AI Chat Agent
# This script guides the user through starting the stack with custom options

# Color definitions
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function for section headers
print_header() {
    echo -e "\n${BOLD}${CYAN}=== $1 ===${NC}"
    echo -e "${GRAY}$2${NC}\n"
}

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

print_error() {
    echo -e "${RED}==> $1${NC}"
}

# Check for Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Banner
echo -e "${BOLD}${CYAN}"
echo "🚀 AI Chat Agent - Interactive Startup"
echo "=======================================${NC}"
echo -e "${GRAY}This script will help you start the AI Chat Agent with your preferences.${NC}"
echo ""

# Hardware detection
print_header "Hardware Detection" "Detecting your system configuration..."

# Detect OS
if [ "$(uname)" == "Darwin" ]; then
    OS="MacOS"
    if [ "$(uname -m)" == "arm64" ]; then
        print_success "Apple Silicon detected"
        DETECTED_HARDWARE="apple"
    else
        print_warning "Intel Mac detected"
        DETECTED_HARDWARE="cpu"
    fi
elif [ "$(uname)" == "Linux" ]; then
    OS="Linux"
    if command -v nvidia-smi &> /dev/null; then
        NVIDIA_INFO=$(nvidia-smi --query-gpu=name --format=csv,noheader)
        print_success "NVIDIA GPU detected: $NVIDIA_INFO"
        DETECTED_HARDWARE="nvidia"
    elif command -v lspci &> /dev/null && lspci | grep -i amd | grep -i vga &> /dev/null; then
        AMD_INFO=$(lspci | grep -i amd | grep -i vga | head -n1)
        print_success "AMD GPU detected: $AMD_INFO"
        DETECTED_HARDWARE="amd"
    else
        print_warning "No GPU detected on Linux"
        DETECTED_HARDWARE="cpu"
    fi
else
    OS="Windows"
    # For Windows, we're likely in WSL or Git Bash
    DETECTED_HARDWARE="cpu"
fi

# Calculate memory recommendations
TOTAL_MEM_GB=8
if [ "$(uname)" == "Darwin" ]; then
    TOTAL_MEM_KB=$(sysctl hw.memsize | awk '{print $2}')
    TOTAL_MEM_GB=$((TOTAL_MEM_KB / 1024 / 1024 / 1024))
elif [ "$(uname)" == "Linux" ]; then
    TOTAL_MEM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    TOTAL_MEM_GB=$((TOTAL_MEM_KB / 1024 / 1024))
fi

# Recommended Ollama memory limit (50% of system RAM, but between 4-16GB)
OLLAMA_MEM=$((TOTAL_MEM_GB / 2))
if [ $OLLAMA_MEM -lt 4 ]; then
    OLLAMA_MEM=4
elif [ $OLLAMA_MEM -gt 16 ]; then
    OLLAMA_MEM=16
fi

# Display detected information
echo -e "${CYAN}Detected System:${NC}"
echo -e "  • Operating System: ${BOLD}$OS${NC}"
echo -e "  • Hardware: ${BOLD}$DETECTED_HARDWARE${NC}"
echo -e "  • Total Memory: ${BOLD}${TOTAL_MEM_GB}GB${NC}"
echo -e "  • Recommended Ollama Memory: ${BOLD}${OLLAMA_MEM}GB${NC}"
echo ""

# Ask for hardware preferences
print_header "Hardware Selection" "Choose acceleration options for AI models"

echo -e "${YELLOW}Detected hardware: ${BOLD}$DETECTED_HARDWARE${NC}"
echo -e "Available options:"
echo -e "  1. ${BOLD}Auto-detect${NC} (recommended, currently: $DETECTED_HARDWARE)"
echo -e "  2. ${BOLD}NVIDIA GPU${NC} - CUDA acceleration"
echo -e "  3. ${BOLD}AMD GPU${NC} - ROCm/DirectML acceleration"
echo -e "  4. ${BOLD}Apple Silicon${NC} - Metal acceleration"
echo -e "  5. ${BOLD}CPU only${NC} - No hardware acceleration"

read -p "Select hardware option [1-5] (default: 1): " HARDWARE_CHOICE
HARDWARE_CHOICE=${HARDWARE_CHOICE:-1}

case $HARDWARE_CHOICE in
    1)
        HARDWARE=$DETECTED_HARDWARE
        print_status "Using auto-detected hardware: $HARDWARE"
        ;;
    2)
        HARDWARE="nvidia"
        print_status "Selected NVIDIA GPU acceleration"
        ;;
    3)
        HARDWARE="amd"
        print_status "Selected AMD GPU acceleration"
        ;;
    4)
        HARDWARE="apple"
        print_status "Selected Apple Silicon acceleration"
        ;;
    5)
        HARDWARE="cpu"
        print_status "Selected CPU-only mode (no acceleration)"
        ;;
    *)
        HARDWARE=$DETECTED_HARDWARE
        print_warning "Invalid choice, using auto-detected hardware: $HARDWARE"
        ;;
esac

# Ask for memory limit
read -p "Enter Ollama memory limit in GB (recommended: $OLLAMA_MEM): " MEMORY_INPUT
OLLAMA_MEMORY=${MEMORY_INPUT:-$OLLAMA_MEM}
echo -e "Setting Ollama memory limit to: ${BOLD}${OLLAMA_MEMORY}GB${NC}"

# Update .env file with memory limit
sed -i.bak "s/OLLAMA_MEMORY_LIMIT=.*/OLLAMA_MEMORY_LIMIT=${OLLAMA_MEMORY}G/" .env 2>/dev/null || \
echo "OLLAMA_MEMORY_LIMIT=${OLLAMA_MEMORY}G" >> .env

# Components selection
print_header "Component Selection" "Choose which components to start"

# Ask about Supabase
echo -e "Do you want to start the ${BOLD}Supabase UI${NC}?"
echo -e "  The Supabase UI provides a visual interface to manage your database."
echo -e "  • Studio interface at http://localhost:3001"
echo -e "  • API endpoint at http://localhost:8000"
read -p "Start Supabase UI? [y/N]: " START_SUPABASE
START_SUPABASE=${START_SUPABASE:-n}

# Ask if they want to install models
echo -e "\nDo you want to ${BOLD}install AI models${NC} after startup?"
echo -e "  Common models include llama2, mistral, codellama, etc."
read -p "Install AI models? [y/N]: " INSTALL_MODELS
INSTALL_MODELS=${INSTALL_MODELS:-n}

# Summary and confirmation
print_header "Summary" "Review your selections before starting"

echo -e "  • Hardware: ${BOLD}$HARDWARE${NC}"
echo -e "  • Ollama Memory: ${BOLD}${OLLAMA_MEMORY}GB${NC}"
echo -e "  • Supabase UI: ${BOLD}$([ "$START_SUPABASE" = "y" ] && echo "Yes" || echo "No")${NC}"
echo -e "  • Install Models: ${BOLD}$([ "$INSTALL_MODELS" = "y" ] && echo "Yes" || echo "No")${NC}"
echo ""

read -p "Start the stack with these settings? [Y/n]: " START_CONFIRM
START_CONFIRM=${START_CONFIRM:-y}

if [ "$START_CONFIRM" != "y" ] && [ "$START_CONFIRM" != "Y" ]; then
    print_error "Startup cancelled."
    exit 1
fi

# Stop any running containers
print_status "Stopping any running containers..."
docker compose down

# Start with the appropriate configuration
print_header "Starting Services" "Initializing your AI stack"

if [ "$HARDWARE" == "nvidia" ]; then
    print_success "Starting with NVIDIA GPU acceleration..."
    docker compose -f docker-compose.yml -f docker-compose.nvidia.yml up -d --remove-orphans || echo "Ignoring validation warnings"
elif [ "$HARDWARE" == "amd" ]; then
    print_success "Starting with AMD GPU acceleration..."
    docker compose -f docker-compose.yml -f docker-compose.amd.yml up -d --remove-orphans || echo "Ignoring validation warnings"
elif [ "$HARDWARE" == "apple" ]; then
    print_success "Starting with Apple Silicon acceleration..."
    docker compose -f docker-compose.yml -f docker-compose.apple.yml up -d --remove-orphans || echo "Ignoring validation warnings"
else
    print_warning "Starting without hardware acceleration..."
    docker compose up -d --remove-orphans || echo "Ignoring validation warnings"
fi

# Start Supabase UI if requested
if [ "$START_SUPABASE" = "y" ] || [ "$START_SUPABASE" = "Y" ]; then
    print_status "Starting Supabase UI..."
    # Wait a moment for the main stack to initialize
    sleep 10
    # Make sure the network exists
    docker network inspect ai-chat-agent_ai_network >/dev/null 2>&1 || docker network create ai-chat-agent_ai_network
    docker compose -f docker-compose-supabase.yml up -d || print_error "Failed to start Supabase UI"
fi

# Install models if requested
if [ "$INSTALL_MODELS" = "y" ] || [ "$INSTALL_MODELS" = "Y" ]; then
    print_status "Installing AI models..."
    # Wait longer for Ollama to initialize
    print_status "Waiting for Ollama to initialize (30 seconds)..."
    sleep 30
    if [ -f ./install-models.sh ]; then
        chmod +x ./install-models.sh
        ./install-models.sh
    else
        print_error "Model installation script not found. You can manually install models later."
    fi
fi

# Final summary
print_header "Startup Complete" "Your AI stack is now running"

echo -e "${CYAN}📋 Access Information:${NC}"
echo -e " - n8n: ${BOLD}http://localhost:5678${NC}"
echo -e " - Open WebUI: ${BOLD}http://localhost:3000${NC}"
echo -e " - Ollama API: ${BOLD}http://localhost:11434${NC}"

if [ "$START_SUPABASE" = "y" ] || [ "$START_SUPABASE" = "Y" ]; then
    echo -e " - Supabase Studio: ${BOLD}http://localhost:3001${NC}"
    echo -e " - Supabase API: ${BOLD}http://localhost:8000${NC}"
fi

echo -e "\n${GRAY}You can stop all services with: ${BOLD}./stop-services.sh${NC}"
echo -e "${GRAY}To view logs: ${BOLD}docker compose logs -f${NC}"
echo -e "\n${GREEN}Enjoy your local AI stack! 🚀${NC}"
