from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from services.ollama_services import classify_intent

app = FastAPI(title="AI Customer Support Assistant")

# Enable CORS so frontend (web/dev servers) can call this API during development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)



class ChatRequest(BaseModel):
    session_id: str
    message: str



@app.get("/")
def root():
    return {
        "message": "Backend Running Successfully"
    }

# Chat Endpoint

@app.post("/chat")
def chat(request: ChatRequest):

    message = request.message

    # 1. Get intent from Ollama
    ai_result = classify_intent(message)

    intent = ai_result.get("intent")

    # 2. TOOL ROUTING (THIS IS WHERE YOUR DATA GOES)
    if intent == "hotel_search":

        response = {
            "intent": "hotel_search",
            "tool_called": "hotel_tool",
            "ui_type": "hotel_page",
            "message": "Available hotels found.",
            # `data` must be a list to match frontend schema `List<dynamic>`
            "data": [
                {
                    "name": "Grand Palace",
                    "price": "$220",
                    "rating": 4.8
                }
            ]
        }

        return response

    # fallback
    return {
        "intent": intent,
        "tool_called": None,
        "ui_type": "text",
        "message": "No matching tool found",
        "data": {}
    }