# syntax=docker/dockerfile:1
FROM python:3.12-slim

ENV CUDA_MODULE_LOADING=LAZY
ENV CUDA_VISIBLE_DEVICES=0
ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies
ARG ULTIMATE_RVC_VERSION
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/root/.cache/pip \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    ffmpeg \
    sox && \
    pip install torch==2.7.0+cu128 torchaudio==2.7.0+cu128 --index-url https://download.pytorch.org/whl/cu128 && \
    if [ -n "${ULTIMATE_RVC_VERSION}" ]; then \
        pip install ultimate-rvc==${ULTIMATE_RVC_VERSION}; \
    else \
        pip install ultimate-rvc; \
    fi && \
    apt-get remove --purge -y build-essential && \
    apt-get autoremove --purge -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip install typer==0.16.0 && \
    urvc --help # Verify installation and pre-initialize

# TODO: remove `pip install typer==0.16.0` once upstream fixes the CLI issue

# Set environment variables
ENV URVC_MODELS_DIR=/data/urvc/models
ENV URVC_AUDIO_DIR=/data/urvc/audio
ENV URVC_TEMP_DIR=/data/urvc/temp
ENV URVC_CONFIG_DIR=/data/urvc/configs
ENV URVC_LOGS_DIR=/data/urvc/logs
ENV URVC_CONSOLE_LOG_LEVEL=INFO
ENV GRADIO_SERVER_NAME=0.0.0.0
ENV GRADIO_SERVER_PORT=7860

