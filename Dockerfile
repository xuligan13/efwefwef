FROM runpod/comfy-ui

# Устанавливаем необходимые утилиты
RUN apt-get update && apt-get install -y git curl && apt-get clean

# Создаём директории, если их нет
RUN mkdir -p /workspace/repo && \
    mkdir -p /workspace/models && \
    mkdir -p /workspace/workflow

# Копируем init.sh и workflow.json из твоего репозитория в контейнер
COPY init.sh /workspace/repo/init.sh
COPY workflow/workflow.json /workspace/workflow/workflow.json

# Делаем init.sh исполнимым
RUN chmod +x /workspace/repo/init.sh

# Указываем рабочую директорию
WORKDIR /workspace

# Команда запуска:
# 1. Выполняет init.sh (скачивает модели с HuggingFace)
# 2. Запускает ComfyUI сервер RunPod
CMD ["/bin/bash", "-c", "/workspace/repo/init.sh && /start.sh"]
