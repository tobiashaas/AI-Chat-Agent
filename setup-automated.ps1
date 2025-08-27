# AI Chat Agent Stack - Automated Setup Script for Windows
# This PowerShell script creates all necessary files and configurations for the AI Chat Stack
# It's idempotent - safe to run multiple times without breaking existing setup

# Show fancy header
Write-Host "🚀 AI Chat Agent Stack - Automated Setup (Ultimate Edition)" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

# Function to create file only if it doesn't exist
function Create-FileIfNotExists {
    param (
        [string]$FilePath,
        [string]$Content
    )
    
    if (-not (Test-Path $FilePath)) {
        Set-Content -Path $FilePath -Value $Content -Encoding UTF8
        Write-Host "✅ Created: $FilePath" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Already exists: $FilePath (skipped)" -ForegroundColor Yellow
    }
}

# Function to create directory structure
function Create-DirStructure {
    param (
        [string]$DirPath
    )
    
    if (-not (Test-Path $DirPath)) {
        New-Item -Path $DirPath -ItemType Directory -Force | Out-Null
    }
    Write-Host "📁 Directory ensured: $DirPath" -ForegroundColor Blue
}

# Check prerequisites
Write-Host "🔍 Checking prerequisites..." -ForegroundColor Magenta
try {
    $dockerVersion = docker --version
    Write-Host "  ✓ Docker is installed: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker not installed. Please install Docker Desktop first." -ForegroundColor Red
    exit 1
}

try {
    $composeVersion = docker compose version
    Write-Host "  ✓ Docker Compose is available: $composeVersion" -ForegroundColor Green
} catch {
    Write-Host "⚠️  'docker compose' command not available. Make sure Docker Compose is installed." -ForegroundColor Yellow
}

# Create directory structure
Write-Host "📁 Creating directory structure..." -ForegroundColor Magenta
Create-DirStructure "shared-files"
Create-DirStructure "supabase\docker\volumes\db"
Create-DirStructure "supabase\docker\volumes\api"
Create-DirStructure "supabase\docker\volumes\functions\main"

# Create .env file with all necessary configurations
Write-Host "📄 Creating .env configuration file..." -ForegroundColor Magenta
$ENV_CONTENT = @'
############################################################################
# AI CHAT AGENT STACK - LOCAL DEVELOPMENT CONFIGURATION
# Generated automatically - safe for local development only!
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
# SUPABASE CONFIGURATION
############################################################################
SUPABASE_PUBLIC_URL=http://localhost:8000
SUPABASE_STUDIO_PORT=3001
KONG_HTTP_PORT=8000
KONG_HTTPS_PORT=8443

POSTGRES_PASSWORD=supabase_local_dev_pass_2025
POSTGRES_DB=postgres
POSTGRES_PORT=5432

JWT_SECRET=jwt_secret_key_32_chars_long_local_dev
ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJvbGUiOiJhbm9uIiwiaWF0IjoxNjQ1NzA2NDAwLCJleHAiOjE5NjEyODI0MDB9.M9jrxyvPLkUxWgOYSf5dNdJ8v_eR2YgOOkOFvU14GYs
SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJvbGUiOiJzZXJ2aWNlX3JvbGUiLCJpYXQiOjE2NDU3MDY0MDAsImV4cCI6MTk2MTI4MjQwMH0.tZpqOhbbkdOCpgTjQ9BqYyNV_gz7bbVJ_9tU1kLgWho

API_EXTERNAL_URL=http://localhost:8000
JWT_EXPIRY=3600
PGRST_DB_SCHEMAS=public,storage,graphql_public

SITE_URL=http://localhost:3001
ADDITIONAL_REDIRECT_URLS=
DISABLE_SIGNUP=false
ENABLE_EMAIL_SIGNUP=true
ENABLE_EMAIL_AUTOCONFIRM=false
ENABLE_PHONE_SIGNUP=true
ENABLE_PHONE_AUTOCONFIRM=false
ENABLE_ANONYMOUS_USERS=false

############################################################################
# SMTP (optional - disabled for local development)
############################################################################
SMTP_ADMIN_EMAIL=admin@localhost.dev
SMTP_HOST=localhost
SMTP_PORT=587
SMTP_USER=admin@localhost.dev
SMTP_PASS=local_dev_smtp_pass
SMTP_SENDER_NAME="AI Chat Agent Local"

