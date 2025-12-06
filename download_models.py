# download_models.py

"""
Model downloader for the RunPod ComfyUI endpoint.
- Reads /mnt/data/workflow.json
- Extracts model filenames referenced in the workflow
- Downloads mapped URLs (mapping provided below) into:
    /workspace/models/unet   (gguf)
    /workspace/models/lora
    /workspace/models/clip
    /workspace/models/vae
    /workspace/models/checkpoints
- Supports resume and basic existence checks.
"""

import os
import json
import requests
from pathlib import Path
from urllib.parse import urlparse
import sys

WORKFLOW_PATH = "/mnt/data/workflow.json"
OUT_DIR = Path("/workspace/models")
OUT_DIR.mkdir(parents=True, exist_ok=True)

FOLDERS = {
    "gguf": OUT_DIR / "unet",
    "lora": OUT_DIR / "lora",
    "clip": OUT_DIR / "clip",
    "vae": OUT_DIR / "vae",
    "checkpoints": OUT_DIR / "checkpoints"
}
for p in FOLDERS.values():
    p.mkdir(parents=True, exist_ok=True)

# === URL MAP (from user-provided URLs) ===
URL_MAP = {
    "Wan2.2-T2V-A14B-LowNoise-Q8_0.gguf": "https://huggingface.co/QuantStack/Wan2.2-T2V-A14B-GGUF/blob/main/LowNoise/Wan2.2-T2V-A14B-LowNoise-Q8_0.gguf",
    "Wan2.2-T2V-A14B-HighNoise-Q8_0.gguf": "https://huggingface.co/QuantStack/Wan2.2-T2V-A14B-GGUF/resolve/main/HighNoise/Wan2.2-T2V-A14B-HighNoise-Q8_0.gguf",
    "Instagirlv2.3_high.safetensors": "https://huggingface.co/lynn-mikami/wan-testing/resolve/main/Instagirlv2.3_high.safetensors",
    "Instagirlv2.3_low.safetensors": "https://huggingface.co/allyourtech/instagirl/resolve/main/Insatgirlv2.3_low.safetensors",
    "l3n0v0.safetensors": "https://huggingface.co/Danrisi/Lenovo_Qwen/resolve/main/lenovo.safetensors",
    "Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors": "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors",
    "1alexi_LorA_000002750.safetensors": "https://huggingface.co/Zlavik1KK/SEX/resolve/main/1alexi_LorA_000002750.safetensors",
    "umt5_xxl_fp8_e4m3fn_scaled.safetensors": "https://huggingface.co/chatpig/encoder/resolve/main/umt5_xxl_fp8_e4m3fn_scaled.safetensors",
    "wan_2.1_vae.safetensors": "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors",
}

def safe_filename_from_url(url):
    p = urlparse(url).path
    return os.path.basename(p)

def download(url, dest: Path, chunk_size=1 << 20):
    dest_tmp = dest.with_suffix(".part")
    headers = {}
    # resume support
    if dest_tmp.exists():
        existing = dest_tmp.stat().st_size
        headers['Range'] = f'bytes={existing}-'
    else:
        existing = 0

    # Add User-Agent to avoid some blocks
    headers.setdefault("User-Agent", "runpod-comfy-downloader/1.0")

    with requests.get(url, stream=True, headers=headers, allow_redirects=True) as r:
        r.raise_for_status()
        total = r.headers.get('Content-Length')
        if total is not None:
            total = int(total) + existing
        mode = 'ab' if existing else 'wb'
        with open(dest_tmp, mode) as f:
            downloaded = existing
            for chunk in r.iter_content(chunk_size=chunk_size):
                if chunk:
                    f.write(chunk)
                    downloaded += len(chunk)
        dest_tmp.rename(dest)
    return dest

def classify_and_dest(filename: str) -> Path:
    lower = filename.lower()
    if lower.endswith(".gguf"):
        return FOLDERS["gguf"] / filename
    if filename.endswith(".safetensors") or filename.endswith(".pt") or filename.endswith(".pth"):
        if "vae" in lower or "wan_2.1" in lower:
            return FOLDERS["vae"] / filename
        if "clip" in lower or "umt5" in lower:
            return FOLDERS["clip"] / filename
        # heuristics for lora
        if "lora" in lower or "lor" in lower or "l3n0" in lower or filename.lower().startswith("1alexi"):
            return FOLDERS["lora"] / filename
        return FOLDERS["checkpoints"] / filename
    return FOLDERS["checkpoints"] / filename

def extract_model_names_from_workflow(path: str):
    try:
        with open(path, "r", encoding="utf-8") as f:
            wf = json.load(f)
    except Exception as e:
        print(f"ERROR: cannot read workflow.json at {path}: {e}", file=sys.stderr)
        return []
    names = set()
    for node in wf.get("nodes", []):
        for v in node.get("widgets_values", []) or []:
            if isinstance(v, str):
                if any(v.lower().endswith(ext) for ext in [".gguf", ".safetensors", ".pt", ".pth"]):
                    names.add(v)
    return list(names)

def main():
    print("Reading workflow:", WORKFLOW_PATH)
    model_names = extract_model_names_from_workflow(WORKFLOW_PATH)
    print("Models found in workflow.json:", model_names)

    for name in model_names:
        url = URL_MAP.get(name)
        if not url:
            print(f"WARNING: no URL mapping for '{name}', skipping. If you want it downloaded add it to URL_MAP.")
            continue
        dest = classify_and_dest(name)
        if dest.exists():
            print(f"Exists: {dest}")
            continue
        print(f"Downloading {name} -> {dest}")
        try:
            download(url, dest)
            print(f"Saved: {dest}")
        except Exception as e:
            print(f"Failed to download {url}: {e}", file=sys.stderr)

    # download any additional mapped URLs not present in workflow.json
    for fname, url in URL_MAP.items():
        dest = classify_and_dest(fname)
        if dest.exists():
            continue
        print(f"(Extra) Downloading {fname} -> {dest}")
        try:
            download(url, dest)
            print(f"Saved: {dest}")
        except Exception as e:
            print(f"Failed to download {url}: {e}", file=sys.stderr)

if __name__ == "__main__":
    main()
