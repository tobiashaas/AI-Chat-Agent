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
git clone https://github.com/tobiashaas/AI-Chat-Agent.git
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

**Option A: Standard Start (without hardware acceleration)**

```bash
# Use docker compose (with space) for Docker Compose V2
docker compose up -d
```

**Option B: With automatic hardware acceleration (recommended)**

```bash
# On Windows (PowerShell)
.\start-with-acceleration.ps1

# On Linux/macOS
chmod +x ./start-with-acceleration.sh
./start-with-acceleration.sh
```

This method automatically detects your GPU or NPU and uses the optimal configuration for your system.

> **Note:** If you see older guides or tutorials using `docker-compose` (with hyphen), replace this command with `docker compose` (with space), as this is the newer version of Docker Compose (V2).

### 5. Access Services

- 🔧 **n8n**: http://localhost:5678
- 🗄️ **PostgreSQL**: localhost:5432
- 🤖 **Ollama API**: http://localhost:11434
- 💬 **Open WebUI**: http://localhost:3000

## 🛠️ Requirements

- **Docker** (Version 20.10+)
- **Docker Compose V2** (integrated in newer Docker versions)
- **Minimum 8GB RAM**
- **SSD recommended** for better performance

## 🚀 Hardware Acceleration (new!)

This stack supports various hardware acceleration technologies for improved AI performance:

- **NVIDIA GPUs**: Automatically configured with CUDA for LLM acceleration
- **AMD GPUs**: Supports ROCm for Linux and DirectML for Windows
- **Apple Silicon**: Optimized for M1/M2/M3 chips with Metal Performance Shaders
- **Intel NPUs**: Experimental support for Intel Neural Processing Units
- **Intel/AMD CPUs**: Utilizes AVX2/AVX512 instructions when available

### Automatic Detection and Configuration

The included scripts `start-with-acceleration.sh` (for Linux/macOS) and `start-with-acceleration.ps1` (for Windows) automatically detect your available hardware and configure the stack accordingly.

Detailed configuration options and information for manual setup can be found in the [HARDWARE-ACCELERATION.md](HARDWARE-ACCELERATION.md).

## 💻 Cross-Platform Support

This stack has been designed to work across multiple operating systems:

- **Windows**: Full PowerShell automation with `.ps1` scripts
- **Linux**: Complete Bash script support with `.sh` scripts
- **macOS**: Optimized for both Intel and Apple Silicon Macs
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

After startup, you can use our model installer scripts:

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

> **Note on Hardware Acceleration**: With hardware acceleration enabled (NVIDIA/AMD GPU or Apple Silicon), models run significantly faster. You can test hardware acceleration with:
> ```bash
> docker exec -it ollama ollama run llama2 "Is this text running on my GPU or CPU?" --verbose
> ```
> The output should show information about the hardware acceleration being used.

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
docker compose ps

# Stop services
docker compose stop

# Stop services with the same scripts used to start them
# On Windows (PowerShell)
.\stop-services.ps1

# On Linux/macOS
chmod +x ./stop-services.sh
./stop-services.sh

# Restart services
docker compose restart

# Delete all data (⚠️ Caution!)
docker compose down -v
```

### View Logs
```bash
# All services (follow mode)
docker compose logs -f

# Single service
docker compose logs -f n8n
docker compose logs -f ollama
docker compose logs -f postgres-db

# Filter for errors only
docker compose logs | grep -i error

# Get logs since a specific time
docker compose logs --since=2023-08-27T00:00:00
```

### Container Status & Health Checks
```bash
# Check container health and status
docker compose ps

# Detailed container inspection
docker inspect ollama | grep -i status

# Check resource usage of containers
docker stats

# Test if services are responsive
curl -s http://localhost:11434/api/version    # Ollama API
curl -s http://localhost:5678/healthz         # n8n health check
```

### Advanced Container Management
```bash
# Restart a single service
docker compose restart n8n

# Scale a specific service (where supported)
docker compose up -d --scale n8n=2

# Execute a command in a running container
docker compose exec ollama bash

# View environment variables of a container
docker compose exec n8n env | sort
```

⚠️ **Warning About Data Loss**: Commands that remove volumes or use the `-v` flag will permanently delete your data. Always create backups before using destructive commands.

## � Data Management

### Backup & Restore

#### Regular Backups (Recommended)
Schedule regular backups to prevent data loss:

```bash
# Create a backup script (example for Linux/macOS)
cat > backup.sh << 'EOL'
#!/bin/bash
BACKUP_DIR="backups/$(date +%Y%m%d_%H%M)"
mkdir -p $BACKUP_DIR
docker exec n8n-db pg_dump -U n8n_user n8n > $BACKUP_DIR/n8n.sql
docker exec memory-db pg_dump -U memory_user n8n_memory > $BACKUP_DIR/memory.sql
docker exec postgres-db pg_dump -U postgres postgres > $BACKUP_DIR/postgres.sql
cp .env $BACKUP_DIR/.env.backup
echo "Backup completed: $BACKUP_DIR"
EOL
chmod +x backup.sh

# Add to crontab (runs daily at 2am)
(crontab -l 2>/dev/null; echo "0 2 * * * $(pwd)/backup.sh") | crontab -
```

#### Data Migration
To migrate your data to another machine:

1. Create a full backup on the source system
2. Transfer backup files to the new system
3. Set up the AI-Chat-Agent on the new system
4. Restore databases and config files from backup

⚠️ **CAUTION**: Always test the restoration process in a safe environment first.

## �🚨 Troubleshooting

### Common Issues

**Container won't start:**
```bash
# Check detailed logs
docker compose logs

