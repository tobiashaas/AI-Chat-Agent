# Supabase UI Extension

This directory contains the configuration files for running Supabase UI alongside the main AI Chat Agent stack.

## Overview

The Supabase UI extension provides:
- A web-based database administration interface
- Authentication management
- Storage management
- API browser

## Usage

To start the Supabase UI:

```bash
docker-compose -f docker-compose-supabase.yml up -d
```

This will launch the Supabase UI and related services in the same network as your main AI Chat Agent stack.

## Access

- **Supabase Studio**: http://localhost:3001
- **API Endpoint**: http://localhost:8000

## Configuration

The default credentials are:

```
# Anonymous Key (for public access)
ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE

# Service Role Key (for administrative access)
SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJzZXJ2aWNlX3JvbGUiLAogICAgImlzcyI6ICJzdXBhYmFzZS1kZW1vIiwKICAgICJpYXQiOiAxNjQxNzY5MjAwLAogICAgImV4cCI6IDE3OTk1MzU2MDAKfQ.DaYlNEoUrrEn2Ig7tqibS-PHK5vgusbcbo7X36XVt4Q
```

## Notes

- The Supabase UI connects to the same PostgreSQL database as your main stack
- Both stacks use the same Docker network (`ai_network`)
- The UI is accessible on port 3001 to avoid conflicts with the Open WebUI
