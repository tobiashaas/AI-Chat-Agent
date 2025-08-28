# PowerShell script to install a specific model in Ollama

# Check if Ollama is responsive
try {
    $response = Invoke-RestMethod -Uri "http://localhost:11434/api/version" -Method Get -TimeoutSec 5
    Write-Host "Ollama is running (version $($response.version))"
} catch {
    Write-Host "Ollama is not responsive. Make sure it's running with 'docker-compose up -d ollama'"
    exit 1
}

# Pull a specific model
$modelName = "orca-mini"
Write-Host "Pulling $modelName model... (this will take some time)"

try {
    # Use docker exec to run the ollama pull command
    $pullCommand = "docker exec -it ollama ollama pull $modelName"
    Invoke-Expression $pullCommand
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Successfully pulled $modelName"
    } else {
        Write-Host "Failed to pull $modelName"
    }
} catch {
    Write-Host "Error pulling $modelName: $($_.Exception.Message)"
}

# List installed models
Write-Host "Current models in Ollama:"
Invoke-Expression "docker exec -it ollama ollama list"
