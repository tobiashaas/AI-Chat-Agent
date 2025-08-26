# 🚀 Self-Hosted AI Development Stack

**n8n + PostgreSQL + Supabase + Ollama**

Dieses Repository enthält eine vollständige **Docker Compose** Konfiguration für eine moderne AI-Entwicklungsumgebung. Alle Services laufen lokal in einem gemeinsamen Docker-Netzwerk und können nahtlos miteinander kommunizieren.

## 📦 Enthaltene Komponenten

| Service | Beschreibung | Port |
|---------|--------------|------|
| **n8n** | Workflow Automation Platform | 5678 |
| **PostgreSQL** | Hauptdatenbank für n8n | - |
| **Memory PostgreSQL** | Separate DB für AI Agent Memory | - |
| **Supabase** | Complete Backend-as-a-Service | 3001, 8000 |
| **Ollama** | Lokaler LLM Server | 11434 |
| **Open WebUI** | Chat Interface für Ollama | 3000 |

## ⚡ Quick Start

### 1. Repository klonen

```bash
git clone https://github.com/tobiashaas/AI-Chat-Agent.git
cd AI-Chat-Agent
```

### 2. Environment Variables konfigurieren

```bash
cp .env.example .env
nano .env  # Alle Passwörter und Keys anpassen!
```

### 3. Setup ausführen (Optional)

```bash
chmod +x setup.sh
./setup.sh
```

### 4. Services starten

```bash
docker-compose up -d
```

### 5. Services aufrufen

- 🔧 **n8n**: http://localhost:5678
- 🗄️ **Supabase Studio**: http://localhost:3001
- 🤖 **Ollama API**: http://localhost:11434
- 💬 **Open WebUI**: http://localhost:3000
- 📊 **Supabase API**: http://localhost:8000

## 🛠️ Voraussetzungen

- **Docker** (Version 20.10+)
- **Docker Compose** (Version 2.0+)
- **Mindestens 8 GB RAM**
- **SSD empfohlen** für bessere Performance
- **NVIDIA GPU** (optional, für Ollama Performance)

## 🔐 Sicherheitskonfiguration

⚠️ **WICHTIG**: Vor dem ersten Start unbedingt in der `.env` Datei anpassen:

### Kritische Einstellungen
```env
# n8n Authentifizierung
N8N_AUTH_USER=admin
N8N_AUTH_PASSWORD=IhrSicheresPasswort123!
N8N_ENCRYPTION_KEY=IhrSuperSicheresVerschluesselungsKey  # 32+ Zeichen

# Supabase
POSTGRES_PASSWORD=IhrSuperSicheresSupabasePasswort123!
JWT_SECRET=IhrSuperGeheimesJWTSecretMit32PlusZeichen123  # 32+ Zeichen
ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## 🔗 Service-Kommunikation

Alle Services laufen im `ai_network` Docker-Netzwerk:

| Von n8n zu | Connection String |
|------------|-------------------|
| PostgreSQL | `postgresql://n8n_user:password@n8n-db:5432/n8n` |
| Memory DB | `postgresql://memory_user:password@memory-db:5432/n8n_memory` |
| Supabase | `http://supabase-kong:8000/rest/v1/` |
| Ollama | `http://ollama:11434` |

## 🤖 Ollama Modelle installieren

Nach dem Start können Sie AI-Modelle installieren:

```bash
# Beliebte Modelle herunterladen
docker exec -it ollama ollama pull llama2
docker exec -it ollama ollama pull mistral
docker exec -it ollama ollama pull codellama

# Verfügbare Modelle anzeigen
docker exec -it ollama ollama list

# Interaktiv mit Modell chatten
docker exec -it ollama ollama run llama2
```

## 🎯 Use Cases & Beispiele

### n8n AI Workflows
- **Chatbots** mit lokalen Ollama LLMs
- **Document Processing** mit AI-Analyse
- **Data Pipeline** mit Supabase Integration
- **Chat Memory** in PostgreSQL speichern

### Supabase Backend
- **User Authentication** und Management
- **REST APIs** für Datenabfragen
- **File Storage** und Management
- **Realtime Updates** via WebSockets

