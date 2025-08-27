# 🚀 Self-Hosted AI Development Stack

**n8n + PostgreSQL + Ollama - Vereinfachte und verbesserte Version**

Eine komplette Docker Compose-Konfiguration für eine moderne KI-Entwicklungsumgebung. Alle Dienste laufen lokal in einem gemeinsamen Docker-Netzwerk und kommunizieren nahtlos miteinander.

## 📦 Enthaltene Komponenten

| Dienst | Beschreibung | Port | Sicherheitsstufe |
|---------|-------------|------|---------------|
| **n8n** | Workflow Automatisierungsplattform | 5678 | 🔒🔒🔒 |
| **PostgreSQL** | Hauptdatenbank für n8n | - | 🔒🔒🔒 |
| **Memory PostgreSQL** | Separate DB für AI Agent Memory | - | 🔒🔒🔒 |
| **PostgreSQL für Daten** | Vereinfachte Datenbank mit auth/storage-Schemas | 5432 | 🔒🔒🔒 |
| **Ollama** | Lokaler LLM-Server | 11434 | 🔒🔒 |
| **Open WebUI** | Chat-Interface für Ollama | 3000 | 🔒🔒 |

## ⚡ Schnellstart

### 1. Repository klonen

```bash
git clone https://github.com/username/AI-Chat-Agent.git
cd AI-Chat-Agent
```

### 2. Automatisches Setup (Empfohlen)

```bash
# Unter Windows (PowerShell)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
.\setup-automated.ps1
```

### 3. Umgebungsvariablen konfigurieren (optional)

```bash
# Überprüfen und anpassen der automatisch erstellten .env-Datei
notepad .env  # Passwörter und Keys anpassen!
```

### 4. Dienste starten

```bash
docker-compose -f docker-compose-simple.yml up -d
```

### 5. Zugriff auf Dienste

- 🔧 **n8n**: http://localhost:5678
- 🗄️ **PostgreSQL**: localhost:5432
- 🤖 **Ollama API**: http://localhost:11434
- 💬 **Open WebUI**: http://localhost:3000

## 🛠️ Anforderungen

- **Docker** (Version 20.10+)
- **Docker Compose** (Version 2.0+)
- **Minimum 8GB RAM**
- **SSD empfohlen** für bessere Performance
- **NVIDIA GPU** (optional, für Ollama-Performance)

## 🔐 Sicherheitskonfiguration

⚠️ **WICHTIG**: Vor dem ersten Start, die `.env`-Datei anpassen:

### Kritische Einstellungen
```env
# n8n Authentication
N8N_AUTH_USER=your_secure_username
N8N_AUTH_PASSWORD=YourSecurePassword123!
N8N_ENCRYPTION_KEY=YourSuperSecureEncryptionKey32Plus  # 32+ Zeichen

# PostgreSQL
POSTGRES_PASSWORD=YourSuperSecureDatabasePassword123!
```

## 🔧 Sicherheitsverbesserungen

Diese Umgebung wurde mit mehreren Sicherheitsverbesserungen ausgestattet:

1. **Container-Härtung**
   - Alle Container verwenden `no-new-privileges:true`
   - Ordnungsgemäße Ressourcenbeschränkungen
   - Nicht-root-Benutzer wo möglich

2. **Netzwerksicherheit**
   - Isoliertes Bridge-Netzwerk mit Subnet-Definition
   - Minimierte exponierte Ports
   - Eingeschränkte Service-zu-Service-Kommunikation

3. **Datenschutz**
   - Volume-Berechtigungen ordnungsgemäß konfiguriert
   - Schreibgeschützte Mounts wo angemessen
   - Sichere Handhabung sensibler Daten

4. **Überwachung & Wiederherstellung**
   - Zustandsprüfungen für alle kritischen Dienste
   - Ordnungsgemäße Neustart-Richtlinien
   - Strukturierte Protokollierung

## 🔗 Service-Kommunikation

Alle Dienste laufen im `ai_network` Docker-Netzwerk:

| Von n8n zu | Verbindungsstring |
|------------|-------------------|
| PostgreSQL | `postgresql://n8n_user:password@n8n-db:5432/n8n` |
| Memory DB | `postgresql://memory_user:password@memory-db:5432/n8n_memory` |
| Daten DB | `postgresql://postgres:password@postgres-db:5432/postgres` |
| Ollama | `http://ollama:11434` |

## 🤖 Installieren von Ollama-Modellen

Nach dem Start können Sie KI-Modelle installieren:

```bash
# Beliebte Modelle herunterladen
docker exec -it ollama ollama pull llama2
docker exec -it ollama ollama pull mistral
docker exec -it ollama ollama pull codellama

# Verfügbare Modelle auflisten
docker exec -it ollama ollama list

# Interaktiv mit einem Modell chatten
docker exec -it ollama ollama run llama2
```

## 🎯 Anwendungsfälle & Beispiele

### n8n AI Workflows
- **Chatbots** mit lokalen Ollama LLMs
- **Dokumentenverarbeitung** mit KI-Analyse
- **Datenpipelines** mit PostgreSQL-Integration
- **Chat-Speicher** in PostgreSQL gespeichert

### PostgreSQL Datenbank
- **Authentifizierung** und Benutzerverwaltung
- **Datenspeicher** für alle Anwendungsdaten
- **Dateispeicher** im Storage-Schema
- **Metadatenverwaltung** für KI-Assets