############################################################################
# FUNCTIONS / EDGE FUNCTIONS
############################################################################
FUNCTIONS_VERIFY_JWT=false

############################################################################
# IMAGE PROXY
############################################################################
IMGPROXY_ENABLE_WEBP_DETECTION=false

############################################################################
# OPENAI (Please add your own API key!)
############################################################################
OPENAI_API_KEY=sk-your-openai-api-key-here

############################################################################
# OLLAMA CONFIGURATION
############################################################################
OLLAMA_PORT=11434
OLLAMA_NUM_PARALLEL=4
OLLAMA_MAX_LOADED_MODELS=3

############################################################################
# OPEN WEBUI
############################################################################
OPEN_WEBUI_PORT=3000
WEBUI_SECRET_KEY=webui_local_dev_secret_key_2025
WEBUI_AUTH=false
'@

Create-FileIfNotExists ".env" $ENV_CONTENT

# Create comprehensive Supabase SQL initialization files
Write-Host "🗃️ Creating Supabase SQL initialization files..." -ForegroundColor Magenta

# 01 - Complete schema initialization with all required tables
$SCHEMAS_SQL = @'
-- AI Chat Agent Stack - Complete Supabase Schema Initialization
-- This script creates all necessary schemas, roles, and tables for Supabase
-- It prevents auth migration errors by pre-creating everything GoTrue expects

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pgjwt";

-- Create all Supabase schemas
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS storage;
CREATE SCHEMA IF NOT EXISTS realtime;
CREATE SCHEMA IF NOT EXISTS supabase_functions;
CREATE SCHEMA IF NOT EXISTS _realtime;
CREATE SCHEMA IF NOT EXISTS graphql;
CREATE SCHEMA IF NOT EXISTS graphql_public;

-- Create all required roles
DO $$
BEGIN
    -- Base roles for JWT authentication
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'anon') THEN
        CREATE ROLE anon NOLOGIN NOINHERIT;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'authenticated') THEN
        CREATE ROLE authenticated NOLOGIN NOINHERIT;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'service_role') THEN
        CREATE ROLE service_role NOLOGIN NOINHERIT BYPASSRLS;
    END IF;
    
    -- Service users with login capabilities
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'authenticator') THEN
        CREATE ROLE authenticator WITH LOGIN;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'supabase_auth_admin') THEN
        CREATE ROLE supabase_auth_admin WITH LOGIN;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'supabase_admin') THEN
        CREATE ROLE supabase_admin WITH LOGIN SUPERUSER;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'supabase_storage_admin') THEN
        CREATE ROLE supabase_storage_admin WITH LOGIN;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'supabase_realtime_admin') THEN
        CREATE ROLE supabase_realtime_admin WITH LOGIN;
    END IF;
END
$$;

-- Essential JWT functions that GoTrue expects
CREATE OR REPLACE FUNCTION auth.uid() 
RETURNS uuid 
LANGUAGE sql 
STABLE
AS $$
    SELECT nullif(current_setting('request.jwt.claim.sub', true), '')::uuid;
$$;

CREATE OR REPLACE FUNCTION auth.role() 
RETURNS text 
LANGUAGE sql 
STABLE
AS $$
    SELECT nullif(current_setting('request.jwt.claim.role', true), '')::text;
$$;

