#!/usr/bin/env python3
"""
Kimi-K2 Server Runner
Provides a simple interface to run the Kimi-K2 model with vLLM
"""

import os
import sys
import argparse
from typing import Optional

def run_vllm_server(
    model_name: str = "moonshot-ai/kimi-k2-instruct",
    host: str = "0.0.0.0",
    port: int = 8000,
    max_model_len: int = 32768,
    tensor_parallel_size: int = 1,
    gpu_memory_utilization: float = 0.95,
    api_key: Optional[str] = None
):
    """Run vLLM OpenAI-compatible API server"""
    
    cmd = [
        sys.executable, "-m", "vllm.entrypoints.openai.api_server",
        "--model", model_name,
        "--served-model-name", "kimi-k2",
        "--host", host,
        "--port", str(port),
        "--max-model-len", str(max_model_len),
        "--tensor-parallel-size", str(tensor_parallel_size),
        "--gpu-memory-utilization", str(gpu_memory_utilization),
        "--trust-remote-code"
    ]
    
    if api_key:
        cmd.extend(["--api-key", api_key])
    
    print(f"Starting Kimi-K2 server on {host}:{port}")
    print(f"Model: {model_name}")
    print(f"Max context length: {max_model_len}")
    print(f"Tensor parallel size: {tensor_parallel_size}")
    print(f"GPU memory utilization: {gpu_memory_utilization}")
    
    import subprocess
    subprocess.run(cmd)

def main():
    parser = argparse.ArgumentParser(description="Run Kimi-K2 Model Server")
    parser.add_argument("--model", default=os.getenv("MODEL_NAME", "moonshot-ai/kimi-k2-instruct"),
                        help="Model name or path")
    parser.add_argument("--host", default=os.getenv("API_HOST", "0.0.0.0"),
                        help="Host to bind to")
    parser.add_argument("--port", type=int, default=int(os.getenv("API_PORT", 8000)),
                        help="Port to bind to")
    parser.add_argument("--max-model-len", type=int, 
                        default=int(os.getenv("MAX_MODEL_LEN", 32768)),
                        help="Maximum model context length")
    parser.add_argument("--tensor-parallel-size", type=int,
                        default=int(os.getenv("TENSOR_PARALLEL_SIZE", 1)),
                        help="Number of GPUs for tensor parallelism")
    parser.add_argument("--gpu-memory-utilization", type=float,
                        default=float(os.getenv("GPU_MEMORY_UTILIZATION", 0.95)),
                        help="GPU memory utilization (0-1)")
    parser.add_argument("--api-key", default=os.getenv("API_KEY"),
                        help="API key for authentication")
    
    args = parser.parse_args()
    
    run_vllm_server(
        model_name=args.model,
        host=args.host,
        port=args.port,
        max_model_len=args.max_model_len,
        tensor_parallel_size=args.tensor_parallel_size,
        gpu_memory_utilization=args.gpu_memory_utilization,
        api_key=args.api_key
    )

if __name__ == "__main__":
    main()