#!/usr/bin/env bash
set -euo pipefail

echo "[init] Starting setup..."

COMFY_DIR="/workspace/ComfyUI"
MODEL_DIR="$COMFY_DIR/models"
WORKFLOW_DIR="$COMFY_DIR/user/default/workflows"

echo "[init] Creating directories..."
mkdir -p "$MODEL_DIR"
mkdir -p "$WORKFLOW_DIR"

echo "[init] Downloading models..."

curl -L -o "$MODEL_DIR/Wan2.2-T2V-A14B-LowNoise-Q8_0.gguf" \
"https://huggingface.co/QuantStack/Wan2.2-T2V-A14B-GGUF/resolve/main/LowNoise/Wan2.2-T2V-A14B-LowNoise-Q8_0.gguf"

curl -L -o "$MODEL_DIR/Wan2.2-T2V-A14B-HighNoise-Q8_0.gguf" \
"https://huggingface.co/QuantStack/Wan2.2-T2V-A14B-GGUF/resolve/main/HighNoise/Wan2.2-T2V-A14B-HighNoise-Q8_0.gguf"

curl -L -o "$MODEL_DIR/wan_2.1_vae.safetensors" \
"https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"

curl -L -o "$MODEL_DIR/umt5_xxl_fp8_e4m3fn_scaled.safetensors" \
"https://huggingface.co/chatpig/encoder/resolve/main/umt5_xxl_fp8_e4m3fn_scaled.safetensors"

curl -L -o "$MODEL_DIR/Instagirlv2.3_high.safetensors" \
"https://huggingface.co/lynn-mikami/wan-testing/resolve/main/Instagirlv2.3_high.safetensors"

curl -L -o "$MODEL_DIR/Insatgirlv2.3_low.safetensors" \
"https://huggingface.co/allyourtech/instagirl/resolve/main/Insatgirlv2.3_low.safetensors"

curl -L -o "$MODEL_DIR/Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors" \
"https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors"

curl -L -o "$MODEL_DIR/1alexi_LorA_000002750.safetensors" \
"https://huggingface.co/Zlavik1KK/SEX/resolve/main/1alexi_LorA_000002750.safetensors"


echo "[init] Copy workflow.json"
cp /workspace/repo/workflow.json "$WORKFLOW_DIR/workflow.json"

echo "[init] Setup complete."
