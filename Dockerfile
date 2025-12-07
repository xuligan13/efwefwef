FROM runpod/comfyui:latest

# установить bash, curl, wget
RUN apt-get update && apt-get install -y bash curl wget

# копируем проект
COPY . /workspace/repo/

# дать права
RUN chmod +x /workspace/repo/init.sh

# запуск ИМЕННО через bash
RUN bash /workspace/repo/init.sh

# рабочая директория
WORKDIR /workspace/ComfyUI

CMD ["python3", "main.py", "--disable-auto-launch", "--listen", "0.0.0.0", "--port", "3000"]
