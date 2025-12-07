#!/usr/bin/env bash
set -euo pipefail

echo ">>> Creating model directories"
mkdir -p /workspace/ComfyUI/models/checkpoints
mkdir -p /workspace/ComfyUI/models/vae
mkdir -p /workspace/ComfyUI/models/loras
mkdir -p /workspace/ComfyUI/models/upscale

echo ">>> Downloading models"

curl -L -o /workspace/ComfyUI/models/vae/wan_2.1_vae.safetensors \
  "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"

curl -L -o /workspace/ComfyUI/models/checkpoints/Insatgirlv2.3_low.safetensors \
  "https://huggingface.co/allyourtech/instagirl/resolve/main/Insatgirlv2.3_low.safetensors"

echo ">>> DONE init.sh"
