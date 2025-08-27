# PowerShell script to test Ollama API

Write-Host "🤖 AI Chat Agent - Ollama API Tester" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# Check if Ollama is responsive
try {
    $response = Invoke-RestMethod -Uri "http://localhost:11434/api/version" -Method Get -TimeoutSec 5
    Write-Host "✅ Ollama is running (version $($response.version))" -ForegroundColor Green
} catch {
    Write-Host "❌ Ollama is not responsive. Make sure it's running with 'docker-compose up -d ollama'" -ForegroundColor Red
    exit 1
}

# Check available models
try {
    $modelsResponse = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -Method Get
    
    if ($modelsResponse.models.Count -eq 0) {
        Write-Host "⚠️ No models are currently installed. Use install-models.ps1 to install models." -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host ""
    Write-Host "📋 Available models:" -ForegroundColor Green
    foreach ($model in $modelsResponse.models) {
        Write-Host "- $($model.name)" -ForegroundColor White
    }
    
    Write-Host ""
    $selectedModel = Read-Host "Enter the name of the model you want to use"
    
    # Check if the model exists
    $modelExists = $false
    foreach ($model in $modelsResponse.models) {
        if ($model.name -eq $selectedModel) {
            $modelExists = $true
            break
        }
    }
    
    if (-not $modelExists) {
        Write-Host "❌ Model '$selectedModel' not found." -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "❌ Failed to get model list: $_" -ForegroundColor Red
    exit 1
}

# Ask for the prompt
Write-Host ""
$prompt = Read-Host "Enter your prompt for the model"

# Prepare the request
$body = @{
    model = $selectedModel
    prompt = $prompt
    stream = $false
} | ConvertTo-Json

Write-Host ""
Write-Host "⏳ Generating response... (this might take a few moments)" -ForegroundColor Yellow

# Send the request
try {
    $startTime = Get-Date
    $response = Invoke-RestMethod -Uri "http://localhost:11434/api/generate" -Method Post -Body $body -ContentType "application/json"
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalSeconds
    
    # Display the response
    Write-Host ""
    Write-Host "✅ Response generated in $([math]::Round($duration, 2)) seconds:" -ForegroundColor Green
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host $response.response
    Write-Host "================================================================" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Failed to get response: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎉 Ollama API test complete!" -ForegroundColor Green
Write-Host "You can explore more options in the Open WebUI at http://localhost:3000" -ForegroundColor Cyan