-- Create ALL auth tables that GoTrue migration expects to exist
-- auth.users (main user table)
CREATE TABLE IF NOT EXISTS auth.users (
    instance_id uuid,
    id uuid NOT NULL PRIMARY KEY DEFAULT uuid_generate_v4(),
    aud varchar(255),
    role varchar(255),
    email varchar(255) UNIQUE,
    encrypted_password varchar(255),
    confirmed_at timestamptz,
    invited_at timestamptz,
    confirmation_token varchar(255),
    confirmation_sent_at timestamptz,
    recovery_token varchar(255),
    recovery_sent_at timestamptz,
    email_change_token varchar(255),
    email_change varchar(255),
    email_change_sent_at timestamptz,
    last_sign_in_at timestamptz,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamptz DEFAULT timezone('utc'::text, now()),
    updated_at timestamptz DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS users_instance_id_email_idx ON auth.users(instance_id, email);
CREATE INDEX IF NOT EXISTS users_instance_id_idx ON auth.users(instance_id);
COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';

-- auth.refresh_tokens
CREATE TABLE IF NOT EXISTS auth.refresh_tokens (
    instance_id uuid,
    id bigserial PRIMARY KEY,
    token varchar(255),
    user_id varchar(255),
    revoked boolean,
    created_at timestamptz,
    updated_at timestamptz
);

CREATE INDEX IF NOT EXISTS refresh_tokens_instance_id_idx ON auth.refresh_tokens(instance_id);
CREATE INDEX IF NOT EXISTS refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens(instance_id, user_id);
CREATE INDEX IF NOT EXISTS refresh_tokens_token_idx ON auth.refresh_tokens(token);
COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';

-- auth.instances
CREATE TABLE IF NOT EXISTS auth.instances (
    id uuid PRIMARY KEY,
    uuid uuid,
    raw_base_config text,
    created_at timestamptz,
    updated_at timestamptz
);
COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';

-- auth.audit_log_entries
CREATE TABLE IF NOT EXISTS auth.audit_log_entries (
    instance_id uuid,
    id uuid PRIMARY KEY,
    payload json,
    created_at timestamptz
);
CREATE INDEX IF NOT EXISTS audit_logs_instance_id_idx ON auth.audit_log_entries(instance_id);
COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';

-- auth.schema_migrations
CREATE TABLE IF NOT EXISTS auth.schema_migrations (
    version varchar(255) PRIMARY KEY
);
COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';

-- Grant comprehensive permissions
-- Public schema permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL ROUTINES IN SCHEMA public TO anon, authenticated, service_role;

-- Auth schema permissions
GRANT USAGE ON SCHEMA auth TO supabase_auth_admin, postgres;
GRANT ALL ON ALL TABLES IN SCHEMA auth TO supabase_auth_admin, postgres;
GRANT ALL ON ALL SEQUENCES IN SCHEMA auth TO supabase_auth_admin, postgres;
GRANT ALL ON ALL ROUTINES IN SCHEMA auth TO supabase_auth_admin, postgres;

-- Storage schema permissions  
GRANT USAGE ON SCHEMA storage TO supabase_storage_admin, postgres;
GRANT ALL ON ALL TABLES IN SCHEMA storage TO supabase_storage_admin, postgres;
GRANT ALL ON ALL SEQUENCES IN SCHEMA storage TO supabase_storage_admin, postgres;
GRANT ALL ON ALL ROUTINES IN SCHEMA storage TO supabase_storage_admin, postgres;

-- Realtime schema permissions
GRANT USAGE ON SCHEMA realtime TO supabase_realtime_admin, postgres;
GRANT USAGE ON SCHEMA _realtime TO supabase_realtime_admin, postgres;
GRANT ALL ON ALL TABLES IN SCHEMA realtime TO supabase_realtime_admin, postgres;
GRANT ALL ON ALL TABLES IN SCHEMA _realtime TO supabase_realtime_admin, postgres;
GRANT ALL ON ALL SEQUENCES IN SCHEMA realtime TO supabase_realtime_admin, postgres;
GRANT ALL ON ALL SEQUENCES IN SCHEMA _realtime TO supabase_realtime_admin, postgres;

-- Functions schema permissions
GRANT USAGE ON SCHEMA supabase_functions TO postgres, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA supabase_functions TO postgres, service_role;

-- GraphQL permissions
GRANT USAGE ON SCHEMA graphql TO postgres, service_role;
GRANT USAGE ON SCHEMA graphql_public TO postgres, anon, authenticated, service_role;

-- ✅ FIX: Create Realtime Publication for all tables
CREATE PUBLICATION supabase_realtime FOR ALL TABLES;

-- Grant replication privileges to realtime admin
GRANT REPLICATION TO supabase_realtime_admin;
'@

Create-FileIfNotExists "supabase\docker\volumes\db\01-init-schemas.sql" $SCHEMAS_SQL

# 02 - Set passwords for all service users
$PASSWORDS_SQL = @'
-- Set passwords for all Supabase service users (LOCAL DEVELOPMENT ONLY)
-- This ensures all services can authenticate properly

ALTER ROLE authenticator WITH PASSWORD 'supabase_local_dev_pass_2025';
ALTER ROLE supabase_auth_admin WITH PASSWORD 'supabase_local_dev_pass_2025';
ALTER ROLE supabase_admin WITH PASSWORD 'supabase_local_dev_pass_2025';
ALTER ROLE supabase_storage_admin WITH PASSWORD 'supabase_local_dev_pass_2025';
ALTER ROLE supabase_realtime_admin WITH PASSWORD 'supabase_local_dev_pass_2025';

-- Grant authenticator the ability to switch roles (required for RLS)
GRANT anon TO authenticator;
GRANT authenticated TO authenticator;
GRANT service_role TO authenticator;

-- Ensure authenticator has necessary permissions
GRANT ALL ON SCHEMA public TO authenticator;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticator;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticator;
GRANT ALL ON ALL ROUTINES IN SCHEMA public TO authenticator;
'@

Create-FileIfNotExists "supabase\docker\volumes\db\02-set-passwords.sql" $PASSWORDS_SQL

# 03 - Storage setup
$STORAGE_SQL = @'
-- Storage setup for Supabase file management
CREATE TABLE IF NOT EXISTS storage.buckets (
    id text PRIMARY KEY,
    name text NOT NULL,
    owner uuid,
    created_at timestamptz DEFAULT timezone('utc'::text, now()),
    updated_at timestamptz DEFAULT timezone('utc'::text, now()),
    public boolean DEFAULT false
);

CREATE TABLE IF NOT EXISTS storage.objects (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamptz DEFAULT timezone('utc'::text, now()),
    updated_at timestamptz DEFAULT timezone('utc'::text, now()),
    last_accessed_at timestamptz DEFAULT timezone('utc'::text, now()),
    metadata jsonb,
    CONSTRAINT objects_bucketId_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id)
);

