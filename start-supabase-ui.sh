#!/bin/bash
# Shell script to start Supabase UI for Linux/macOS users

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

echo -e "${CYAN}🚀 AI Chat Agent - Supabase UI Starter${NC}"
echo -e "${CYAN}=====================================================${NC}"
echo ""

# Check if docker is installed
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✅ Docker is installed: $(docker --version)${NC}"
else
    echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Check if main stack is running
if ! docker ps --format "{{.Names}}" | grep -q "postgres-db"; then
    echo -e "${YELLOW}❓ The main AI Chat Agent stack doesn't appear to be running.${NC}"
    read -p "Would you like to start it first? (y/n): " START_MAIN
    
    if [ "$START_MAIN" = "y" ] || [ "$START_MAIN" = "Y" ]; then
        echo -e "${BLUE}Starting main stack...${NC}"
        docker-compose up -d
        echo -e "${YELLOW}Waiting for the database to initialize...${NC}"
        sleep 10
    fi
else
    echo -e "${GREEN}✅ Main AI Chat Agent stack is running${NC}"
fi

echo ""
echo -e "${BLUE}Starting Supabase UI...${NC}"

# Start Supabase UI
if docker-compose -f docker-compose-supabase.yml up -d; then
    echo ""
    echo -e "${GREEN}✅ Supabase UI is starting!${NC}"
    echo ""
    echo -e "${CYAN}📋 Access Information:${NC}"
    echo -e " - Supabase Studio: http://localhost:3001"
    echo -e " - API Endpoint:    http://localhost:8000"
    echo ""
    echo -e "${YELLOW}⏳ Please allow a few moments for all services to initialize...${NC}"
    echo ""
    echo -e "${CYAN}🔑 Default Service Role Key (for administrative access):${NC}"
    echo -e "${GRAY}eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJzZXJ2aWNlX3JvbGUiLAogICAgImlzcyI6ICJzdXBhYmFzZS1kZW1vIiwKICAgICJpYXQiOiAxNjQxNzY5MjAwLAogICAgImV4cCI6IDE3OTk1MzU2MDAKfQ.DaYlNEoUrrEn2Ig7tqibS-PHK5vgusbcbo7X36XVt4Q${NC}"
else
    echo -e "${RED}❌ Failed to start Supabase UI${NC}"
    exit 1
fi
