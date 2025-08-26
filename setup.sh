#!/bin/bash

# Setup Script für n8n + PostgreSQL + Supabase + Ollama Stack

set -e

echo "🚀 Starte Setup für n8n + PostgreSQL + Supabase + Ollama Stack..."

if ! command -v docker &> /dev/null; then
    echo "❌ Docker ist nicht installiert. Bitte installiere Docker zuerst."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose ist nicht installiert. Bitte installiere Docker Compose zuerst."
    exit 1
fi

echo "📁 Erstelle notwendige Verzeichnisse..."
mkdir -p shared-files
mkdir -p supabase/docker/volumes/{db,api,storage,functions}

if [ ! -f .env ]; then
    echo "📄 Kopiere .env.example zu .env..."
    cp .env.example .env
    echo "⚠️  WICHTIG: Bearbeite die .env Datei und fülle alle Werte aus!"
else
    echo "✅ .env Datei bereits vorhanden"
fi

# Supabase Setup (optional)
if [ ! -d "supabase" ]; then
    echo "📦 Lade Supabase Docker Setup herunter..."
    git clone --depth 1 https://github.com/supabase/supabase.git supabase-repo
    cp -r supabase-repo/docker supabase/
    rm -rf supabase-repo
    echo "✅ Supabase Setup heruntergeladen"
fi

echo "🎉 Setup abgeschlossen!"
echo "Starte die Services mit 'docker-compose up -d'"
