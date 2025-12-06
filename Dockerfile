# Dockerfile
# Build args:
#   TORCH_CUDA - e.g. cu118 or cpu. Default cu118.
ARG TORCH_CUDA=cu118
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /workspace

# basic deps
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    ca-certificates \
    python3 \
    python3-venv \
    python3-pip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# ensure python points to python3
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# create venv
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# upgrade pip
RUN pip install --upgrade pip

# Install torch - template: change TORCH_CUDA if needed
# If using CPU-only, pass --build-arg TORCH_CUDA=cpu during docker build
RUN if [ "$TORCH_CUDA" = "cpu" ]; then \
      pip install "torch" torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu; \
    else \
      pip install --upgrade "torch" torchvision torchaudio --index-url https://download.pytorch.org/whl/${TORCH_CUDA}; \
    fi

# Clone ComfyUI (default official repo). You can change branch/URL if you have a fork.
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI

# Install ComfyUI requirements (some forks have requirements.txt)
WORKDIR /workspace/ComfyUI
RUN pip install -r requirements.txt || true

WORKDIR /workspace
COPY download_models.py /workspace/download_models.py
COPY handler.py /workspace/handler.py

EXPOSE 8188

# entrypoint: start handler which will download models and start comfy
CMD ["python", "handler.py"]