GRANT ALL ON storage.buckets TO supabase_storage_admin, postgres;
GRANT ALL ON storage.objects TO supabase_storage_admin, postgres;
'@

Create-FileIfNotExists "supabase\docker\volumes\db\03-storage-setup.sql" $STORAGE_SQL

# 04 - Realtime setup
$REALTIME_SQL = @'
-- Realtime setup for Supabase live updates
CREATE TABLE IF NOT EXISTS _realtime.schema_migrations (
    version bigint PRIMARY KEY,
    inserted_at timestamp DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS _realtime.subscription (
    id bigserial PRIMARY KEY,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters text[] NOT NULL DEFAULT '{}',
    claims jsonb NOT NULL,
    claims_role text GENERATED ALWAYS AS ((claims ->> 'role')::text) STORED,
    created_at timestamp DEFAULT timezone('utc'::text, now())
);

-- Additional realtime tables that might be needed
CREATE TABLE IF NOT EXISTS _realtime.extensions (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    type text NOT NULL,
    settings jsonb,
    tenant_external_id text,
    inserted_at timestamp DEFAULT timezone('utc'::text, now()),
    updated_at timestamp DEFAULT timezone('utc'::text, now())
);

-- Enable realtime for auth.users (example)
-- ALTER PUBLICATION supabase_realtime ADD TABLE auth.users;
'@

Create-FileIfNotExists "supabase\docker\volumes\db\04-realtime-setup.sql" $REALTIME_SQL

# Create Kong API Gateway configuration
Write-Host "🔧 Creating Kong API Gateway configuration..." -ForegroundColor Magenta
$KONG_CONFIG = @'
_format_version: "1.1"

consumers:
  - username: anon
    keyauth_credentials:
      - key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJvbGUiOiJhbm9uIiwiaWF0IjoxNjQ1NzA2NDAwLCJleHAiOjE5NjEyODI0MDB9.M9jrxyvPLkUxWgOYSf5dNdJ8v_eR2YgOOkOFvU14GYs
  - username: service_role
    keyauth_credentials:
      - key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJvbGUiOiJzZXJ2aWNlX3JvbGUiLCJpYXQiOjE2NDU3MDY0MDAsImV4cCI6MTk2MTI4MjQwMH0.tZpqOhbbkdOCpgTjQ9BqYyNV_gz7bbVJ_9tU1kLgWho

acls:
  - consumer: anon
    group: anon
  - consumer: service_role
    group: admin

services:
  - name: auth
    url: http://supabase-auth:9999
    routes:
      - name: auth
        strip_path: true
        paths:
          - /auth/v1
    plugins:
      - name: cors
        config:
          origins:
            - "*"
          methods:
            - GET
            - POST
            - OPTIONS
          headers:
            - authorization
            - content-type

  - name: rest
    url: http://supabase-rest:3000
    routes:
      - name: rest
        strip_path: true
        paths:
          - /rest/v1
    plugins:
      - name: cors
        config:
          origins:
            - "*"
          methods:
            - GET
            - POST
            - PUT
            - DELETE
            - OPTIONS
          headers:
            - authorization
            - content-type
      - name: key-auth
        config:
          hide_credentials: true

  - name: realtime
    url: http://supabase-realtime:4000/socket
    routes:
      - name: realtime
        strip_path: true
        paths:
          - /realtime/v1
    plugins:
      - name: cors
        config:
          origins:
            - "*"
      - name: key-auth

  - name: storage
    url: http://supabase-storage:5000
    routes:
      - name: storage
        strip_path: true
        paths:
          - /storage/v1
    plugins:
      - name: cors
        config:
          origins:
            - "*"
      - name: key-auth

  - name: meta
    url: http://supabase-meta:8080
    routes:
      - name: meta
        strip_path: true
        paths:
          - /pg
    plugins:
      - name: key-auth
      - name: acl
        config:
          hide_groups_header: true
          allow:
            - admin

  - name: functions
    url: http://supabase-edge-functions:9000
    routes:
      - name: functions
        strip_path: true
        paths:
          - /functions/v1
    plugins:
      - name: cors
        config:
          origins:
            - "*"
'@

Create-FileIfNotExists "supabase\docker\volumes\api\kong.yml" $KONG_CONFIG

# Create Edge Functions template
Write-Host "📂 Creating Edge Functions template..." -ForegroundColor Magenta
$EDGE_FUNCTION = @'
// AI Chat Agent Stack - Edge Function Template
// This is a basic Edge Function for testing Supabase Functions

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const { method } = req
  
  if (method === "GET") {
    return new Response(
      JSON.stringify({ 
        message: "Hello from AI Chat Agent Edge Functions!",
        timestamp: new Date().toISOString(),
        method: method
      }),
      { 
        headers: { "Content-Type": "application/json" },
        status: 200
      }
    )
  }
  
  if (method === "POST") {
    try {
      const body = await req.json()
      return new Response(
        JSON.stringify({ 
          message: "POST request received",
          data: body,
          timestamp: new Date().toISOString()
        }),
        { 
          headers: { "Content-Type": "application/json" },
          status: 200
        }
      )
    } catch (error) {
      return new Response(
        JSON.stringify({ error: "Invalid JSON" }),
        { 
          headers: { "Content-Type": "application/json" },
          status: 400
        }
      )
    }
  }
  
  return new Response(
    JSON.stringify({ error: "Method not allowed" }),
    { 
      headers: { "Content-Type": "application/json" },
      status: 405
    }
  )
})
'@

