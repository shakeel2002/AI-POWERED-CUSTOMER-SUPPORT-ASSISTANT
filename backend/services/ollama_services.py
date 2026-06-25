import requests
import json

OLLAMA_URL = "http://localhost:11434/api/generate"

def classify_intent(message, context=""):

    prompt = f"""
You are an intent classifier.

Available intents:

order_tracking
refund_request
complaint
escalation
hotel_search
flight_search

Conversation Context:
{context}

User:
{message}

Return ONLY valid JSON.

Example:

{{"intent":"hotel_search"}}
"""

    response = requests.post(
        OLLAMA_URL,
        json={
            "model": "qwen2.5:1.5b",
            "prompt": prompt,
            "stream": False
        }
    )

    result = response.json()["response"]

    try:
        return json.loads(result)
    except:
        return {"intent": "unknown"}