#!/bin/bash
# Stop services script
# This script stops all running containers in the AI-Chat-Agent stack

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

print_status "Stopping all AI-Chat-Agent services..."

# Stop running containers
docker compose down

print_success "All services stopped successfully!"
echo ""
print_status "To start services again, use:"
echo -e "${CYAN}  ./start-with-hardware-acceleration.sh${NC}"
echo ""
