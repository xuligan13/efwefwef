# handler.py

"""
RunPod handler for the ComfyUI endpoint.

Behavior:
- On container start, runs download_models.py to ensure models are present.
- Starts ComfyUI (assumes ComfyUI code is at /workspace/ComfyUI).
- Starts a small Flask HTTP server exposing:
    /health - basic status
    /run    - copy workflow.json into ComfyUI/workflows (and optionally trigger run via API/CLI)
Notes:
- Adjust COMFY_CMD if your ComfyUI fork requires different startup flags.
- For private HF repos, set HF_TOKEN env var and modify download_models.py to use it.
"""
import os
import subprocess
import threading
import time
from pathlib import Path
from flask import Flask, jsonify, request

WORKDIR = Path("/workspace")
COMFY_DIR = WORKDIR / "ComfyUI"
MODELS_DIR = WORKDIR / "models"
WORKFLOW_SRC = Path("/mnt/data/workflow.json")
COMFY_WORKFLOWS = COMFY_DIR / "workflows"
COMFY_WORKFLOWS.mkdir(parents=True, exist_ok=True)

# Command to start ComfyUI in headless/api mode. Edit if your fork differs.
COMFY_CMD = ["python", "main.py", "--api", "--headless"]

app = Flask(__name__)

def run_download_models():
    print("Starting download_models.py ...")
    subprocess.run(["python", "/workspace/download_models.py"], check=False)

def start_comfy():
    print("Starting ComfyUI ...")
    p = subprocess.Popen(COMFY_CMD, cwd=str(COMFY_DIR), stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    def _forward():
        for line in p.stdout:
            print("[ComfyUI]", line.rstrip())
    t = threading.Thread(target=_forward, daemon=True)
    t.start()
    return p

@app.route("/health", methods=["GET"])
def health():
    running = COMFY_DIR.exists()
    return jsonify({"status": "ok", "comfy_exists": running, "models_dir": str(MODELS_DIR)})

@app.route("/run", methods=["POST"])
def run_workflow():
    data = request.get_json(silent=True) or {}
    wf_path = data.get("workflow_path", str(WORKFLOW_SRC))
    target = COMFY_WORKFLOWS / "deployed_workflow.json"
    try:
        with open(wf_path, "r", encoding="utf-8") as fr, open(target, "w", encoding="utf-8") as fw:
            fw.write(fr.read())
    except Exception as e:
        return jsonify({"ok": False, "error": f"cannot copy workflow: {e}"}), 500

    # TODO: Trigger ComfyUI to execute the workflow. Many forks have an API or CLI.
    return jsonify({"ok": True, "message": "workflow deployed", "path": str(target)})

if __name__ == "__main__":
    # 1) download models (blocking)
    run_download_models()

    # 2) start comfy
    comfy_proc = start_comfy()
    # give comfy some time to boot
    time.sleep(6)

    # 3) start flask server
    app.run(host="0.0.0.0", port=8188)
