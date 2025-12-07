#!/usr/bin/env bash
set -euo pipefail

echo "[init] Starting setup..."

COMFY_DIR="/workspace/ComfyUI"
MODEL_DIR="$COMFY_DIR/models"
WORKFLOW_DIR="$COMFY_DIR/user/default/workflows"

echo "[init] Creating directories..."
mkdir -p "$MODEL_DIR" "$WORKFLOW_DIR"

echo "[init] Downloading models..."

wget -O "$MODEL_DIR/model1.safetensors" "https://..."
wget -O "$MODEL_DIR/model2.safetensors" "https://..."
# остальные модели

echo "[init] Copying workflow..."
cp /workspace/repo/workflow.json "$WORKFLOW_DIR/workflow.json"

echo "[init] Finished."
