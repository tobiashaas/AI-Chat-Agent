# Simple script to check GPU support
# PowerShell version

Write-Host "GPU Check for Ollama" -ForegroundColor Cyan
Write-Host "====================" -ForegroundColor Cyan

# Check if Ollama is running
if (!(docker ps | Select-String "ollama")) {
    Write-Host "❌ Ollama container is not running. Start it with 'docker-compose up -d'" -ForegroundColor Red
    exit 1
}

# Check for NVIDIA GPU
Write-Host "Testing for NVIDIA GPU..." -ForegroundColor Yellow
docker exec -it ollama nvidia-smi 2>&1 > $null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ NVIDIA GPU detected and working!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Try using a model with GPU acceleration:" -ForegroundColor Cyan
    Write-Host "docker exec -it ollama ollama run llama2 --gpu" -ForegroundColor Gray
} else {
    Write-Host "❌ NVIDIA GPU not detected or not properly configured" -ForegroundColor Yellow
    
    Write-Host ""
    Write-Host "Checking for CPU acceleration..." -ForegroundColor Yellow
    docker exec -it ollama grep -E 'avx2|avx512' /proc/cpuinfo 2>&1 > $null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ CPU supports AVX instructions - LLM performance will be acceptable" -ForegroundColor Green
    } else {
        Write-Host "❌ CPU does not have advanced vector extensions - LLM performance may be slow" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "For detailed configuration options, see HARDWARE-ACCELERATION.md" -ForegroundColor Cyan
