#!/bin/bash
# AI Chat Agent Stack - Automated Setup Script for Linux/macOS
# This script creates all necessary files and configurations for the AI Chat Agent Stack

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo -e "${CYAN}AI Chat Agent Stack - Automated Setup (Linux/macOS Edition)${NC}"
echo -e "${CYAN}=================================================================${NC}"

# Function to create a file if it doesn't exist
create_file_if_not_exists() {
    if [ ! -f "$1" ]; then
        echo "$2" > "$1"
        echo -e "${GREEN}Created: $1${NC}"
    else
        echo -e "${YELLOW}Already exists: $1 (skipped)${NC}"
    fi
}

# Function to create directory structure
create_dir_structure() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo -e "${GREEN}Directory created: $1${NC}"
    else
        echo -e "${YELLOW}Directory already exists: $1${NC}"
    fi
}

# Check prerequisites
echo -e "${MAGENTA}Checking prerequisites...${NC}"
if command -v docker &> /dev/null; then
    echo -e "${GREEN}Docker is installed: $(docker --version)${NC}"
else
    echo -e "${RED}Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Create directory structure
echo -e "${MAGENTA}Creating directory structure...${NC}"
create_dir_structure "shared-files"

# Create .env file with all necessary configurations
echo -e "${MAGENTA}Creating .env configuration file...${NC}"
ENV_CONTENT="############################################################################
# AI CHAT AGENT STACK - LOCAL DEVELOPMENT CONFIGURATION
# Automatically generated - For local development only!
############################################################################

############################################################################
# GENERAL SETTINGS
############################################################################
TIMEZONE=Europe/Berlin

############################################################################
# N8N CONFIGURATION
############################################################################
N8N_PORT=5678
N8N_HOST=localhost
N8N_WEBHOOK_URL=http://localhost:5678

N8N_AUTH_USER=admin
N8N_AUTH_PASSWORD=LocalDev2025!
N8N_ENCRYPTION_KEY=n8n_local_dev_key_32_chars_long_123

N8N_DB_NAME=n8n
N8N_DB_USER=n8n_user
N8N_DB_PASSWORD=n8n_secure_local_pass_2025

############################################################################
# MEMORY DB FOR AI AGENTS
############################################################################
MEMORY_DB_NAME=n8n_memory
MEMORY_DB_USER=memory_user
MEMORY_DB_PASSWORD=memory_secure_local_pass_2025

############################################################################
# POSTGRES CONFIGURATION
############################################################################
POSTGRES_PASSWORD=supabase_local_dev_pass_2025
POSTGRES_DB=postgres
POSTGRES_PORT=5432

############################################################################
# OLLAMA CONFIGURATION
############################################################################
OLLAMA_PORT=11434

############################################################################
# OPEN WEBUI
############################################################################
OPEN_WEBUI_PORT=3000
WEBUI_SECRET_KEY=webui_local_dev_secret_key_2025
WEBUI_AUTH=false"

create_file_if_not_exists ".env" "$ENV_CONTENT"

# Create PostgreSQL initialization file
echo -e "${MAGENTA}Creating PostgreSQL initialization file...${NC}"
INIT_SQL="-- Complete initialization file for simplified PostgreSQL installation
-- This file creates all required schemas, extensions and tables

-- 1. Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";
CREATE EXTENSION IF NOT EXISTS \"pgcrypto\";

-- 2. Create schemas
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS storage;
CREATE SCHEMA IF NOT EXISTS realtime;

-- 3. Create auth tables
CREATE TABLE IF NOT EXISTS auth.users (
    id uuid NOT NULL PRIMARY KEY DEFAULT uuid_generate_v4(),
    email varchar(255) UNIQUE,
    encrypted_password varchar(255),
    email_confirmed_at timestamptz,
    created_at timestamptz DEFAULT timezone('utc'::text, now()),
    updated_at timestamptz DEFAULT timezone('utc'::text, now()),
    raw_user_meta_data jsonb
);

CREATE INDEX IF NOT EXISTS users_email_idx ON auth.users(email);

