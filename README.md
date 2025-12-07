# RunPod ComfyUI Endpoint

This repository contains everything required to deploy a fully automated ComfyUI endpoint on RunPod Serverless.

## Files included

- Dockerfile — builds a fully working ComfyUI environment
- init.sh — downloads models & installs workflow
- workflow.json — your custom workflow

## Important

init.sh must use LF line endings.
Dockerfile automatically cleans CRLF via sed.

## Deployment steps

1. Push this repository to GitHub
2. Create new RunPod Serverless endpoint (GitHub → Dockerfile)
3. Wait until Build succeeds
4. Deploy
5. Call ComfyUI via RunPod API v2
