#!/bin/bash
# Shell script to pull popular models into Ollama

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo -e "${CYAN}🤖 AI Chat Agent - Ollama Model Installer${NC}"
echo -e "${CYAN}=====================================================${NC}"
echo ""

# Check if Ollama is responsive
if ! curl -s -o /dev/null -w "%{http_code}" http://localhost:11434/api/version | grep -q "200"; then
    echo -e "${RED}❌ Ollama is not responsive. Make sure it's running with 'docker-compose up -d ollama'${NC}"
    exit 1
fi

# Get Ollama version
OLLAMA_VERSION=$(curl -s http://localhost:11434/api/version | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
echo -e "${GREEN}✅ Ollama is running (version $OLLAMA_VERSION)${NC}"

# List of popular models to pull
declare -a models=(
    "llama2:Llama 2 (Meta):3.8GB" 
    "mistral:Mistral 7B:4.1GB" 
    "phi:Phi-2 (Microsoft):1.7GB" 
    "gemma\:2b:Gemma 2B (Google):1.8GB" 
    "codellama:Code Llama (Meta):3.8GB" 
    "orca-mini:Orca Mini:1.8GB"
)

echo -e "${YELLOW}Available models to install:${NC}"
echo ""
for i in "${!models[@]}"; do
    IFS=':' read -ra MODEL_INFO <<< "${models[$i]}"
    echo -e "$((i+1)). ${WHITE}${MODEL_INFO[1]} (${MODEL_INFO[2]})${NC}"
done
echo -e "${CYAN}7. All models${NC}"
echo -e "${RED}8. Exit${NC}"
echo ""

read -p "Select a model to install (1-8): " choice

if [ "$choice" == "8" ]; then
    echo -e "${YELLOW}Exiting...${NC}"
    exit 0
fi

declare -a models_to_pull=()
if [ "$choice" == "7" ]; then
    echo ""
    echo -e "${YELLOW}⚠️ You've chosen to install all models. This will download approximately 17GB of data.${NC}"
    read -p "Are you sure you want to continue? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[yY]$ ]]; then
        echo -e "${RED}Installation cancelled.${NC}"
        exit 0
    fi
    models_to_pull=("${models[@]}")
elif [[ "$choice" =~ ^[1-6]$ ]]; then
    models_to_pull=("${models[$((choice-1))]}")
else
    echo -e "${RED}Invalid selection. Exiting.${NC}"
    exit 1
fi

for model_info in "${models_to_pull[@]}"; do
    IFS=':' read -ra MODEL_DATA <<< "$model_info"
    MODEL_NAME="${MODEL_DATA[0]}"
    MODEL_DISPLAY="${MODEL_DATA[1]}"
    MODEL_SIZE="${MODEL_DATA[2]}"
    
    echo ""
    echo -e "${CYAN}📥 Pulling $MODEL_DISPLAY... (approximately $MODEL_SIZE)${NC}"
    
    # Use docker exec to run the ollama pull command
    PULL_COMMAND="docker exec -it ollama ollama pull $MODEL_NAME"
    echo -e "${GRAY}Executing: $PULL_COMMAND${NC}"
    eval $PULL_COMMAND
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Successfully pulled $MODEL_DISPLAY${NC}"
    else
        echo -e "${RED}❌ Failed to pull $MODEL_DISPLAY${NC}"
    fi
done

echo ""
echo -e "${CYAN}📋 Current models in Ollama:${NC}"
docker exec -it ollama ollama list

echo ""
echo -e "${GREEN}🎉 Model installation completed!${NC}"
echo -e "${CYAN}You can now use these models through:${NC}"
echo -e "- Open WebUI at http://localhost:3000"
echo -e "- Direct API calls to http://localhost:11434"
echo -e "- In n8n workflows with the HTTP Request node"

echo ""
echo -e "${YELLOW}Example API call (curl):${NC}"
echo -e "${GRAY}curl -X POST http://localhost:11434/api/generate -H 'Content-Type: application/json' -d '{
  \"model\": \"llama2\",
  \"prompt\": \"Explain how AI works in simple terms\",
  \"stream\": false
}'${NC}"
