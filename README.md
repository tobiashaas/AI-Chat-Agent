# 🚀 Self-Hosted AI Development Stack

**n8n + PostgreSQL + Supabase + Ollama - Security Enhanced Version**

A complete Docker Compose configuration for a modern AI development environment. All services run locally in a shared Docker network and communicate seamlessly with each other.

## 📦 Included Components

| Service | Description | Port | Security Level |
|---------|-------------|------|---------------|
| **n8n** | Workflow Automation Platform | 5678 | 🔒🔒🔒 |
| **PostgreSQL** | Main database for n8n | - | 🔒🔒🔒 |
| **Memory PostgreSQL** | Separate DB for AI Agent Memory | - | 🔒🔒🔒 |
| **Supabase** | Complete Backend-as-a-Service | 3001, 8000 | 🔒🔒🔒 |
| **Ollama** | Local LLM Server | 11434 | 🔒🔒 |
| **Open WebUI** | Chat Interface for Ollama | 3000 | 🔒🔒 |

## ⚡ Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/username/AI-Chat-Agent.git
cd AI-Chat-Agent
```

### 2. Automated setup (Recommended)

```bash
# On Linux/macOS
chmod +x setup-automated.sh
./setup-automated.sh

# On Windows (PowerShell)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
.\setup-automated.ps1
```

### 3. Configure environment variables

```bash
# Review and adjust the automatically created .env file
nano .env  # Adjust passwords and keys!
```

### 4. Start services

```bash
docker compose up -d
```

### 5. Access services

- 🔧 **n8n**: http://localhost:5678
- 🗄️ **Supabase Studio**: http://localhost:3001
- 🤖 **Ollama API**: http://localhost:11434
- 💬 **Open WebUI**: http://localhost:3000
- 📊 **Supabase API**: http://localhost:8000

## 🛠️ Requirements

- **Docker** (Version 20.10+)
- **Docker Compose** (Version 2.0+)
- **Minimum 8GB RAM**
- **SSD recommended** for better performance
- **NVIDIA GPU** (optional, for Ollama performance)

## 🔐 Security Configuration

⚠️ **IMPORTANT**: Before first start, adjust the `.env` file:

### Critical Settings
```env
# n8n Authentication
N8N_AUTH_USER=your_secure_username
N8N_AUTH_PASSWORD=YourSecurePassword123!
N8N_ENCRYPTION_KEY=YourSuperSecureEncryptionKey32Plus  # 32+ characters

# Supabase
POSTGRES_PASSWORD=YourSuperSecureSupabasePassword123!
JWT_SECRET=YourSuperSecretJWTWith32PlusChars123  # 32+ characters
```

## 🔧 Security Enhancements

This stack has been enhanced with multiple security improvements:

1. **Container Hardening**
   - All containers use `no-new-privileges:true`
   - Proper resource constraints applied
   - Non-root users where possible

2. **Network Security**
   - Isolated bridge network with subnet definition
   - Minimized exposed ports
   - Restricted service-to-service communication

3. **Data Protection**
   - Volume permissions properly configured
   - Read-only mounts where appropriate
   - Secure handling of sensitive data

4. **Service Configuration**
   - Disabled telemetry and analytics
   - Rate limiting enabled
   - Proper JWT refresh token rotation
   - Strong password policies

5. **Monitoring & Recovery**
   - Health checks for all critical services
   - Proper restart policies
   - Structured logging

## 🔗 Service Communication

All services run in the `ai_network` Docker network:

| From n8n to | Connection String |
|------------|-------------------|
| PostgreSQL | `postgresql://n8n_user:password@n8n-db:5432/n8n` |
| Memory DB | `postgresql://memory_user:password@memory-db:5432/n8n_memory` |
| Supabase | `http://supabase-kong:8000/rest/v1/` |
| Ollama | `http://ollama:11434` |

## 🤖 Installing Ollama Models

After startup, you can install AI models:

```bash
# Download popular models
docker exec -it ollama ollama pull llama2
docker exec -it ollama ollama pull mistral
docker exec -it ollama ollama pull codellama

# List available models
docker exec -it ollama ollama list

# Chat interactively with a model
docker exec -it ollama ollama run llama2
```

## 🎯 Use Cases & Examples

### n8n AI Workflows
- **Chatbots** with local Ollama LLMs
- **Document Processing** with AI analysis
- **Data Pipelines** with Supabase integration
- **Chat Memory** stored in PostgreSQL