# Check specific service logs
docker compose logs n8n
docker compose logs ollama

# Check if volumes exist and are properly mounted
docker volume ls
docker volume inspect ai-chat-agent_n8n_data

# Check if ports are already in use
netstat -ano | findstr :5678  # Windows
lsof -i :5678  # Linux/macOS

# Check Docker service status
systemctl status docker  # Linux
brew services info docker-machine  # macOS
Get-Service docker  # Windows PowerShell
```

**Database connection fails:**
```bash
# PostgreSQL Container Status
docker exec -it postgres-db pg_isready -U postgres

# Test network connection
docker exec -it n8n ping postgres-db
```

### Hardware Acceleration Issues

**Check GPU Detection:**

```bash
# For NVIDIA GPUs
docker exec -it ollama nvidia-smi

# For AMD GPUs on Linux
docker exec -it ollama rocm-smi

# Test hardware acceleration
docker exec -it ollama ollama run llama2 "Is my GPU being used?" --verbose
```

**Common Issues:**

1. **NVIDIA GPU not detected:**
   - Make sure you have the latest NVIDIA drivers installed
   - Verify that the NVIDIA Container Toolkit is installed and activated

2. **Docker-compose vs Docker compose:**
   - Use `docker compose` (with space) for Docker Compose V2
   - Use `docker-compose` (with hyphen) only for older Docker versions with Docker Compose V1

3. **Hardware acceleration doesn't activate:**
   - Run `./detect-hardware.sh` or `.\detect-hardware.ps1` to start automatic detection
   - Check the `.env` file for correct hardware settings

For detailed troubleshooting, see the [HARDWARE-ACCELERATION.md](HARDWARE-ACCELERATION.md).

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
├── start-with-hardware-acceleration.ps1 # Windows start with hardware detection
├── start-with-hardware-acceleration.sh  # Linux/macOS start with hardware detection
├── stop-services.ps1           # Windows service stopper
├── stop-services.sh            # Linux/macOS service stopper
├── install-models.ps1          # Windows Ollama model installer
├── install-models.sh           # Linux/macOS Ollama model installer
├── shared-files/               # Shared files between containers
├── init.sql                    # Database initialization script
├── README.md                   # This file
├── SUPABASE-README.md          # Supabase UI documentation
└── .gitignore                  # Git ignore rules
```

## 🔄 Updates & Maintenance

### Safe Update Procedure
⚠️ **IMPORTANT**: Always create a backup before updating to avoid data loss!

#### 1. Create a Backup First
```bash
# Create a timestamped backup directory
mkdir -p backups/$(date +%Y%m%d)

# PostgreSQL Backups
docker exec n8n-db pg_dump -U n8n_user n8n > backups/$(date +%Y%m%d)/backup_n8n.sql
docker exec memory-db pg_dump -U memory_user n8n_memory > backups/$(date +%Y%m%d)/backup_memory.sql
docker exec postgres-db pg_dump -U postgres postgres > backups/$(date +%Y%m%d)/backup_postgres.sql

# Volume Backups
docker run --rm -v n8n_data:/data -v $(pwd)/backups/$(date +%Y%m%d):/backup alpine tar czf /backup/n8n_data.tar.gz /data
docker run --rm -v postgres_data:/data -v $(pwd)/backups/$(date +%Y%m%d):/backup alpine tar czf /backup/postgres_data.tar.gz /data

# Backup your .env file
cp .env backups/$(date +%Y%m%d)/.env.backup
```

#### 2. Update the Repository
```bash
# Get latest code changes
git pull origin main
```

#### 3. Update Docker Images Without Data Loss
```bash
# Pull latest images
docker compose pull

# Recreate containers with updated images (preserves volumes)
docker compose up -d --force-recreate
```

### Rolling Back Updates
If an update causes issues, you can roll back to your previous state:

```bash
# Stop the problematic containers
./stop-services.sh  # or .\stop-services.ps1 on Windows

# Restore from the most recent backup
# Example for PostgreSQL database restoration:
cat backups/YYYYMMDD/backup_postgres.sql | docker exec -i postgres-db psql -U postgres
cat backups/YYYYMMDD/backup_n8n.sql | docker exec -i n8n-db psql -U n8n_user n8n
cat backups/YYYYMMDD/backup_memory.sql | docker exec -i memory-db psql -U memory_user n8n_memory

# Restore your original .env file if needed
cp backups/YYYYMMDD/.env.backup .env

# Restart with the previous configuration
./start-with-hardware-acceleration.sh  # or use the PowerShell version on Windows
```

### Complete Reset (Fresh Start)
⚠️ **WARNING**: This will permanently delete ALL your data! Use with extreme caution!

```bash
# Stop all containers and remove all data volumes
docker compose down -v

# Optional: Remove all related Docker volumes manually
docker volume rm ai-chat-agent_n8n_data
docker volume rm ai-chat-agent_postgres_data
docker volume rm ai-chat-agent_memory_data
docker volume rm ai-chat-agent_ollama_data

# Recreate the environment from scratch
./setup-automated.sh  # or .\setup-automated.ps1 on Windows
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
