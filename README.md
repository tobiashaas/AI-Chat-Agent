# 🚀 Self-Hosted AI Development Stack

**n8n + PostgreSQL + Ollama - Simplified and Enhanced Version**

A complete Docker Compose configuration for a modern AI development environment. All services run locally in a shared Docker network and communicate seamlessly with each other.

## 📦 Included Components

| Service | Description | Port | Security Level |
|---------|-------------|------|---------------|
| **n8n** | Workflow Automation Platform | 5678 | 🔒🔒🔒 |
| **PostgreSQL** | Main database for n8n | - | 🔒🔒🔒 |
| **Memory PostgreSQL** | Separate DB for AI Agent Memory | - | 🔒🔒🔒 |
| **PostgreSQL for Data** | Simplified database with auth/storage schemas | 5432 | 🔒🔒🔒 |
| **Ollama** | Local LLM Server | 11434 | 🔒🔒 |
| **Open WebUI** | Chat Interface for Ollama | 3000 | 🔒🔒 |

## ⚡ Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/username/AI-Chat-Agent.git
cd AI-Chat-Agent
```

### 2. Automated Setup (Recommended)

```bash
# On Windows (PowerShell)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
.\setup-automated.ps1

# On Linux/macOS
chmod +x ./setup-automated.sh
./setup-automated.sh
```

### 3. Configure Environment Variables (optional)

```bash
# Check and modify the automatically created .env file
notepad .env  # Adjust passwords and keys!
```

### 4. Start Services

```bash
docker-compose up -d
```

### 5. Access Services

- 🔧 **n8n**: http://localhost:5678
- 🗄️ **PostgreSQL**: localhost:5432
- 🤖 **Ollama API**: http://localhost:11434
- 💬 **Open WebUI**: http://localhost:3000

## 🛠️ Requirements

- **Docker** (Version 20.10+)
- **Docker Compose** (Version 2.0+)
- **Minimum 8GB RAM**
- **SSD recommended** for better performance
- **GPU or AI accelerated CPU** (configured for better Ollama performance)

## 🚀 Hardware Acceleration

This stack supports hardware acceleration for improved AI performance:

- **NVIDIA GPUs**: Automatically configured for LLM acceleration
- **Intel/AMD CPUs**: Uses AVX2/AVX512 instructions when available
- **Apple Silicon**: Optimized for M1/M2/M3 chips

See the [HARDWARE-ACCELERATION.md](HARDWARE-ACCELERATION.md) guide for detailed configuration options.

## 💻 Cross-Platform Support

This stack has been designed to work across multiple operating systems:

- **Windows**: Full PowerShell automation with `.ps1` scripts
- **Linux**: Complete Bash script support with `.sh` scripts
- **macOS**: Full compatibility with the same Linux scripts

All automation scripts are provided in both PowerShell and Bash versions to ensure a seamless experience regardless of your operating system.

## 🔐 Security Configuration

⚠️ **IMPORTANT**: Before first start, adjust the `.env` file:

### Critical Settings
```env
# n8n Authentication
N8N_AUTH_USER=your_secure_username
N8N_AUTH_PASSWORD=YourSecurePassword123!
N8N_ENCRYPTION_KEY=YourSuperSecureEncryptionKey32Plus  # 32+ characters

# PostgreSQL
POSTGRES_PASSWORD=YourSuperSecureDatabasePassword123!
```

## 🔧 Security Enhancements

This environment has been equipped with several security enhancements:

1. **Container Hardening**
   - All containers use `no-new-privileges:true`
   - Proper resource limitations
   - Non-root users where possible

2. **Network Security**
   - Isolated bridge network with subnet definition
   - Minimized exposed ports
   - Restricted service-to-service communication

3. **Data Protection**
   - Volume permissions properly configured
   - Read-only mounts where appropriate
   - Secure handling of sensitive data

4. **Monitoring & Recovery**
   - Health checks for all critical services
   - Proper restart policies
   - Structured logging

## 🔗 Service Communication

All services run in the `ai_network` Docker network:

| From n8n to | Connection string |
|------------|-------------------|
| PostgreSQL | `postgresql://n8n_user:n8n_secure_local_pass_2025@n8n-db:5432/n8n` |
| Memory DB | `postgresql://memory_user:memory_secure_local_pass_2025@memory-db:5432/n8n_memory` |
| Data DB | `postgresql://postgres:supabase_local_dev_pass_2025@postgres-db:5432/postgres` |
| Ollama | `http://ollama:11434` |

## 🤖 Installing Ollama Models

After starting, you can use our model installer scripts:

```bash
# On Windows (PowerShell)
.\install-models.ps1

# On Linux/macOS
chmod +x ./install-models.sh
./install-models.sh
```

You can also manually install models:

```bash
# Download popular models
docker exec -it ollama ollama pull llama2
docker exec -it ollama ollama pull mistral
docker exec -it ollama ollama pull codellama

# List available models
docker exec -it ollama ollama list

# Interactive chat with a model
docker exec -it ollama ollama run llama2
```