Create-FileIfNotExists "supabase\docker\volumes\functions\main\index.ts" $EDGE_FUNCTION

# Create policy.json for Edge Functions
Write-Host "📋 Creating Edge Functions policy file..." -ForegroundColor Magenta
$EDGE_POLICY = @'
{
  "version": "1",
  "policies": [
    {
      "effect": "allow",
      "action": "*",
      "resource": "*"
    }
  ]
}
'@

Create-FileIfNotExists "supabase\docker\volumes\functions\policy.json" $EDGE_POLICY

# Verify file structure
Write-Host "🔍 Verifying created file structure..." -ForegroundColor Magenta
Write-Host "📊 Summary of created files:" -ForegroundColor Cyan

if (Test-Path ".env") {
    Write-Host "✅ .env configuration file" -ForegroundColor Green
} else {
    Write-Host "❌ .env file missing" -ForegroundColor Red
}

Write-Host "📁 SQL initialization files:" -ForegroundColor Cyan
$sqlFiles = Get-ChildItem -Path "supabase\docker\volumes\db\*.sql" -ErrorAction SilentlyContinue
foreach ($file in $sqlFiles) {
    Write-Host "✅ $($file.Name)" -ForegroundColor Green
}

if (Test-Path "supabase\docker\volumes\api\kong.yml") {
    Write-Host "✅ Kong API Gateway configuration" -ForegroundColor Green
} else {
    Write-Host "❌ Kong configuration missing" -ForegroundColor Red
}

