#!/usr/bin/env bash
set -euo pipefail

echo ">>> [init.sh] Начало инициализации."

COMFY="/workspace/ComfyUI"

echo ">>> [init.sh] Создаю каталоги моделей..."
mkdir -p "$COMFY/models/checkpoints"
mkdir -p "$COMFY/models/vae"
mkdir -p "$COMFY/models/loras"
mkdir -p "$COMFY/models/upscale"

echo ">>> [init.sh] Скачиваю модели..."

# WAN VAE
wget -O "$COMFY/models/vae/wan_2.1_vae.safetensors" \
  "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"

# Instagirl
wget -O "$COMFY/models/checkpoints/Instagirlv2.3_low.safetensors" \
  "https://huggingface.co/allyourtech/instagirl/resolve/main/Insatgirlv2.3_low.safetensors"

# Другие модели добавишь сам, формат один

echo ">>> [init.sh] Копирую workflow.json..."
cp /workspace/repo/workflow.json "/workspace/ComfyUI/user/default/workflows/workflow.json"

echo ">>> [init.sh] Инициализация завершена успешно!"
