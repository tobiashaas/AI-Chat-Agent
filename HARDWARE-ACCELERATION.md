# Ollama Hardware Configuration Guide
# ==============================

## Automatic Hardware Detection
# ---------------------------

We've added automatic hardware detection scripts that will configure your environment for optimal performance:

- **Linux/macOS**: Run `./detect-hardware.sh` before starting the containers
- **Windows**: Run `.\detect-hardware.ps1` before starting the containers

These scripts will detect your available hardware acceleration options and configure the `.env` file accordingly.

## Manual Configuration in .env File
# ------------------------------

You can manually configure hardware acceleration by editing these variables in the `.env` file:

```
# Hardware Acceleration Settings (true/false)
ENABLE_GPU=true           # Master-switch for GPU acceleration
NVIDIA_GPU=false          # For NVIDIA GPUs
AMD_GPU=false             # For AMD GPUs
INTEL_NPU=false           # For Intel Neural Processing Units
APPLE_SILICON=true        # For Apple Silicon (M1/M2/M3)
OLLAMA_MEMORY_LIMIT=8G    # Memory limit for Ollama
```

## GPU Configuration
# ------------------

### NVIDIA GPU
To enable NVIDIA GPU support, make sure you have:
1. NVIDIA drivers installed on your host machine
2. NVIDIA Container Toolkit installed

For Windows/WSL2:
- Make sure to install the NVIDIA CUDA drivers on Windows
- Enable GPU in Docker Desktop settings

For Linux:
```bash
# Install NVIDIA Container Toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

### AMD GPU Acceleration
To enable AMD GPU support:

For Linux:
```bash
# Install ROCm on Ubuntu
wget -q -O - https://repo.radeon.com/rocm/rocm.gpg.key | sudo apt-key add -
echo 'deb [arch=amd64] https://repo.radeon.com/rocm/apt/debian/ ubuntu main' | sudo tee /etc/apt/sources.list.d/rocm.list
sudo apt update
sudo apt install rocm-dev
```

For Windows:
Use DirectML through WSL2 (experimental support)

### Intel/AMD CPU Acceleration
Ollama automatically uses AVX2/AVX512 instructions if your CPU supports them.

### Apple Silicon Acceleration
On Apple Silicon (M1/M2/M3), Ollama can use Metal Performance Shaders (MPS) for acceleration. This is automatically enabled when running on Apple Silicon.

## Performance Tuning
# ------------------

### Memory Settings
The default memory limit is 8GB. Adjust based on your system:

```yaml
deploy:
  resources:
    limits:
      memory: 12G  # Increase for better performance with large models
```

### GPU Memory Settings
For systems with limited VRAM, you can set:

```
environment:
  - CUDA_VISIBLE_DEVICES=0  # Use specific GPU
  - GPU_MEMORY_UTILIZATION=0.9  # Use 90% of available VRAM
```

## Troubleshooting
# --------------

### Check GPU Detection
For NVIDIA GPU:
```bash
docker exec -it ollama nvidia-smi
```

For AMD GPU:
```bash
docker exec -it ollama rocm-smi
```

For Apple Silicon:
```bash
docker exec -it ollama metal-info  # If metal-info is available
```

### Check Ollama GPU Usage
Run:
```bash
docker exec -it ollama ollama run llama2 "Are you using my GPU?" --verbose
```

### CPU Feature Detection
Check AVX support:
```bash
docker exec -it ollama cat /proc/cpuinfo | grep -E 'avx2|avx512'
```

### If Hardware Acceleration Isn't Working

1. Make sure the hardware detection scripts have been run
2. Check your `.env` file to ensure the correct variables are set
3. Try manually setting the appropriate variables in `.env` 
4. Restart the stack with `docker compose down && docker compose up -d`

If problems persist, you can disable hardware acceleration by setting `ENABLE_GPU=false` in your `.env` file.

## Model Loading Parameters
# -----------------------

You can tune model loading with parameters:

```bash
docker exec -it ollama ollama run llama2:13b \
  --gpu-layers 35 \  # Number of layers to offload to GPU
  --num-ctx 4096    # Context window size
```