### File Sharing
- Dateien über `./shared-files` Volume zwischen Services teilen
- CSV-Import in n8n, Verarbeitung in Ollama

## 🔧 Management & Wartung

### Container verwalten
```bash
# Status prüfen
docker-compose ps

# Services stoppen
docker-compose stop

# Services neu starten
docker-compose restart

# Alle Daten löschen (⚠️ Vorsicht!)
docker-compose down -v
```

### Logs anzeigen
```bash
# Alle Services
docker-compose logs -f

# Einzelner Service
docker-compose logs -f n8n
docker-compose logs -f ollama
docker-compose logs -f supabase-db
```

### Updates durchführen
```bash
# Images aktualisieren
docker-compose pull

# Mit neuen Images neu starten
docker-compose up -d --force-recreate
```

## 🚨 Troubleshooting

### Häufige Probleme

**Container starten nicht:**
```bash
# Logs prüfen
docker-compose logs

# Volumes prüfen
docker volume ls

# Ports prüfen
netstat -tulpn | grep :5678
```

**Datenbankverbindung fehlschlägt:**
```bash
# PostgreSQL Container Status
docker exec -it n8n-postgres pg_isready -U n8n_user

# Netzwerk-Konnektivität testen
docker exec -it n8n ping n8n-db
```

**Port-Konflikte lösen:**
```env
# In .env Datei anpassen
N8N_PORT=5679
SUPABASE_STUDIO_PORT=3002
KONG_HTTP_PORT=8001
```

## 🔒 Produktion & Sicherheit

### Produktions-Checkliste
- [ ] Alle Standard-Passwörter geändert
- [ ] SSL/HTTPS mit Reverse Proxy (Nginx/Traefik)
- [ ] Firewall konfiguriert
- [ ] Backup-Strategie implementiert
- [ ] Log-Monitoring eingerichtet
- [ ] `.env` aus Git ausgeschlossen

### Empfohlene Sicherheitsmaßnahmen
```bash
# Docker Secrets verwenden (statt .env)
echo "mein_passwort" | docker secret create db_password -

# Netzwerk-Isolation
# Nur notwendige Ports exponieren
```

## 🏗️ Projektstruktur

```
AI-Chat-Agent/
├── docker-compose.yml          # Haupt-Konfiguration
├── .env.example               # Environment Variables Template
├── .env                       # Ihre lokalen Variablen (nicht in Git)
├── setup.sh                   # Automatisches Setup-Script
├── shared-files/              # Geteilte Dateien zwischen Containern
├── supabase/                  # Supabase Konfiguration
│   └── docker/volumes/
├── README.md                  # Diese Datei
└── .gitignore                 # Git Ignore Regeln
```

## 🔄 Updates & Wartung

### Git Repository aktualisieren
```bash
git pull origin main
docker-compose pull
docker-compose up -d --force-recreate
```

### Backup erstellen
```bash
# PostgreSQL Backup
docker exec n8n-postgres pg_dump -U n8n_user n8n > backup_n8n.sql
docker exec supabase-postgres pg_dump -U postgres postgres > backup_supabase.sql

# Volumes sichern
docker run --rm -v n8n_data:/data -v $(pwd):/backup alpine tar czf /backup/n8n_backup.tar.gz /data
```

## 🤝 Contribution & Support

### Bei Problemen
1. **Issues** in diesem Repository erstellen
2. **Logs** mit `docker-compose logs` prüfen
3. **Konfiguration** in `.env` validieren

### Verbesserungen vorschlagen
- Pull Requests sind willkommen
- Feature Requests via Issues

## 📄 Lizenz & Credits

Basiert auf folgenden Open Source Projekten:

- **[n8n](https://github.com/n8n-io/n8n)** - Apache 2.0 License
- **[Supabase](https://github.com/supabase/supabase)** - Apache 2.0 License  
- **[Ollama](https://github.com/ollama/ollama)** - MIT License
- **[PostgreSQL](https://www.postgresql.org/)** - PostgreSQL License

---

## 🎉 Viel Erfolg mit Ihrem lokalen AI-Stack!

**Haben Sie Fragen oder Feedback? Erstellen Sie gerne ein Issue! 🚀**

---

*Entwickelt mit ❤️ für die Open Source AI Community*
