# AI Chat Agent Stack - Automated Setup for Windows PowerShell
# This script creates all necessary files and configurations for the AI Chat Agent Stack

Write-Host "AI Chat Agent Stack - Automated Setup (Windows Edition)" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

# Function to create files if they don't exist
function New-FileIfNotExists {
    param (
        [string]$FilePath,
        [string]$Content
    )
    
    if (-not (Test-Path $FilePath)) {
        Set-Content -Path $FilePath -Value $Content -Encoding UTF8
        Write-Host "Created: $FilePath" -ForegroundColor Green
    } else {
        Write-Host "Already exists: $FilePath (skipped)" -ForegroundColor Yellow
    }
}

# Function to create directory structures
function New-DirStructure {
    param (
        [string]$DirPath
    )
    
    if (-not (Test-Path $DirPath)) {
        New-Item -Path $DirPath -ItemType Directory -Force | Out-Null
        Write-Host "Directory created: $DirPath" -ForegroundColor Green
    } else {
        Write-Host "Directory already exists: $DirPath" -ForegroundColor Yellow
    }
}

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Magenta
try {
    $dockerVersion = docker --version
    Write-Host "Docker is installed: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "Docker is not installed. Please install Docker Desktop first." -ForegroundColor Red
    exit 1
}

# Create directory structure
Write-Host "Creating directory structure..." -ForegroundColor Magenta
New-DirStructure "shared-files"

# Create .env file with all necessary configurations
Write-Host "Creating .env configuration file..." -ForegroundColor Magenta
$ENV_CONTENT = @'
############################################################################
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
WEBUI_AUTH=false
'@

New-FileIfNotExists ".env" $ENV_CONTENT

# Create PostgreSQL initialization file
Write-Host "Creating PostgreSQL initialization file..." -ForegroundColor Magenta
$INIT_SQL = @'
-- Complete initialization file for simplified PostgreSQL installation
-- This file creates all required schemas, extensions and tables

-- 1. Notwendige Erweiterungen aktivieren
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. Schemas erstellen
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS storage;
CREATE SCHEMA IF NOT EXISTS realtime;

-- 3. Auth-Tabellen erstellen
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

-- 4. Storage-Tabellen erstellen
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

-- 5. Realtime-Setup
-- Erstellen Sie eine Publikation für Echtzeit-Updates
CREATE PUBLICATION postgres_publication FOR ALL TABLES;
'@

New-FileIfNotExists "init.sql" $INIT_SQL

# Create simplified docker-compose file
Write-Host "Creating docker-compose.yml file..." -ForegroundColor Magenta
$DOCKER_COMPOSE = @'
version: '3.8'

services:
  postgres-db:
    image: postgres:15-alpine
    container_name: postgres-db
    restart: unless-stopped
    ports:
      - "${POSTGRES_PORT:-5432}:5432"
    environment:
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-supabase_local_dev_pass_2025}
      POSTGRES_DB: ${POSTGRES_DB:-postgres}
      POSTGRES_INITDB_ARGS: "--locale=C --encoding=UTF8"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    networks:
      - ai_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
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
      - POSTGRES_DB=${N8N_DB_NAME:-n8n}
      - POSTGRES_USER=${N8N_DB_USER:-n8n_user}
      - POSTGRES_PASSWORD=${N8N_DB_PASSWORD:-n8n_secure_local_pass_2025}
    volumes:
      - n8n_postgres_data:/var/lib/postgresql/data
    networks:
      - ai_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${N8N_DB_USER:-n8n_user}"]
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
      - POSTGRES_DB=${MEMORY_DB_NAME:-n8n_memory}
      - POSTGRES_USER=${MEMORY_DB_USER:-memory_user}
      - POSTGRES_PASSWORD=${MEMORY_DB_PASSWORD:-memory_secure_local_pass_2025}
    volumes:
      - memory_postgres_data:/var/lib/postgresql/data
    networks:
      - ai_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${MEMORY_DB_USER:-memory_user}"]
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
      - "${N8N_PORT:-5678}:5678"
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=n8n-db
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=${N8N_DB_NAME:-n8n}
      - DB_POSTGRESDB_USER=${N8N_DB_USER:-n8n_user}
      - DB_POSTGRESDB_PASSWORD=${N8N_DB_PASSWORD:-n8n_secure_local_pass_2025}
      - N8N_HOST=${N8N_HOST:-localhost}
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - WEBHOOK_URL=${N8N_WEBHOOK_URL:-http://localhost:5678}
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=${N8N_AUTH_USER:-admin}
      - N8N_BASIC_AUTH_PASSWORD=${N8N_AUTH_PASSWORD:-LocalDev2025!}
      - GENERIC_TIMEZONE=${TIMEZONE:-Europe/Berlin}
      - N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY:-n8n_local_dev_key_32_chars_long_123}
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
      - "${OLLAMA_PORT:-11434}:11434"
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
      - "${OPEN_WEBUI_PORT:-3000}:8080"
    environment:
      - OLLAMA_API_BASE_URL=http://ollama:11434/api
      - SECRET_KEY=${WEBUI_SECRET_KEY:-webui_local_dev_secret_key_2025}
      - WEBUI_AUTH=${WEBUI_AUTH:-false}
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
  open_webui_data:
'@

New-FileIfNotExists "docker-compose.yml" $DOCKER_COMPOSE

# File structure verification
Write-Host "Checking created file structure..." -ForegroundColor Magenta
Write-Host "Summary of created files:" -ForegroundColor Cyan

if (Test-Path ".env") {
    Write-Host ".env configuration file" -ForegroundColor Green
} else {
    Write-Host ".env file missing" -ForegroundColor Red
}

if (Test-Path "init.sql") {
    Write-Host "PostgreSQL initialization script" -ForegroundColor Green
} else {
    Write-Host "init.sql missing" -ForegroundColor Red
}

if (Test-Path "docker-compose.yml") {
    Write-Host "Docker Compose configuration" -ForegroundColor Green
} else {
    Write-Host "docker-compose.yml missing" -ForegroundColor Red
}

# Start containers
Write-Host "Starting containers..." -ForegroundColor Magenta
Write-Host "This may take several minutes on first start while Docker downloads images." -ForegroundColor Yellow

docker-compose up -d

Write-Host ""
Write-Host "AI Chat Agent Stack Setup completed!" -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Access credentials:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   n8n Workflow Automation: http://localhost:5678" -ForegroundColor Blue
Write-Host "      Username: admin" -ForegroundColor White
Write-Host "      Password: LocalDev2025!" -ForegroundColor White
Write-Host ""
Write-Host "   PostgreSQL Database: localhost:5432" -ForegroundColor Blue
Write-Host "      Username: postgres" -ForegroundColor White
Write-Host "      Password: supabase_local_dev_pass_2025" -ForegroundColor White
Write-Host ""
Write-Host "   Ollama API: http://localhost:11434" -ForegroundColor Blue
Write-Host "   Open WebUI (Chat): http://localhost:3000" -ForegroundColor Blue
Write-Host ""
Write-Host "Note: The PostgreSQL database already contains all necessary schemas:" -ForegroundColor Yellow
Write-Host "    - auth" -ForegroundColor White
Write-Host "    - storage" -ForegroundColor White
Write-Host "    - realtime" -ForegroundColor White
Write-Host ""
Write-Host "Use the following connection string:" -ForegroundColor Cyan
Write-Host "   postgresql://postgres:supabase_local_dev_pass_2025@localhost:5432/postgres" -ForegroundColor White
Write-Host ""
Write-Host "Happy coding with your AI Chat Agent Stack!" -ForegroundColor Green
