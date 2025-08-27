#!/bin/bash
# Hardware Acceleration Detection Script
# This script detects available GPUs and sets the appropriate environment variables in .env

# Function to set a value in the .env file
update_env_var() {
    KEY=$1
    VALUE=$2
    if grep -q "^${KEY}=" .env; then
        sed -i.bak "s|^${KEY}=.*|${KEY}=${VALUE}|" .env
    else
        echo "${KEY}=${VALUE}" >> .env
    fi
}

echo "Detecting hardware acceleration capabilities..."

# Enable GPU by default
update_env_var "ENABLE_GPU" "true"

# Default to none/0/false for all specific hardware
update_env_var "NVIDIA_GPU" "none"
update_env_var "NVIDIA_VISIBLE_DEVICES" "none"
update_env_var "NVIDIA_DRIVER_CAPABILITIES" ""
update_env_var "AMD_GPU" "0"
update_env_var "HSA_OVERRIDE_GFX_VERSION" ""
update_env_var "INTEL_NPU" "0"
update_env_var "APPLE_SILICON" "0"
update_env_var "DYLD_LIBRARY_PATH" ""
update_env_var "METAL_DEVICE_WRAPPER_TYPE" ""

# Check for NVIDIA GPU
if command -v nvidia-smi &> /dev/null; then
    echo "NVIDIA GPU detected"
    update_env_var "NVIDIA_GPU" "nvidia"
    update_env_var "NVIDIA_VISIBLE_DEVICES" "all"
    update_env_var "NVIDIA_DRIVER_CAPABILITIES" "compute,utility"
fi

# Check for AMD GPU on Linux
if [ "$(uname)" == "Linux" ] && command -v lspci &> /dev/null; then
    if lspci | grep -i amd | grep -i vga &> /dev/null; then
        echo "AMD GPU detected"
        update_env_var "AMD_GPU" "1"
        update_env_var "HSA_OVERRIDE_GFX_VERSION" "10.3.0"
    fi
fi

# Check for Apple Silicon
if [ "$(uname)" == "Darwin" ] && [ "$(uname -m)" == "arm64" ]; then
    echo "Apple Silicon detected"
    update_env_var "APPLE_SILICON" "1"
    update_env_var "DYLD_LIBRARY_PATH" "/usr/lib:/usr/local/lib"
    update_env_var "METAL_DEVICE_WRAPPER_TYPE" "1"
fi

# Check for Intel NPU (this is a basic check and might need to be improved)
if command -v lspci &> /dev/null; then
    if lspci | grep -i intel | grep -i neural &> /dev/null; then
        echo "Intel NPU detected"
        update_env_var "INTEL_NPU" "1"
    fi
fi

echo "Hardware detection complete. Updated .env file."
