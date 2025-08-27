# Ollama Hardware Configuration Guide
# ==============================

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

### Intel/AMD CPU Acceleration
Ollama automatically uses AVX2/AVX512 instructions if your CPU supports them.

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
Run inside the container:
```bash
docker exec -it ollama nvidia-smi
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

## Model Loading Parameters
# -----------------------

You can tune model loading with parameters:

```bash
docker exec -it ollama ollama run llama2:13b \
  --gpu-layers 35 \  # Number of layers to offload to GPU
  --num-ctx 4096    # Context window size
```