-- 4. Create storage tables
CREATE TABLE IF NOT EXISTS storage.buckets (
    id text NOT NULL PRIMARY KEY,
    name text NOT NULL,
    owner uuid,
    public boolean DEFAULT false,
    created_at timestamptz DEFAULT timezone('utc'::text, now()),
    updated_at timestamptz DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS storage.objects (
    id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamptz DEFAULT timezone('utc'::text, now()),
    updated_at timestamptz DEFAULT timezone('utc'::text, now()),
    last_accessed_at timestamptz DEFAULT timezone('utc'::text, now()),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/')) STORED,
    CONSTRAINT objects_bucketid_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id)
);

CREATE INDEX IF NOT EXISTS objects_bucket_id_name_idx ON storage.objects(bucket_id, name);

-- 5. Realtime setup
-- Create a publication for real-time updates
CREATE PUBLICATION postgres_publication FOR ALL TABLES;"

create_file_if_not_exists "init.sql" "$INIT_SQL"

# Create docker-compose file
echo -e "${MAGENTA}Creating docker-compose.yml file...${NC}"
DOCKER_COMPOSE="version: '3.8'

services:
  postgres-db:
    image: postgres:15-alpine
    container_name: postgres-db
    restart: unless-stopped
    ports:
      - \"\${POSTGRES_PORT:-5432}:5432\"
    environment:
      POSTGRES_PASSWORD: \${POSTGRES_PASSWORD:-supabase_local_dev_pass_2025}
      POSTGRES_DB: \${POSTGRES_DB:-postgres}
      POSTGRES_INITDB_ARGS: \"--locale=C --encoding=UTF8\"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    networks:
      - ai_network
    healthcheck:
      test: [\"CMD-SHELL\", \"pg_isready -U postgres\"]
      interval: 10s
      timeout: 5s
      retries: 5
    security_opt:
      - no-new-privileges:true

  n8n-db:
    image: postgres:15-alpine
    container_name: n8n-postgres
    restart: unless-stopped
    environment:
      - POSTGRES_DB=\${N8N_DB_NAME:-n8n}
      - POSTGRES_USER=\${N8N_DB_USER:-n8n_user}
      - POSTGRES_PASSWORD=\${N8N_DB_PASSWORD:-n8n_secure_local_pass_2025}
    volumes:
      - n8n_postgres_data:/var/lib/postgresql/data
    networks:
      - ai_network
    healthcheck:
      test: [\"CMD-SHELL\", \"pg_isready -U \${N8N_DB_USER:-n8n_user}\"]
      interval: 10s
      timeout: 5s
      retries: 5
    security_opt:
      - no-new-privileges:true

  memory-db:
    image: postgres:15-alpine
    container_name: n8n-memory-postgres
    restart: unless-stopped
    environment:
      - POSTGRES_DB=\${MEMORY_DB_NAME:-n8n_memory}
      - POSTGRES_USER=\${MEMORY_DB_USER:-memory_user}
      - POSTGRES_PASSWORD=\${MEMORY_DB_PASSWORD:-memory_secure_local_pass_2025}
    volumes:
      - memory_postgres_data:/var/lib/postgresql/data
    networks:
      - ai_network
    healthcheck:
      test: [\"CMD-SHELL\", \"pg_isready -U \${MEMORY_DB_USER:-memory_user}\"]
      interval: 10s
      timeout: 5s
      retries: 5
    security_opt:
      - no-new-privileges:true

  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - \"\${N8N_PORT:-5678}:5678\"
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=n8n-db
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=\${N8N_DB_NAME:-n8n}
      - DB_POSTGRESDB_USER=\${N8N_DB_USER:-n8n_user}
      - DB_POSTGRESDB_PASSWORD=\${N8N_DB_PASSWORD:-n8n_secure_local_pass_2025}
      - N8N_HOST=\${N8N_HOST:-localhost}
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - WEBHOOK_URL=\${N8N_WEBHOOK_URL:-http://localhost:5678}
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=\${N8N_AUTH_USER:-admin}
      - N8N_BASIC_AUTH_PASSWORD=\${N8N_AUTH_PASSWORD:-LocalDev2025!}
      - GENERIC_TIMEZONE=\${TIMEZONE:-Europe/Berlin}
      - N8N_ENCRYPTION_KEY=\${N8N_ENCRYPTION_KEY:-n8n_local_dev_key_32_chars_long_123}
      - NODE_FUNCTION_ALLOW_EXTERNAL=axios,moment,lodash,n8n-nodes-*
      - N8N_DIAGNOSTICS_ENABLED=false
      - N8N_HIRING_BANNER_ENABLED=false
    volumes:
      - n8n_data:/home/node/.n8n
      - ./shared-files:/files:ro
    networks:
      - ai_network
    depends_on:
      n8n-db:
        condition: service_healthy
    security_opt:
      - no-new-privileges:true

  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    restart: unless-stopped
    ports:
      - \"\${OLLAMA_PORT:-11434}:11434\"
    volumes:
      - ollama_data:/root/.ollama
    networks:
      - ai_network
    deploy:
      resources:
        limits:
          memory: 8G
    security_opt:
      - no-new-privileges:true

  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    restart: unless-stopped
    ports:
      - \"\${OPEN_WEBUI_PORT:-3000}:8080\"
    environment:
      - OLLAMA_API_BASE_URL=http://ollama:11434/api
      - SECRET_KEY=\${WEBUI_SECRET_KEY:-webui_local_dev_secret_key_2025}
      - WEBUI_AUTH=\${WEBUI_AUTH:-false}
    volumes:
      - open_webui_data:/app/backend/data
    networks:
      - ai_network
    depends_on:
      - ollama
    security_opt:
      - no-new-privileges:true

networks:
  ai_network:
    driver: bridge

volumes:
  postgres_data:
  n8n_postgres_data:
  memory_postgres_data:
  n8n_data:
  ollama_data:
  open_webui_data:"

create_file_if_not_exists "docker-compose.yml" "$DOCKER_COMPOSE"

# File structure verification
echo -e "${MAGENTA}Checking created file structure...${NC}"
echo -e "${CYAN}Summary of created files:${NC}"

if [ -f ".env" ]; then
    echo -e "${GREEN}.env configuration file${NC}"
else
    echo -e "${RED}.env file missing${NC}"
fi

if [ -f "init.sql" ]; then
    echo -e "${GREEN}PostgreSQL initialization script${NC}"
else
    echo -e "${RED}init.sql missing${NC}"
fi

if [ -f "docker-compose.yml" ]; then
    echo -e "${GREEN}Docker Compose configuration${NC}"
else
    echo -e "${RED}docker-compose.yml missing${NC}"
fi

# Start containers
echo -e "${MAGENTA}Starting containers...${NC}"
echo -e "${YELLOW}This may take several minutes on first start while Docker downloads images.${NC}"

docker-compose up -d

echo ""
echo -e "${GREEN}AI Chat Agent Stack Setup completed!${NC}"
echo -e "${CYAN}=================================================================${NC}"
echo ""
echo -e "${CYAN}Access credentials:${NC}"
echo ""
echo -e "${BLUE}   n8n Workflow Automation: http://localhost:5678${NC}"
echo -e "${WHITE}      Username: admin${NC}"
echo -e "${WHITE}      Password: LocalDev2025!${NC}"
echo ""
echo -e "${BLUE}   PostgreSQL Database: localhost:5432${NC}"
echo -e "${WHITE}      Username: postgres${NC}"
echo -e "${WHITE}      Password: supabase_local_dev_pass_2025${NC}"
echo ""
echo -e "${BLUE}   Ollama API: http://localhost:11434${NC}"
echo -e "${BLUE}   Open WebUI (Chat): http://localhost:3000${NC}"
echo ""
echo -e "${YELLOW}Note: The PostgreSQL database already contains all necessary schemas:${NC}"
echo -e "${WHITE}    - auth${NC}"
echo -e "${WHITE}    - storage${NC}"
echo -e "${WHITE}    - realtime${NC}"
echo ""
echo -e "${CYAN}Use the following connection string:${NC}"
echo -e "${WHITE}   postgresql://postgres:supabase_local_dev_pass_2025@localhost:5432/postgres${NC}"
echo ""
echo -e "${GREEN}Happy coding with your AI Chat Agent Stack!${NC}"
