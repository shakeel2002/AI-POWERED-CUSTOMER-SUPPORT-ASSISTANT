# AI-Powered Customer Support Assistant

A simple offline demo app with a FastAPI backend, Ollama intent routing, and a Flutter mobile frontend.
This project shows how a support chatbot can send requests to mock tools for hotels, flights, orders, refunds and complaints.

## What this does

- Uses Ollama to understand user messages
- Routes requests to the right mock tool
- Sends structured responses to the Flutter app
- Keeps a small session history in memory
- Works offline after the model is downloaded

## Setup

1. Install Ollama: https://ollama.ai
2. Download the model:
   ```bash
   ollama pull qwen2.5:1.5b
   ```
3. Start Ollama:
   ```bash
   ollama serve
   ```
4. Backend setup:
   ```bash
   cd backend
   python -m venv venv
   venv\Scripts\activate
   pip install -r requirements.txt
   uvicorn app:app --host 0.0.0.0 --port 8000 --reload
   ```
5. Frontend setup:
   ```bash
   cd Frontend/flutter_app
   flutter pub get
   flutter run
   ```

## API

Endpoint: `POST /chat`

Request example:

```json
{
  "session_id": "user-123",
  "message": "Show me hotels in Dubai"
}
```

Response example:

```json
{
  "success": true,
  "intent": "hotel_search",
  "ui_type": "hotel_page",
  "message": "Hotels found",
  "data": [
    { "id": 1, "name": "Grand Dubai Hotel", "price": 120, "rating": 4.5 }
  ]
}
```

## Notes

- Use `http://10.0.2.2:8000` for Android emulator.
- Use `http://localhost:8000` for iOS simulator or browser.
- The app uses mock data and is meant for demo/testing only.

## Project layout

- `backend/` - FastAPI code, Ollama service, tools, mock data
- `Frontend/flutter_app/` - Flutter UI and response renderer
