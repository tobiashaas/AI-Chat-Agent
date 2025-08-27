# PowerShell script to start Supabase UI

Write-Host "🚀 AI Chat Agent - Supabase UI Starter" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# Check if docker is installed
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker is installed: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not installed. Please install Docker Desktop first." -ForegroundColor Red
    exit 1
}

# Check if main stack is running
try {
    $containerCheck = docker ps --format "{{.Names}}" | Select-String "postgres-db"
    if (!$containerCheck) {
        Write-Host "❓ The main AI Chat Agent stack doesn't appear to be running." -ForegroundColor Yellow
        $startMain = Read-Host "Would you like to start it first? (y/n)"
        
        if ($startMain -eq "y") {
            Write-Host "Starting main stack..." -ForegroundColor Magenta
            docker-compose up -d
            Write-Host "Waiting for the database to initialize..." -ForegroundColor Yellow
            Start-Sleep -Seconds 10
        }
    } else {
        Write-Host "✅ Main AI Chat Agent stack is running" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Error checking container status: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Starting Supabase UI..." -ForegroundColor Magenta

try {
    # Start Supabase UI
    docker-compose -f docker-compose-supabase.yml up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ Supabase UI is starting!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📋 Access Information:" -ForegroundColor Cyan
        Write-Host " - Supabase Studio: http://localhost:3001" -ForegroundColor White
        Write-Host " - API Endpoint:    http://localhost:8000" -ForegroundColor White
        Write-Host ""
        Write-Host "⏳ Please allow a few moments for all services to initialize..." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "🔑 Default Service Role Key (for administrative access):" -ForegroundColor Cyan
        Write-Host "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJzZXJ2aWNlX3JvbGUiLAogICAgImlzcyI6ICJzdXBhYmFzZS1kZW1vIiwKICAgICJpYXQiOiAxNjQxNzY5MjAwLAogICAgImV4cCI6IDE3OTk1MzU2MDAKfQ.DaYlNEoUrrEn2Ig7tqibS-PHK5vgusbcbo7X36XVt4Q" -ForegroundColor DarkGray
    } else {
        Write-Host "❌ Failed to start Supabase UI" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error starting Supabase UI: $_" -ForegroundColor Red
    exit 1
}
