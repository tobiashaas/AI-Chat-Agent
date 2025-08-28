#!/usr/bin/env pwsh
# PowerShell script to pull popular models into Ollama

Write-Host "🤖 AI Chat Agent - Ollama Model Installer" -ForegroundColor Cyan
Write-Host "=====================================================`n" -ForegroundColor Cyan

# Check if Ollama is responsive
try {
    $response = Invoke-RestMethod -Uri "http://localhost:11434/api/version" -Method Get -TimeoutSec 5
    Write-Host "✅ Ollama is running (version $($response.version))" -ForegroundColor Green
} catch {
    Write-Host "❌ Ollama is not responsive. Make sure it's running with 'docker-compose up -d ollama'" -ForegroundColor Red
    exit 1
}

# List of popular models to pull
$models = @(
    @{ Name = "llama2"; DisplayName = "Llama 2 (Meta)"; Size = "3.8GB" },
    @{ Name = "mistral"; DisplayName = "Mistral 7B"; Size = "4.1GB" },
    @{ Name = "phi"; DisplayName = "Phi-2 (Microsoft)"; Size = "1.7GB" },
    @{ Name = "gemma:2b"; DisplayName = "Gemma 2B (Google)"; Size = "1.8GB" },
    @{ Name = "codellama"; DisplayName = "Code Llama (Meta)"; Size = "3.8GB" },
    @{ Name = "orca-mini"; DisplayName = "Orca Mini"; Size = "1.8GB" }
)

Write-Host "Available models to install:`n" -ForegroundColor Yellow
foreach ($i in 0..($models.Count-1)) {
    Write-Host "$($i+1). $($models[$i].DisplayName) ($($models[$i].Size))" -ForegroundColor White
}
Write-Host "7. All models" -ForegroundColor Cyan
Write-Host "8. Exit" -ForegroundColor Red

$choice = Read-Host "`nSelect a model to install (1-8)"

if ($choice -eq "8") {
    Write-Host "Exiting..." -ForegroundColor Yellow
    exit 0
}

$modelsToPull = @()
if ($choice -eq "7") {
    Write-Host "`n⚠️ You've chosen to install all models. This will download approximately 17GB of data." -ForegroundColor Yellow
    $confirm = Read-Host "Are you sure you want to continue? (y/n)"
    if ($confirm -ne "y") {
        Write-Host "Installation cancelled." -ForegroundColor Red
        exit 0
    }
    $modelsToPull = $models
} elseif ([int]$choice -ge 1 -and [int]$choice -le $models.Count) {
    $modelsToPull = @($models[[int]$choice-1])
} else {
    Write-Host "Invalid selection. Exiting." -ForegroundColor Red
    exit 1
}

foreach ($model in $modelsToPull) {
    Write-Host "`n📥 Pulling $($model.DisplayName)... (approximately $($model.Size))" -ForegroundColor Cyan
    
    try {
        # Use docker exec to run the ollama pull command
        $pullCommand = "docker exec -it ollama ollama pull $($model.Name)"
        Write-Host "Executing: $pullCommand" -ForegroundColor Gray
        Invoke-Expression $pullCommand
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Successfully pulled $($model.DisplayName)" -ForegroundColor Green
        } else {
            Write-Host "❌ Failed to pull $($model.DisplayName)" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Error pulling $($model.DisplayName): $_" -ForegroundColor Red
    }
}

Write-Host "`n📋 Current models in Ollama:" -ForegroundColor Cyan
Invoke-Expression "docker exec -it ollama ollama list"

Write-Host "`n🎉 Model installation completed!" -ForegroundColor Green
Write-Host "You can now use these models through:" -ForegroundColor Cyan
Write-Host "- Open WebUI at http://localhost:3000" -ForegroundColor Cyan
Write-Host "- Direct API calls to http://localhost:11434" -ForegroundColor Cyan
Write-Host "- In n8n workflows with the HTTP Request node" -ForegroundColor Cyan

Write-Host "`nExample API call (PowerShell):" -ForegroundColor Yellow
Write-Host @'
$body = @{
    model = "llama2"
    prompt = "Explain how AI works in simple terms"
    stream = $false
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:11434/api/generate" -Method Post -Body $body -ContentType "application/json"
$response.response
'@ -ForegroundColor Gray
