# Check GPU and hardware acceleration for Ollama

Write-Host "🔍 GPU Detection for Ollama" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
try {
    docker info > $null 2>&1
} catch {
    Write-Host "❌ Docker is not running. Please start Docker first." -ForegroundColor Red
    exit 1
}

# Check if Ollama container is running
if (-not (docker ps | Select-String -Pattern "ollama")) {
    Write-Host "❌ Ollama container is not running. Please start it with 'docker-compose up -d ollama'" -ForegroundColor Red
    exit 1
}

Write-Host "Checking for NVIDIA GPU..." -ForegroundColor Blue
try {
    docker exec -it ollama nvidia-smi 2>&1 > $null
    if ($LASTEXITCODE -eq 0) {
        $gpuInfo = docker exec -it ollama nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader
        Write-Host "✅ NVIDIA GPU detected:" -ForegroundColor Green
        foreach ($line in $gpuInfo -split "`n") {
            Write-Host "   $line"
        }
        
        Write-Host ""
        Write-Host "Testing GPU with Ollama..." -ForegroundColor Blue
        Write-Host "This will check if Ollama can access the GPU" -ForegroundColor Gray
        
        $gpuTestOutput = docker exec -it ollama bash -c 'ollama run lionel-wong/verify-gpu 2>&1'
        $gpuTestOutput | Select-String -Pattern "gpu|cuda|available|tensor" | ForEach-Object {
            Write-Host $_
        }
        
        # Check if models are using GPU
        Write-Host ""
        Write-Host "Current models:" -ForegroundColor Blue
        $models = docker exec -it ollama ollama list
        $modelList = $models | Select-Object -Skip 1
        
        if ($modelList.Count -eq 0 -or [string]::IsNullOrWhiteSpace($modelList)) {
            Write-Host "   No models installed yet. Install models with './install-models.ps1'" -ForegroundColor Yellow
        } else {
            foreach ($model in $modelList) {
                if (-not [string]::IsNullOrWhiteSpace($model)) {
                    $modelName = ($model -split "\s+")[0]
                    Write-Host "   $modelName" -ForegroundColor Cyan
                }
            }
        }
    } else {
        Write-Host "⚠️ NVIDIA GPU not detected or not properly configured." -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️ NVIDIA GPU not detected or not properly configured." -ForegroundColor Yellow
}

# Check CPU acceleration
Write-Host ""
Write-Host "Checking for CPU acceleration features..." -ForegroundColor Blue

try {
    $cpuInfoOutput = docker exec -it ollama cat /proc/cpuinfo
    if ($cpuInfoOutput | Select-String -Pattern "avx2|avx512") {
        Write-Host "✅ CPU supports AVX2/AVX512 instructions for acceleration" -ForegroundColor Green
        
        $cpuModel = ($cpuInfoOutput | Select-String -Pattern "model name" | Select-Object -First 1) -replace ".*: "
        Write-Host "   CPU: $cpuModel" -ForegroundColor Green
        
        # Check which instructions are supported
        if ($cpuInfoOutput | Select-String -Pattern "avx512") {
            Write-Host "   AVX-512: Supported ✓" -ForegroundColor Green
        } else {
            Write-Host "   AVX-512: Not supported ✗" -ForegroundColor Yellow
        }
        
        if ($cpuInfoOutput | Select-String -Pattern "avx2") {
            Write-Host "   AVX2: Supported ✓" -ForegroundColor Green
        } else {
            Write-Host "   AVX2: Not supported ✗" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ CPU does not support advanced vector instructions (AVX)." -ForegroundColor Red
        Write-Host "   LLM inference will be significantly slower." -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Could not check CPU features." -ForegroundColor Red
}

Write-Host ""
Write-Host "Memory configuration:" -ForegroundColor Blue
try {
    $memInfo = docker exec -it ollama cat /proc/meminfo | Select-String -Pattern "MemTotal|MemAvailable"
    $memInfo | ForEach-Object {
        $line = $_ -replace ":\s+", " "
        $parts = $line -split "\s+"
        $gbValue = [math]::Round([int]$parts[1] / 1024 / 1024, 2)
        Write-Host "   $($parts[0]) $gbValue GB"
    }
} catch {
    Write-Host "❌ Could not check memory configuration." -ForegroundColor Red
}

Write-Host ""
Write-Host "Recommendations:" -ForegroundColor Cyan
Write-Host "1. For NVIDIA GPU support, ensure you have the NVIDIA Container Toolkit installed" -ForegroundColor White
Write-Host "2. For optimal CPU performance, ensure your models are compiled with AVX2/AVX512 support" -ForegroundColor White
Write-Host "3. Consider smaller models like phi-2, gemma:2b for machines with limited resources" -ForegroundColor White
Write-Host ""
Write-Host "See HARDWARE-ACCELERATION.md for detailed configuration options" -ForegroundColor Green
