# RunPod ComfyUI Custom Endpoint Template

Этот репозиторий — шаблон для запуска ComfyUI как RunPod Custom Endpoint.
Он автоматически скачивает модели, кладёт их в правильные папки и запускает ComfyUI в headless/api режиме.

## Содержимое
- `Dockerfile` — собирает образ, устанавливает зависимости и запускает `handler.py`.
- `handler.py` — стартовый скрипт: скачивает модели, запускает ComfyUI и поднимает Flask API.
- `download_models.py` — скачивает модели, перечисленные в `workflow.json`, и дополнительные URL из маппинга.
- `workflow.json` — (опционально) твой workflow — мы положили сюда копию для удобства.

## Быстрый старт (локально)
1. Скопируй `workflow.json` в `./workflow.json` или используй монтирование.
2. Построй Docker-образ:
```bash
docker build --build-arg TORCH_CUDA=cu118 -t comfy-runpod:latest .
```
3. Запусти контейнер (добавь GPU-флаги при необходимости):
```bash
docker run --rm -p 8188:8188 -v /full/path/to/workflow.json:/mnt/data/workflow.json comfy-runpod:latest
```
4. Проверь `/health` и `POST /run` на порту 8188.

## RunPod
1. Создай новый Custom Endpoint на RunPod.
2. Выбери "Import from GitHub" и укажи этот репозиторий.
3. При необходимости добавь переменные окружения:
   - `HF_TOKEN` — токен HuggingFace для приватных репозиториев.
   - `TORCH_CUDA` — cu118, cu121 или `cpu`.

## Примечания и доработки
- Команда запуска ComfyUI (`COMFY_CMD`) может отличаться в форках — проверь `handler.py`.
- `download_models.py` использует URL маппинг; если имена в `workflow.json` и URL не совпадают, добавь соответствующие записи.
- Для приватных HF-репозиториев добавь использование `HF_TOKEN` в `download_models.py` (Authorization header).

