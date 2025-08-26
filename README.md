# Self-Hosted AI Development Stack mit n8n, PostgreSQL, Supabase & Ollama

Dieses Repository enthält eine vollständige **Docker Compose** Konfiguration, um eine moderne Entwicklungsumgebung für AI, Automatisierung und Datenmanagement lokal bereitzustellen. Alle Services laufen in einem gemeinsamen Docker-Netzwerk und sind sofort einsatzbereit.

---

## Enthaltene Komponenten

- **n8n**: Workflow Automation Tool mit umfangreichen Integrationen  
- **PostgreSQL**: Hauptdatenbank für n8n und separater Memory-DB für AI Agenten  
- **Supabase**: Backend-as-a-Service Plattform (Datenbank, Auth, Storage, Realtime)  
- **Ollama**: Lokaler LLM Server für schnelle AI Modelle  
- **Open WebUI**: Web-Oberfläche für Ollama AI Chat Modelle  

---

## Voraussetzungen

- Docker 
- Docker Compose 
- Mindestens 8 GB RAM, empfohlen SSD und bei Bedarf GPU (für Ollama)  

---

## Installation & Start

1. Repository klonen oder Dateien herunterladen  
2. `.env.example` kopieren zu `.env` und alle sensiblen Daten (Passwörter, Keys) anpassen  
3. Setup-Skript ausführbar machen und ausführen (optional): chmod +x setup.sh ./setup.sh
4. Docker Compose starten: docker-compose up -d
5. 5. Services öffnen:
- n8n: http://localhost:5678  
- Supabase Studio: http://localhost:3001  
- Ollama API: http://localhost:11434  
- Open WebUI: http://localhost:3000  

---

## Konfiguration

- Alle Einstellungen über `.env` Datei steuerbar  
- Datenbanken, Ports und Authentifizierungen sind parametrisiert  
- Sicherstellen, dass Passwörter und JWT-Secrets stark und einzigartig sind  

---

## Ollama Modelle installieren

Um Ollama-Modelle zu nutzen, öffnen Sie ein Terminal im Ollama-Container:
docker exec -it ollama bash
ollama pull llama2
ollama list

---

## Nutzung und Beispiele

- Erstellen Sie AI-Workflows mit n8n, die lokale Ollama LLMs nutzen  
- Nutzen Sie Supabase für Datenhaltung, Authentifizierung und Web-APIs  
- Speichern Sie AI-Chats im separaten Memory-Postgres für Kontext-Speicherung  
- Teilen Sie Dateien per Volume zwischen n8n und Ollama  

---

## Troubleshooting

- Logs anschauen:  
docker-compose logs -f
docker-compose logs n8n

- Container Status prüfen:  
docker-compose ps

- Netzwerk prüfen und Verbindungen sicherstellen  
- Ports in `.env` anpassen, falls Konflikte auftreten  

---

## Sicherheit & Produktion

- Verwenden Sie für den produktiven Einsatz HTTPS über Reverse Proxy (z.B. Nginx, Traefik).  
- Geheimnisse niemals öffentlich speichern.  
- Backup-Strategien für Datenbanken umsetzen.  

---

## Lizenz & Danksagung

Dieses Setup basiert auf Open Source Komponenten:

- [n8n](https://github.com/n8n-io/n8n) – Apache 2.0  
- [Supabase](https://github.com/supabase/supabase) – Apache 2.0  
- [Ollama](https://github.com/ollama/ollama) – MIT  

---

**Viel Erfolg mit Ihrem lokalen AI-Stack! 🚀**