## 🔍 Using Supabase UI (Optional)

If you prefer a visual interface to manage your database, you can use the optional Supabase UI:

```bash
# On Windows (PowerShell)
.\start-supabase-ui.ps1

# On Linux/macOS
chmod +x ./start-supabase-ui.sh
./start-supabase-ui.sh

# Alternatively, use docker-compose directly:
docker-compose -f docker-compose-supabase.yml up -d
```

The Supabase UI will be available at:
- **Supabase Studio**: http://localhost:3001
- **API Endpoint**: http://localhost:8000

For more details, see the [SUPABASE-README.md](SUPABASE-README.md) file.

## 🎯 Use Cases & Examples

### n8n AI Workflows
- **Chatbots** with local Ollama LLMs
- **Document processing** with AI analysis
- **Data pipelines** with PostgreSQL integration
- **Chat memory** stored in PostgreSQL

### PostgreSQL Database
- **Authentication** and user management
- **Data storage** for all application data
- **File storage** in the storage schema
- **Metadata management** for AI assets

### Supabase UI (Optional)
- Visual database management with Supabase Studio
- API explorer and documentation
- Storage management interface
- Authentication dashboard

### Data Sharing
- Share files between services via `./shared-files` volume
- CSV import in n8n, processing in Ollama

## 🔧 Management & Maintenance

### Container Management
```bash
# Check status
docker-compose ps

# Stop services
docker-compose stop

# Restart services
docker-compose restart

# Delete all data (⚠️ Caution!)
docker-compose down -v
```

### View Logs
```bash
# All services
docker-compose logs -f

# Single service
docker-compose logs -f n8n
docker-compose logs -f ollama
docker-compose logs -f postgres-db
```

### Perform Updates
```bash
# Update images
docker-compose pull

# Restart with new images
docker-compose up -d --force-recreate
```

## 🚨 Troubleshooting

### Common Issues

**Container won't start:**
```bash
# Check logs
docker-compose logs

# Check volumes
docker volume ls

# Check ports
netstat -ano | findstr :5678  # Windows
```

**Database connection fails:**
```bash
# PostgreSQL Container Status
docker exec -it postgres-db pg_isready -U postgres

# Test network connection
docker exec -it n8n ping postgres-db
```

**Resolve port conflicts:**
```env
# Adjust in the .env file
N8N_PORT=5679
POSTGRES_PORT=5433
OPEN_WEBUI_PORT=3001
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
├── docker-compose-supabase.yml # Optional Supabase UI configuration
├── .env                        # Local environment variables
├── setup-automated.ps1         # Windows setup script
├── setup-automated.sh          # Linux/macOS setup script
├── start-supabase-ui.ps1       # Windows Supabase UI starter
├── start-supabase-ui.sh        # Linux/macOS Supabase UI starter
├── install-models.ps1          # Windows Ollama model installer
├── install-models.sh           # Linux/macOS Ollama model installer
├── shared-files/               # Shared files between containers
├── init.sql                    # Database initialization script
├── README.md                   # This file
├── SUPABASE-README.md          # Supabase UI documentation
└── .gitignore                  # Git ignore rules
```

## 🔄 Updates & Maintenance

### Update Git Repository
```bash
git pull origin main
docker-compose pull
docker-compose up -d --force-recreate
```

### Create Backup
```bash
# PostgreSQL Backup
docker exec n8n-postgres pg_dump -U n8n_user n8n > backup_n8n.sql
docker exec postgres-db pg_dump -U postgres postgres > backup_postgres.sql

# Volume Backup
docker run --rm -v n8n_data:/data -v ${PWD}:/backup alpine tar czf /backup/n8n_backup.tar.gz /data
```

## 📦 Automated Installation

The setup script provides:

1. **Complete configuration**: Creates all necessary files and directories
2. **Database initialization**: Sets up PostgreSQL schemas and tables
3. **Security hardening**: Applies security measures
4. **Cross-platform**: Works on Windows with PowerShell

## 🔗 PostgreSQL Connection Details

### Connection Information

| Parameter | Value |
|-----------|------|
| Host      | localhost |
| Port      | 5432 |
| Database  | postgres |
| User      | postgres |
| Password  | supabase_local_dev_pass_2025 |

### Connection String

```
postgresql://postgres:supabase_local_dev_pass_2025@localhost:5432/postgres
```

### Configured Schemas

- `auth` - For authentication and user accounts
- `storage` - For file storage
- `realtime` - For real-time updates

### Important Tables

- `auth.users` - User accounts
- `storage.buckets` - Storage bucket definitions
- `storage.objects` - Stored files

## 📄 License & Credits

Based on the following open-source projects:

- **[n8n](https://github.com/n8n-io/n8n)** - Apache 2.0 License
- **[PostgreSQL](https://www.postgresql.org/)** - PostgreSQL License
- **[Ollama](https://github.com/ollama/ollama)** - MIT License

---

## 🎉 Enjoy your local AI stack!

**Questions or feedback? Please create an issue! 🚀**

---

*Developed with ❤️ for the open-source AI community*