### Supabase Backend
- **User Authentication** and management
- **REST APIs** for data queries
- **File Storage** and management
- **Realtime Updates** via WebSockets

### File Sharing
- Share files between services via `./shared-files` volume
- CSV import in n8n, processing in Ollama

## 🔧 Management & Maintenance

### Container Management
```bash
# Check status
docker compose ps

# Stop services
docker compose stop

# Restart services
docker compose restart

# Delete all data (⚠️ Caution!)
docker compose down -v
```

### Viewing Logs
```bash
# All services
docker compose logs -f

# Single service
docker compose logs -f n8n
docker compose logs -f ollama
docker compose logs -f supabase-db
```

### Performing Updates
```bash
# Update images
docker compose pull

# Restart with new images
docker compose up -d --force-recreate
```

## 🚨 Troubleshooting

### Common Issues

**Containers fail to start:**
```bash
# Check logs
docker compose logs

# Check volumes
docker volume ls

# Check ports
netstat -tulpn | grep :5678  # Linux
netstat -ano | findstr :5678  # Windows
```

**Database connection fails:**
```bash
# PostgreSQL container status
docker exec -it n8n-postgres pg_isready -U n8n_user

# Test network connectivity
docker exec -it n8n ping n8n-db
```

**Resolving port conflicts:**
```env
# Adjust in .env file
N8N_PORT=5679
SUPABASE_STUDIO_PORT=3002
KONG_HTTP_PORT=8001
```

**Supabase Edge Functions issues:**
```bash
# Edge functions are temporarily disabled due to compatibility issues
# To re-enable, uncomment the relevant section in docker-compose.yml
# and ensure the correct directory structure exists
```

## 🔒 Production & Security

### Production Checklist
- [ ] All default passwords changed
- [ ] SSL/HTTPS with reverse proxy (Nginx/Traefik)
- [ ] Firewall configured
- [ ] Backup strategy implemented
- [ ] Log monitoring set up
- [ ] `.env` excluded from Git

### Recommended Security Measures
```bash
# Use Docker Secrets (instead of .env)
echo "my_password" | docker secret create db_password -

# Network isolation
# Only expose necessary ports
```

## 🏗️ Project Structure

```
AI-Chat-Agent/
├── docker-compose.yml          # Main configuration
├── .env                        # Your local environment variables
├── setup-automated.sh          # Automated setup script
├── setup-automated.ps1         # Windows setup script
├── shared-files/               # Shared files between containers
├── supabase/                   # Supabase configuration
│   └── docker/volumes/
│       ├── api/                # Kong API Gateway config
│       ├── db/                 # Database initialization scripts
│       └── functions/          # Edge Functions
├── README.md                   # This file
└── .gitignore                  # Git ignore rules
```

## 🔄 Updates & Maintenance

### Update Git Repository
```bash
git pull origin main
docker compose pull
docker compose up -d --force-recreate
```

### Create Backup
```bash
# PostgreSQL Backup
docker exec n8n-postgres pg_dump -U n8n_user n8n > backup_n8n.sql
docker exec supabase-postgres pg_dump -U postgres postgres > backup_supabase.sql

# Volume backup
docker run --rm -v n8n_data:/data -v $(pwd):/backup alpine tar czf /backup/n8n_backup.tar.gz /data
```

## 📦 Automated Installation

The setup scripts provide:

1. **Complete Configuration**: Creates all necessary files and directories
2. **Database Initialization**: Sets up Supabase schemas and permissions
3. **Security Hardening**: Applies security best practices
4. **Cross-Platform**: Works on Linux, macOS, and Windows (via PowerShell)

## 🤝 Contribution & Support

### For Issues
1. Create **Issues** in this repository
2. Check **Logs** with `docker compose logs`
3. Validate **Configuration** in `.env`

### Suggest Improvements
- Pull Requests are welcome
- Feature Requests via Issues

## 📄 License & Credits

Based on the following Open Source projects:

- **[n8n](https://github.com/n8n-io/n8n)** - Apache 2.0 License
- **[Supabase](https://github.com/supabase/supabase)** - Apache 2.0 License  
- **[Ollama](https://github.com/ollama/ollama)** - MIT License
- **[PostgreSQL](https://www.postgresql.org/)** - PostgreSQL License

---

## 🎉 Enjoy your local AI stack!

**Questions or feedback? Please create an issue! 🚀**

---

*Developed with ❤️ for the Open Source AI Community*
