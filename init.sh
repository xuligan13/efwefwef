#!/usr/bin/env bash
set -euo pipefail

echo "[init] Запуск init.sh"

WORKDIR="/workspace"
MODELDIR="$WORKDIR/models"
WORKFLOWDIR="$WORKDIR/workflow"

mkdir -p "$MODELDIR"
mkdir -p "$WORKFLOWDIR"

echo "[init] Скачиваю модели в ${MODELDIR}"

# UNET LOW NOISE
curl -L -o "$MODELDIR/Wan2.2-T2V-A14B-LowNoise-Q8_0.gguf" \
  "https://huggingface.co/QuantStack/Wan2.2-T2V-A14B-GGUF/resolve/main/LowNoise/Wan2.2-T2V-A14B-LowNoise-Q8_0.gguf"

# UNET HIGH NOISE
curl -L -o "$MODELDIR/Wan2.2-T2V-A14B-HighNoise-Q8_0.gguf" \
  "https://huggingface.co/QuantStack/Wan2.2-T2V-A14B-GGUF/resolve/main/HighNoise/Wan2.2-T2V-A14B-HighNoise-Q8_0.gguf"

# VAE
curl -L -o "$MODELDIR/wan_2.1_vae.safetensors" \
  "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"

# CLIP ENCODER
curl -L -o "$MODELDIR/umt5_xxl_fp8_e4m3fn_scaled.safetensors" \
  "https://huggingface.co/chatpig/encoder/resolve/main/umt5_xxl_fp8_e4m3fn_scaled.safetensors"

# INSTAGIRL HIGH
curl -L -o "$MODELDIR/Instagirlv2.3_high.safetensors" \
  "https://huggingface.co/lynn-mikami/wan-testing/resolve/main/Instagirlv2.3_high.safetensors"

# INSTAGIRL LOW
curl -L -o "$MODELDIR/Insatgirlv2.3_low.safetensors" \
  "https://huggingface.co/allyourtech/instagirl/resolve/main/Insatgirlv2.3_low.safetensors"

# WAN VIDEO LoRA
curl -L -o "$MODELDIR/Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors" \
  "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors"

# 1alexi LoRA
curl -L -o "$MODELDIR/1alexi_LorA_000002750.safetensors" \
  "https://huggingface.co/Zlavik1KK/SEX/resolve/main/1alexi_LorA_000002750.safetensors"

echo "[init] Копирую workflow.json"
cp /workspace/repo/workflow/workflow.json "$WORKFLOWDIR/workflow.json"

echo "[init] Устанавливаю права"
chmod -R 777 "$MODELDIR" "$WORKFLOWDIR"

echo "[init] init.sh завершён."
