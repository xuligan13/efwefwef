FROM ghcr.io/comfyanonymous/comfyui:latest

# устанавливаем утилиты
RUN apt-get update && apt-get install -y git curl && apt-get clean

# создаем каталоги
RUN mkdir -p /workspace/repo \
    && mkdir -p /workspace/models \
    && mkdir -p /workspace/workflow

# копируем файлы
COPY init.sh /workspace/repo/init.sh
COPY workflow.json /workspace/workflow/workflow.json

RUN chmod +x /workspace/repo/init.sh

WORKDIR /workspace

# запускаем init + comfyui
CMD ["/bin/bash", "-c", "/workspace/repo/init.sh && python3 /usr/local/comfyui/main.py --listen 0.0.0.0 --port 8188"]
