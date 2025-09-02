"""Load testing gpt-oss models on Kubernetes GPUs"""

import random
import requests

def send_requests(msg: str, model: str):
    """Send a series of requests to the chat completions endpoint."""    
    for _ in range(10): 
        response = requests.post(f"http://localhost:8000/{model}/v1/chat/completions", json={
            "model": model,
            "messages": [
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user", "content": msg}
            ],
            "temperature": 0.5
        }, timeout=30)
        response.raise_for_status()
        print(response.json())

def main():
    """Main function to run load tests."""
    test_messages = [
        "Explain what MXFP4 quantization is.",
        "What is the difference between CUDA cores and Tensor cores?",
        "How does GPU memory bandwidth affect deep learning performance?",
        "What are the advantages of using mixed precision training?",
        "Explain the concept of GPU kernel fusion in neural networks.",
        "What is the difference between FP16 and BF16 data types?",
        "How does batch size affect GPU utilization in training?",
        "What is GPU memory fragmentation and how to avoid it?",
        "Explain the role of GPU schedulers in deep learning frameworks.",
        "What are the benefits of using multi-GPU training strategies?",
        "How does gradient accumulation help with limited GPU memory?",
        "What is the difference between data parallelism and model parallelism?",
        "Explain how GPU memory coalescing improves performance.",
        "What are the challenges of deploying large language models on GPUs?",
        "How does dynamic batching optimize GPU inference throughput?",
        "What is the impact of sequence length on GPU memory consumption?",
        "Explain the concept of GPU occupancy and how to optimize it.",
        "What are the trade-offs between different quantization techniques?",
        "How does attention mechanism computation scale with GPU resources?",
        "What is the role of GPU caching in transformer model inference?",
        "Explain how to profile GPU performance for deep learning workloads.",
        "What is the difference between compute-bound and memory-bound GPU workloads?",
        "How does NVIDIA's NVLink technology improve multi-GPU communication?",
        "Explain the concept of GPU warp divergence and its performance impact.",
        "What are the benefits and limitations of GPU virtualization in ML workloads?",
        "How does pipeline parallelism help with training large transformer models?",
        "What is the role of CUDA streams in optimizing GPU performance?",
        "Explain how GPU tensor cores accelerate matrix multiplication operations.",
        "What are the key considerations for GPU memory allocation strategies?",
        "How does gradient checkpointing trade compute for memory in GPU training?",
        "What is the impact of GPU memory hierarchy on deep learning performance?"
    ]

    models = ["gpt-oss-20b", "gpt-oss-120b"]
    test_messages = [(msg, random.choice(models)) for msg, _ in test_messages]
    for msg, model in test_messages:
        send_requests(msg, model)
