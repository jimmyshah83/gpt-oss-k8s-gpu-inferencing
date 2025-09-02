"""Load testing gpt-oss models on Kubernetes GPUs"""

import os
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

def _load_questions() -> list[str]:
    """Load questions from questions.txt located next to this module."""
    here = os.path.dirname(__file__)
    questions_path = os.path.join(here, "questions.txt")
    with open(questions_path, "r", encoding="utf-8") as f:
        return [line.strip() for line in f if line.strip()]


def main():
    """Main function to run load tests."""
    test_messages = _load_questions()

    models = ["gpt-oss-20b", "gpt-oss-120b"]
    pairs = [(msg, random.choice(models)) for msg in test_messages]
    for msg, model in pairs:
        send_requests(msg, model)


if __name__ == "__main__":
    main()
