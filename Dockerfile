# ============================================
# Kimi-K2 Docker Image
# ============================================
# 
# 시스템 요구사항:
# - GPU: NVIDIA A100 80GB (권장) 또는 2x A100 40GB
# - VRAM: 최소 64GB (전체 정밀도), 32GB (INT8), 16GB (INT4)
# - RAM: 최소 128GB 권장
# - Storage: 100GB+ (모델 다운로드 및 캐시)
# - CUDA: 11.8 이상
# - Driver: 515.65.01 이상
#
# 성능 사양:
# - 모델 크기: 1조 파라미터 (활성화: 320억)
# - 컨텍스트 길이: 최대 128K 토큰
# - 추론 속도: ~50-100 tokens/sec (A100 기준)
# - 동시 요청: GPU 메모리에 따라 1-10개
#
# ============================================

# Use Python 3.10 slim as base image
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install PyTorch with CUDA support
# CUDA 11.8 for A100 GPU optimization
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# Install vLLM for inference with flash attention support
# vLLM은 A100의 Tensor Core를 최적으로 활용
RUN pip install --no-cache-dir vllm flash-attn

# Install additional dependencies
RUN pip install --no-cache-dir \
    transformers \
    accelerate \
    sentencepiece \
    protobuf \
    fastapi \
    uvicorn \
    pydantic

# Create directory for model cache
RUN mkdir -p /app/models

# Set environment variables
ENV HF_HOME=/app/models
ENV TRANSFORMERS_CACHE=/app/models
ENV CUDA_VISIBLE_DEVICES=0

# Copy application files (if any)
COPY . /app/

# Expose the API port
EXPOSE 8000

# Performance optimization settings
ENV PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512
ENV CUDA_LAUNCH_BLOCKING=0
ENV OMP_NUM_THREADS=48

# Default command to run the vLLM server
# 성능 최적화 파라미터 포함
CMD ["python", "-m", "vllm.entrypoints.openai.api_server", \
     "--model", "moonshot-ai/kimi-k2-instruct", \
     "--served-model-name", "kimi-k2", \
     "--host", "0.0.0.0", \
     "--port", "8000", \
     "--max-model-len", "32768", \
     "--tensor-parallel-size", "1", \
     "--gpu-memory-utilization", "0.95", \
     "--max-num-seqs", "256", \
     "--trust-remote-code", \
     "--enable-prefix-caching"]