### Datenaustausch
- Dateien zwischen Diensten über `./shared-files` Volume teilen
- CSV-Import in n8n, Verarbeitung in Ollama

## 🔧 Verwaltung & Wartung

### Container-Verwaltung
```bash
# Status prüfen
docker-compose -f docker-compose-simple.yml ps

# Dienste stoppen
docker-compose -f docker-compose-simple.yml stop

# Dienste neustarten
docker-compose -f docker-compose-simple.yml restart

# Alle Daten löschen (⚠️ Vorsicht!)
docker-compose -f docker-compose-simple.yml down -v
```

### Logs anzeigen
```bash
# Alle Dienste
docker-compose -f docker-compose-simple.yml logs -f

# Einzelner Dienst
docker-compose -f docker-compose-simple.yml logs -f n8n
docker-compose -f docker-compose-simple.yml logs -f ollama
docker-compose -f docker-compose-simple.yml logs -f postgres-db
```

### Updates durchführen
```bash
# Images aktualisieren
docker-compose -f docker-compose-simple.yml pull

# Mit neuen Images neustarten
docker-compose -f docker-compose-simple.yml up -d --force-recreate
```

## 🚨 Fehlerbehebung

### Häufige Probleme

**Container starten nicht:**
```bash
# Logs überprüfen
docker-compose -f docker-compose-simple.yml logs

# Volumes überprüfen
docker volume ls

# Ports überprüfen
netstat -ano | findstr :5678  # Windows
```

**Datenbankverbindung schlägt fehl:**
```bash
# PostgreSQL Container-Status
docker exec -it postgres-db pg_isready -U postgres

# Netzwerkverbindung testen
docker exec -it n8n ping postgres-db
```

**Portkonflikt lösen:**
```env
# In der .env-Datei anpassen
N8N_PORT=5679
POSTGRES_PORT=5433
OPEN_WEBUI_PORT=3001
```

## 🔒 Produktion & Sicherheit

### Produktions-Checkliste
- [ ] Alle Standardpasswörter geändert
- [ ] SSL/HTTPS mit Reverse Proxy (Nginx/Traefik)
- [ ] Firewall konfiguriert
- [ ] Backup-Strategie implementiert
- [ ] Log-Überwachung eingerichtet
- [ ] `.env` von Git ausgeschlossen

### Empfohlene Sicherheitsmaßnahmen
```bash
# Docker Secrets verwenden (statt .env)
echo "my_password" | docker secret create db_password -

# Netzwerkisolierung
# Nur notwendige Ports exponieren
```

## 🏗️ Projektstruktur

```
AI-Chat-Agent/
├── docker-compose-simple.yml   # Vereinfachte Hauptkonfiguration
├── .env                        # Lokale Umgebungsvariablen
├── setup-automated.ps1         # Windows Setup-Skript
├── shared-files/               # Gemeinsame Dateien zwischen Containern
├── init.sql                    # Datenbank-Initialisierungsskript
├── README.md                   # Diese Datei
└── .gitignore                  # Git Ignore-Regeln
```

## 🔄 Updates & Wartung

### Git Repository aktualisieren
```bash
git pull origin main
docker-compose -f docker-compose-simple.yml pull
docker-compose -f docker-compose-simple.yml up -d --force-recreate
```

### Backup erstellen
```bash
# PostgreSQL Backup
docker exec n8n-postgres pg_dump -U n8n_user n8n > backup_n8n.sql
docker exec postgres-db pg_dump -U postgres postgres > backup_postgres.sql

# Volume Backup
docker run --rm -v n8n_data:/data -v ${PWD}:/backup alpine tar czf /backup/n8n_backup.tar.gz /data
```

## 📦 Automatische Installation

Das Setup-Skript bietet:

1. **Vollständige Konfiguration**: Erstellt alle notwendigen Dateien und Verzeichnisse
2. **Datenbank-Initialisierung**: Richtet PostgreSQL-Schemas und -Tabellen ein
3. **Sicherheitshärtung**: Wendet Sicherheitsmaßnahmen an
4. **Plattformübergreifend**: Funktioniert auf Windows mit PowerShell

## 🔗 PostgreSQL-Verbindungsdetails

### Verbindungsinformationen

| Parameter | Wert |
|-----------|------|
| Host      | localhost |
| Port      | 5432 |
| Datenbank | postgres |
| Benutzer  | postgres |
| Passwort  | supabase_local_dev_pass_2025 |

### Verbindungs-String

```
postgresql://postgres:supabase_local_dev_pass_2025@localhost:5432/postgres
```

### Eingerichtete Schemata

- `auth` - Für Authentifizierung und Benutzerkonten
- `storage` - Für Dateiablage
- `realtime` - Für Echtzeit-Updates

### Wichtige Tabellen

- `auth.users` - Benutzerkonten
- `storage.buckets` - Speicher-Bucket-Definitionen
- `storage.objects` - Gespeicherte Dateien

## 📄 Lizenz & Credits

Basierend auf den folgenden Open-Source-Projekten:

- **[n8n](https://github.com/n8n-io/n8n)** - Apache 2.0 Lizenz
- **[PostgreSQL](https://www.postgresql.org/)** - PostgreSQL Lizenz
- **[Ollama](https://github.com/ollama/ollama)** - MIT Lizenz

---

## 🎉 Viel Spaß mit Ihrem lokalen KI-Stack!

**Fragen oder Feedback? Bitte erstellen Sie ein Issue! 🚀**

---

*Entwickelt mit ❤️ für die Open-Source-KI-Community*
