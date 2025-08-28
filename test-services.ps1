#!/usr/bin/env pwsh
# PowerShell script to test all services in the AI Chat Agent Stack

Write-Host "🚀 AI Chat Agent - Service Test Script" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# Function to test a URL
function Test-Endpoint {
    param (
        [string]$Name,
        [string]$Url
    )
    
    try {
        Invoke-RestMethod -Uri $Url -Method Get -TimeoutSec 5 | Out-Null
        Write-Host "✅ $Name ($Url): Success" -ForegroundColor Green
        return $true
    } 
    catch {
        # Check if it's a 404 error, which is expected for some root endpoints
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Host "✅ $Name ($Url): 404 Not Found (This is expected for the root path)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ $Name ($Url): Failed - $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    }
}

Write-Host "Testing service endpoints:" -ForegroundColor Yellow

# Main services
$n8n = Test-Endpoint -Name "n8n" -Url "http://localhost:5678"
$supabase_studio = Test-Endpoint -Name "Supabase Studio" -Url "http://localhost:3001"
$supabase_kong = Test-Endpoint -Name "Supabase Kong" -Url "http://localhost:8000"
$ollama = Test-Endpoint -Name "Ollama API" -Url "http://localhost:11434"
$open_webui = Test-Endpoint -Name "Open WebUI" -Url "http://localhost:3000"

if ($n8n -and $supabase_studio -and $supabase_kong -and $ollama -and $open_webui) {
    Write-Host ""
    Write-Host "All core services are accessible!" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "Testing specific Supabase endpoints:" -ForegroundColor Yellow
    
    # Test Supabase specific endpoints
    $supabase_auth = Test-Endpoint -Name "Supabase Auth API" -Url "http://localhost:8000/auth/v1"
    $supabase_rest = Test-Endpoint -Name "Supabase REST API" -Url "http://localhost:8000/rest/v1"
    $supabase_storage = Test-Endpoint -Name "Supabase Storage API" -Url "http://localhost:8000/storage/v1"
    
    if ($supabase_auth -and $supabase_rest -and $supabase_storage) {
        Write-Host ""
        Write-Host "🎉 All services are running properly!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "⚠️ Some Supabase APIs are not responding correctly." -ForegroundColor Yellow
        Write-Host "Try restarting the stack: docker-compose restart" -ForegroundColor Yellow
    }
} else {
    Write-Host ""
    Write-Host "⚠️ Some core services are not accessible." -ForegroundColor Red
    Write-Host "Check if all containers are running: docker-compose ps" -ForegroundColor Yellow
    Write-Host "Check logs for errors: docker-compose logs" -ForegroundColor Yellow
}