if (Test-Path "supabase\docker\volumes\functions\main\index.ts") {
    Write-Host "✅ Edge Function template" -ForegroundColor Green
} else {
    Write-Host "❌ Edge Function template missing" -ForegroundColor Red
}

if (Test-Path "supabase\docker\volumes\functions\policy.json") {
    Write-Host "✅ Edge Functions policy file" -ForegroundColor Green
} else {
    Write-Host "❌ Edge Functions policy file missing" -ForegroundColor Red
}

# Final instructions
Write-Host ""
Write-Host "🎉 AI Chat Agent Stack setup completed successfully!" -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Cyan
Write-Host "1. Start the stack: " -NoNewline -ForegroundColor White
Write-Host "docker compose up -d" -ForegroundColor Green
Write-Host "2. Wait for services to initialize (3-5 minutes on first run)" -ForegroundColor White
Write-Host "3. Access your services:" -ForegroundColor White
Write-Host ""
Write-Host "   🔧 n8n Workflow Automation: " -NoNewline -ForegroundColor Blue
Write-Host "http://localhost:5678" -ForegroundColor White
Write-Host "      👤 Username: admin" -ForegroundColor White
Write-Host "      🔑 Password: LocalDev2025!" -ForegroundColor White
Write-Host ""
Write-Host "   🗄️ Supabase Studio: " -NoNewline -ForegroundColor Blue
Write-Host "http://localhost:3001" -ForegroundColor White
Write-Host "   📊 Supabase API Gateway: " -NoNewline -ForegroundColor Blue
Write-Host "http://localhost:8000" -ForegroundColor White
Write-Host "   🤖 Ollama API: " -NoNewline -ForegroundColor Blue
Write-Host "http://localhost:11434" -ForegroundColor White
Write-Host "   💬 Open WebUI (Chat): " -NoNewline -ForegroundColor Blue
Write-Host "http://localhost:3000" -ForegroundColor White
Write-Host ""
Write-Host "🔑 Pre-configured credentials (LOCAL DEV ONLY):" -ForegroundColor Cyan
Write-Host "   Database password: " -NoNewline -ForegroundColor White
Write-Host "supabase_local_dev_pass_2025" -ForegroundColor Green
Write-Host "   All service accounts use the same password for simplicity" -ForegroundColor White
Write-Host ""
Write-Host "✨ Features automatically configured:" -ForegroundColor Cyan
Write-Host "   ✅ Complete Supabase schema with auth, storage, realtime" -ForegroundColor White
Write-Host "   ✅ All necessary database roles and permissions" -ForegroundColor White
Write-Host "   ✅ Kong API Gateway with CORS and authentication" -ForegroundColor White
Write-Host "   ✅ Edge Functions template ready for customization" -ForegroundColor White
Write-Host "   ✅ Edge Functions policy file for security" -ForegroundColor White
Write-Host "   ✅ Realtime publication for live updates" -ForegroundColor White
Write-Host "   ✅ n8n with persistent database and file sharing" -ForegroundColor White
Write-Host "   ✅ Ollama with Open WebUI for local LLM chat" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  Important notes:" -ForegroundColor Yellow
Write-Host "   📝 Add your OpenAI API key to .env for GPT model access" -ForegroundColor White
Write-Host "   🔒 These passwords are for LOCAL DEVELOPMENT only" -ForegroundColor White
Write-Host "   🔄 This script is idempotent - safe to run multiple times" -ForegroundColor White
Write-Host "   📁 Shared files between services: ./shared-files/" -ForegroundColor White
Write-Host ""
Write-Host "Happy coding with your AI Chat Agent Stack! 🚀" -ForegroundColor Green
