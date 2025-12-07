FROM runpod/comfyui:latest

# копируем проект
COPY . /workspace/repo/

# ставим curl, jq если нет
RUN apt-get update && apt-get install -y curl jq

# запускаем setup
RUN chmod +x /workspace/repo/init.sh
RUN /workspace/repo/init.sh

# рабочая директория
WORKDIR /workspace/ComfyUI

CMD ["python", "main.py", "--disable-auto-launch", "--listen", "0.0.0.0", "--port", "3000"]
