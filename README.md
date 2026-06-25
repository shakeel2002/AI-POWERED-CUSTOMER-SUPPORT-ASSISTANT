# AI-POWERED CUSTOMER SUPPORT ASSISTANT

An intelligent, offline-first customer support system combining a **FastAPI backend** with **Ollama LLM** and a **Flutter mobile frontend**. The system uses intent classification to route customer queries to specialized tools (hotel search, flight booking, order tracking, refunds, complaints, escalations).

**Live Demo:** [GitHub Repository](https://github.com/shakeel2002/AI-POWERED-CUSTOMER-SUPPORT-ASSISTANT)

---

## 🎯 Key Features

- **Offline-First Architecture**: Runs completely offline after initial model download
- **Intent Classification**: Uses Ollama LLM (Qwen2.5) to classify customer intents
- **Multi-Tool Router**: Dispatches to specialized tools (hotels, flights, tracking, refunds, complaints, escalations)
- **Session Memory**: Maintains conversation context across requests
- **Dynamic UI**: Flutter app renders different UIs based on tool responses (hotel listings, flight options, etc.)
- **CORS-Enabled**: Easy frontend-backend communication during development
- **Mock Data**: Pre-configured sample data for testing without external APIs

---

## 📋 Prerequisites

### Backend Requirements

- **Python 3.8+**
- **Ollama** (for running LLM locally)
- **FastAPI & Dependencies** (installed via pip)

### Frontend Requirements

- **Flutter SDK 2.18.0+**
- **Dart 2.18.0+**
- **iOS/Android SDK** (for mobile testing)

### System Requirements

- **Disk Space**: ~5GB (for Ollama Qwen2.5 model)
- **RAM**: 8GB minimum (16GB recommended for smooth operation)
- **Network**: Internet required for initial Ollama model download only

---

## 🚀 Quick Start Setup

### 1. **Install Ollama**

Download and install Ollama from: https://ollama.ai

Verify installation:

```bash
ollama --version
```

### 2. **Pull the Ollama Model**

```bash
ollama pull qwen2.5:1.5b
```

This downloads the 1.5B parameter Qwen2.5 model (~1GB). After this, everything runs offline.

**Start Ollama Service:**

```bash
ollama serve
```

Leave this terminal running. Ollama listens on `http://localhost:11434`

### 3. **Set Up Backend**

```bash
# Navigate to backend directory
cd backend

# Create Python virtual environment
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

**Create `requirements.txt` in `/backend`:**

```
fastapi==0.104.1
uvicorn==0.24.0
pydantic==2.4.2
python-multipart==0.0.6
requests==2.31.0
python-cors==1.3.6
```

**Start Backend Server:**

```bash
uvicorn app:app --host 0.0.0.0 --port 8000 --reload
```

Backend runs on `http://localhost:8000`

### 4. **Set Up Flutter Frontend**

```bash
# Navigate to frontend directory
cd Frontend/flutter_app

# Get dependencies
flutter pub get

# For Android Emulator
flutter run -d emulator-5554

# For iOS Simulator
flutter run -d iPhone-14

# For web (development)
flutter run -d chrome
```

**Configure API Endpoint** in `lib/services/api_service.dart`:

```dart
// Android Emulator (talks to host machine)
static const String baseUrl = 'http://10.0.2.2:8000';

// iOS Simulator (talks to host machine)
static const String baseUrl = 'http://localhost:8000';

// Real Device (use your machine's LAN IP)
static const String baseUrl = 'http://192.168.1.10:8000';
```

---

## 🏗️ Architecture Overview

### System Design

```
┌─────────────────────────────────────────────────────────────┐
│                    FLUTTER MOBILE APP                       │
│  (Chat UI + Dynamic Widget Renderer + API Service)          │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ POST /chat
                         │ {session_id, message}
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    FASTAPI BACKEND                          │
│ ┌──────────────────────────────────────────────────────────┐│
│ │ Routes                                                   ││
│ │  └─ POST /chat → ChatController                         ││
│ ├──────────────────────────────────────────────────────────┤│
│ │ Services                                                 ││
│ │  ├─ Memory Service (session context tracking)           ││
│ │  ├─ Intent Classifier (Ollama LLM integration)          ││
│ │  └─ Router Service (tool dispatch)                      ││
│ ├──────────────────────────────────────────────────────────┤│
│ │ Tools (Intent Executors)                                ││
│ │  ├─ hotel_tool() → {hotels[]}                           ││
│ │  ├─ flight_tool() → {flights[]}                         ││
│ │  ├─ tracking_tool() → {orders[]}                        ││
│ │  ├─ refund_tool() → {refunds[]}                         ││
│ │  ├─ complaint_tool() → {ticket}                         ││
│ │  └─ escalation_tool() → {escalation_status}            ││
│ └──────────────────────────────────────────────────────────┘│
└────────────────┬────────────────────────────────────────────┘
                 │
                 │ REST API (localhost:11434)
                 ▼
    ┌────────────────────────────────┐
    │      OLLAMA LLM SERVICE        │
    │   (qwen2.5:1.5b model)         │
    │   Runs offline locally         │
    └────────────────────────────────┘
```

### Key Design Decisions

| Component             | Choice                | Rationale                                             |
| --------------------- | --------------------- | ----------------------------------------------------- |
| **LLM**               | Ollama + Qwen2.5 1.5B | Lightweight, runs offline, good intent classification |
| **Backend Framework** | FastAPI               | Fast, easy to prototype, great async support          |
| **Frontend**          | Flutter               | Cross-platform (iOS/Android/Web), native performance  |
| **Memory**            | In-process dict       | Demo purposes; use Redis/DB for production            |
| **Tools**             | Mock data             | Fast testing; replace with real APIs in production    |

---

## 📡 API Reference

### **POST /chat**

**Request:**

```json
{
  "session_id": "user-123",
  "message": "Show me available hotels in Dubai"
}
```

**Response:**

```json
{
  "success": true,
  "intent": "hotel_search",
  "ui_type": "hotel_page",
  "message": "Hotels Found",
  "data": [
    {
      "id": 1,
      "name": "Grand Dubai Hotel",
      "price": 120,
      "rating": 4.5
    },
    {
      "id": 2,
      "name": "Palm Stay",
      "price": 90,
      "rating": 4.2
    }
  ],
  "memory": {
    "session_id": "user-123",
    "conversation_history": [
      { "role": "user", "content": "Show me available hotels in Dubai" }
    ]
  }
}
```

### **Supported Intents & UI Types**

| Intent           | UI Type           | Response Data                  | Example Use Case          |
| ---------------- | ----------------- | ------------------------------ | ------------------------- |
| `hotel_search`   | `hotel_page`      | `[{id, name, price, rating}]`  | "Find hotels in Dubai"    |
| `flight_search`  | `flight_page`     | `[{airline, price, from, to}]` | "Book a flight to London" |
| `order_tracking` | `tracking_page`   | `[{order_id, status, eta}]`    | "Where's my order?"       |
| `refund_request` | `refund_page`     | `{refund_id, status, amount}`  | "I want a refund"         |
| `complaint`      | `complaint_page`  | `{ticket_id, status}`          | "File a complaint"        |
| `escalation`     | `escalation_page` | `{ticket_id, agent}`           | "Escalate my issue"       |

---

## 🔧 Testing with cURL / Postman

### **cURL Example:**

```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test-user-1",
    "message": "I need a hotel in Dubai"
  }'
```

### **Postman Setup:**

1. **Method:** POST
2. **URL:** `http://localhost:8000/chat`
3. **Headers:**
   - `Content-Type: application/json`
4. **Body (JSON):**
   ```json
   {
     "session_id": "postman-test",
     "message": "Show me flights to London"
   }
   ```
5. **Send** and view response

---

## 📁 Project Structure

```
.
├── backend/
│   ├── app.py                      # FastAPI entry point
│   ├── architecture.md             # System design diagram
│   ├── requirements.txt            # Python dependencies
│   ├── routes/
│   │   ├── __init__.py
│   │   └── chat.py                 # Chat endpoint logic
│   ├── schemas/
│   │   ├── request.py              # ChatRequest model
│   │   └── response.py             # ChatResponse model
│   ├── services/
│   │   ├── __init__.py
│   │   ├── memory_service.py       # Session/context management
│   │   ├── ollama_services.py      # LLM intent classification
│   │   └── router_service.py       # Tool dispatch logic
│   ├── tools/
│   │   ├── __init__.py
│   │   ├── hotel_tool.py           # Hotel search tool
│   │   ├── flight_tool.py          # Flight search tool
│   │   ├── tracking_tool.py        # Order tracking tool
│   │   ├── refund_tool.py          # Refund processing tool
│   │   ├── complaint_tool.py       # Complaint filing tool
│   │   └── escalation_tool.py      # Escalation tool
│   └── data/
│       └── mock_data.py            # Sample hotels, flights, etc.
│
└── Frontend/
    └── flutter_app/
        ├── pubspec.yaml            # Flutter dependencies
        ├── README.md               # Flutter setup guide
        ├── lib/
        │   ├── main.dart           # Chat UI + dynamic renderer
        │   ├── models/
        │   │   └── chat_response.dart  # Response model
        │   ├── services/
        │   │   └── api_service.dart    # HTTP client to backend
        │   └── widgets/
        │       └── hotel_widget.dart   # Hotel listing UI component
        └── build/                  # Build artifacts (auto-generated)
```

---

## 🔌 Running Fully Offline

**After the initial setup, here's how to run completely offline:**

1. **Ollama model already downloaded?**

   ```bash
   ollama list
   # Should show: qwen2.5:1.5b
   ```

2. **Start Ollama (offline mode):**

   ```bash
   ollama serve
   ```

3. **Start Backend:**

   ```bash
   cd backend
   source venv/bin/activate  # or venv\Scripts\activate on Windows
   uvicorn app:app --host 0.0.0.0 --port 8000
   ```

4. **Start Flutter App:**
   ```bash
   cd Frontend/flutter_app
   flutter run
   ```

✅ **Everything runs offline after model download!**

---

## 🎨 Screenshots & Demo

### Flutter App Chat Interface

- User sends: _"Show me hotels in Dubai"_
- Backend classifies intent: `hotel_search`
- Flutter dynamically renders `HotelWidget` with listings
- Same flow for flights, tracking, refunds, complaints, escalations

_[Add screenshots of the Flutter app in action here]_

---

## 🛠️ Development & Customization

### Adding a New Intent

1. **Create a tool** in `backend/tools/my_tool.py`:

   ```python
   def my_tool():
       return {
           "ui_type": "my_page",
           "message": "Success",
           "data": [...]
       }
   ```

2. **Register in router** (`backend/services/router_service.py`):

   ```python
   INTENT_MAP = {
       ...
       "my_intent": my_tool,
   }
   ```

3. **Create Flutter widget** in `Frontend/flutter_app/lib/widgets/my_widget.dart`

4. **Render in main.dart** based on `ui_type: "my_page"`

### Connecting to Real APIs

Replace mock data in tools:

```python
# Before: return mock_data
# After: return requests.get("https://real-api.com/hotels").json()
```

---

## 🐛 Troubleshooting

| Issue                                | Solution                                                                      |
| ------------------------------------ | ----------------------------------------------------------------------------- |
| **Backend won't start**              | Ensure `pip install -r requirements.txt` completed                            |
| **Ollama connection error**          | Check `ollama serve` is running on `localhost:11434`                          |
| **Flutter can't reach backend**      | Check `ApiService.baseUrl` matches your setup (10.0.2.2 for Android emulator) |
| **Model takes forever to download**  | Qwen2.5 1.5B is ~1GB; internet speed matters. Leave it running.               |
| **Memory service persists old data** | Restart backend (in-process dict clears on exit)                              |

---

## 📦 Dependencies

### Backend

```
fastapi==0.104.1
uvicorn==0.24.0
pydantic==2.4.2
requests==2.31.0
```

### Frontend

```
flutter: sdk
http: ^0.13.6
provider: ^6.0.5
```

### System

```
Ollama + qwen2.5:1.5b model (~1GB)
```

---

## 🚀 Production Deployment (Future)

- **Backend**: Deploy FastAPI to Render, Railway, or AWS Lambda
- **Ollama**: Use managed inference API (Replicate, HuggingFace, or self-hosted GPU)
- **Memory**: Replace in-process dict with Redis/PostgreSQL
- **Tools**: Connect real APIs (Booking.com, Skyscanner, etc.)
- **Frontend**: Build and deploy to App Stores or Firebase Hosting

---

## 📝 License

MIT License - Feel free to use, modify, and distribute.

---

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request with clear descriptions

---

## 📧 Support

For issues, questions, or feature requests, please open a GitHub issue or reach out to the maintainers.

---

**Happy Building! 🚀**

Made with ❤️ for intelligent customer support.
