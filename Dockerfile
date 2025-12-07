FROM runpod/comfyui:latest

# -----------------------------
# 1. Basic utilities (bash, curl, wget)
# -----------------------------
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    wget \
    && apt-get clean

# -----------------------------
# 2. Create working directories
# -----------------------------
RUN mkdir -p /workspace/repo
RUN mkdir -p /workspace/ComfyUI/models
RUN mkdir -p /workspace/ComfyUI/user/default/workflows

# -----------------------------
# 3. Copy repo into container
# -----------------------------
COPY . /workspace/repo/

# -----------------------------
# 4. Fix Windows line endings (CRLF → LF)
# -----------------------------
RUN sed -i 's/\r$//' /workspace/repo/init.sh

# -----------------------------
# 5. Make init.sh executable
# -----------------------------
RUN chmod +x /workspace/repo/init.sh

# -----------------------------
# 6. Run init.sh THROUGH BASH
# -----------------------------
RUN bash /workspace/repo/init.sh

# -----------------------------
# 7. Set working directory
# -----------------------------
WORKDIR /workspace/ComfyUI

# -----------------------------
# 8. Launch ComfyUI API server
# -----------------------------
CMD ["python3", "main.py", "--disable-auto-launch", "--listen", "0.0.0.0", "--port", "3000"]
