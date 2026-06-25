# Architecture Diagram - AI Customer Support Assistant

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         FLUTTER MOBILE APP                          │
│                     (Cross-platform Frontend)                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ ChatPage (State Management)                                    │ │
│  │  • Text Input Field                                            │ │
│  │  • Chat Message Display                                        │ │
│  │  • Dynamic Widget Renderer                                     │ │
│  └────────┬─────────────────────────────────────────────────────┘ │
│           │                                                         │
│  ┌────────▼─────────────────────────────────────────────────────┐ │
│  │ API Service                                                  │ │
│  │  • HTTP Client (package:http)                               │ │
│  │  • BaseUrl Config (localhost:8000 or LAN IP)               │ │
│  │  • POST /chat endpoint calls                                │ │
│  └────────┬─────────────────────────────────────────────────────┘ │
│           │                                                         │
│  ┌────────▼─────────────────────────────────────────────────────┐ │
│  │ UI Widgets                                                   │ │
│  │  • HotelWidget (Card list with ratings)                     │ │
│  │  • FlightWidget (Flight options)                            │ │
│  │  • TrackingWidget (Order status)                            │ │
│  │  • RefundWidget (Refund status)                             │ │
│  │  • ComplaintWidget (Ticket info)                            │ │
│  │  • EscalationWidget (Agent assignment)                      │ │
│  └────────────────────────────────────────────────────────────┘ │
└────────────────────────┬──────────────────────────────────────────┘
                         │
                         │ POST /chat
                         │ JSON Request: {session_id, message}
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      FASTAPI BACKEND SERVER                         │
│                    (FastAPI + Uvicorn + Python 3.8+)               │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ HTTP Layer (FastAPI)                                         │  │
│  │  • CORS Middleware (allow_origins=["*"])                   │  │
│  │  • Request/Response Serialization                          │  │
│  │  • Error Handling                                          │  │
│  └──────────────┬───────────────────────────────────────────┘  │
│                 │                                               │
│  ┌──────────────▼───────────────────────────────────────────┐  │
│  │ Routes (chat.py)                                         │  │
│  │  • GET / (health check)                                 │  │
│  │  • POST /chat (main endpoint)                          │  │
│  │    └─ Receives: ChatRequest {session_id, message}      │  │
│  │    └─ Returns: ChatResponse {...}                      │  │
│  └──────────────┬───────────────────────────────────────────┘  │
│                 │                                               │
│  ┌──────────────▼───────────────────────────────────────────┐  │
│  │ Service Layer                                            │  │
│  │                                                          │  │
│  │  ┌─────────────────────────────────────────────────┐   │  │
│  │  │ Memory Service (memory_service.py)             │   │  │
│  │  │  • get_context(session_id) → conversation[]   │   │  │
│  │  │  • update_context(session_id, msg, intent)    │   │  │
│  │  │  • Uses in-memory dict (replace with Redis)   │   │  │
│  │  └─────────────────────────────────────────────────┘   │  │
│  │                                                          │  │
│  │  ┌─────────────────────────────────────────────────┐   │  │
│  │  │ Intent Classifier (ollama_services.py)         │   │  │
│  │  │  • Takes: user message + context               │   │  │
│  │  │  • Calls Ollama API (localhost:11434)         │   │  │
│  │  │  • Returns: {intent: "hotel_search", ...}     │   │  │
│  │  │  • Intents:                                    │   │  │
│  │  │    - hotel_search                              │   │  │
│  │  │    - flight_search                             │   │  │
│  │  │    - order_tracking                            │   │  │
│  │  │    - refund_request                            │   │  │
│  │  │    - complaint                                 │   │  │
│  │  │    - escalation                                │   │  │
│  │  │    - unknown                                   │   │  │
│  │  └─────────────────────────────────────────────────┘   │  │
│  │                                                          │  │
│  │  ┌─────────────────────────────────────────────────┐   │  │
│  │  │ Router Service (router_service.py)             │   │  │
│  │  │  • Maps intent → tool function                 │   │  │
│  │  │  • Executes tool and returns result            │   │  │
│  │  │  • INTENT_MAP = {                              │   │  │
│  │  │    "hotel_search": hotel_tool,                │   │  │
│  │  │    "flight_search": flight_tool,              │   │  │
│  │  │    "order_tracking": tracking_tool,           │   │  │
│  │  │    "refund_request": refund_tool,             │   │  │
│  │  │    "complaint": complaint_tool,               │   │  │
│  │  │    "escalation": escalation_tool              │   │  │
│  │  │  }                                              │   │  │
│  │  └─────────────────────────────────────────────────┘   │  │
│  └──────────────┬───────────────────────────────────────────┘  │
│                 │                                               │
│  ┌──────────────▼───────────────────────────────────────────┐  │
│  │ Tool Layer (tools/*.py)                                  │  │
│  │                                                          │  │
│  │  Each tool returns: {ui_type, message, data[]}         │  │
│  │                                                          │  │
│  │  ┌──────────────┐  ┌──────────────┐                     │  │
│  │  │ hotel_tool() │  │ flight_tool()│  ...                │  │
│  │  │              │  │              │                     │  │
│  │  │ Returns:     │  │ Returns:     │                     │  │
│  │  │ {            │  │ {            │                     │  │
│  │  │  ui_type:    │  │  ui_type:    │                     │  │
│  │  │  "hotel_page"│  │  "flight_page"                    │  │
│  │  │  data: [     │  │  data: [     │                     │  │
│  │  │    {id, name,│  │   {airline,  │                     │  │
│  │  │     price,   │  │    price,    │                     │  │
│  │  │     rating}  │  │    from, to} │                     │  │
│  │  │  ]           │  │  ]           │                     │  │
│  │  │ }            │  │ }            │                     │  │
│  │  └──────────────┘  └──────────────┘                     │  │
│  │                                                          │  │
│  │  Data Source: mock_data.py (sample hotels/flights)      │  │
│  │  Future: Replace with real API calls                    │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────┬──────────────────────────────────┘
                              │
                              │ HTTP REST API Call
                              │ POST http://localhost:11434/api/generate
                              │
                              ▼
           ┌──────────────────────────────────┐
           │    OLLAMA LOCAL LLM SERVICE      │
           │  (Runs locally, fully offline)   │
           │                                  │
           │  Model: qwen2.5:1.5b            │
           │  Size: ~1GB                     │
           │                                  │
           │  Process:                       │
           │  1. Receives prompt             │
           │  2. Classifies intent           │
           │  3. Returns JSON response       │
           │                                  │
           │  Example Output:                │
           │  {                              │
           │   "intent": "hotel_search"      │
           │  }                              │
           └──────────────────────────────────┘
```

---

## Data Flow Diagram

```
User Types Message in Flutter App
           │
           ▼
┌──────────────────────────┐
│ Validate & Send to API   │
│ POST /chat               │
│ {                        │
│   session_id: "user-123" │
│   message: "..."         │
│ }                        │
└────────┬─────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│ FastAPI /chat Endpoint           │
│ • Extract session_id & message   │
└────────┬────────────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│ Memory Service                   │
│ Get conversation context         │
└────────┬────────────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│ Ollama Intent Classifier         │
│ Prompt:                          │
│ "Classify this: {message}"       │
│                                  │
│ Returns: {intent: "..."}         │
└────────┬────────────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│ Router Service                   │
│ Route to appropriate tool        │
│ if intent == "hotel_search":     │
│   execute hotel_tool()           │
└────────┬────────────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│ Tool Execution                   │
│ hotel_tool() processes request   │
│ Returns structured data          │
└────────┬────────────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│ Memory Update                    │
│ Store message & intent in        │
│ session context                  │
└────────┬────────────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│ Build Response                   │
│ ChatResponse {                   │
│   success: true,                 │
│   intent: "hotel_search",        │
│   ui_type: "hotel_page",         │
│   message: "Hotels Found",       │
│   data: [{...}, {...}],          │
│   memory: {...}                  │
│ }                                │
└────────┬────────────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│ Send JSON Response to Flutter    │
└────────┬────────────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│ Flutter Receives & Parses        │
│ • Deserialize JSON               │
│ • Extract ui_type                │
└────────┬────────────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│ Dynamic Widget Rendering         │
│ if ui_type == "hotel_page":      │
│   render HotelWidget(data)       │
│ else if ui_type == "flight_page" │
│   render FlightWidget(data)      │
│ ...                              │
└────────┬────────────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│ Display Result in Chat           │
│ User sees structured UI          │
│ (list of hotels, flights, etc.)  │
└──────────────────────────────────┘
```

---

## Component Interaction Matrix

| Component             | Calls                      | Called By      | Purpose                    |
| --------------------- | -------------------------- | -------------- | -------------------------- |
| **main.dart**         | APIService                 | User           | Chat UI & widget rendering |
| **APIService**        | /chat endpoint             | main.dart      | HTTP communication         |
| **routes/chat.py**    | Memory, Classifier, Router | FastAPI        | Request handler            |
| **Memory Service**    | dict operations            | routes/chat.py | Context management         |
| **Intent Classifier** | Ollama API                 | routes/chat.py | LLM classification         |
| **Router Service**    | Tools                      | routes/chat.py | Intent → tool mapping      |
| **Tools**             | mock_data                  | Router         | Data retrieval             |
| **Ollama API**        | LLM model                  | Classifier     | Language processing        |

---

## Deployment Architecture (Production Ready)

```
┌─────────────────────────────────────────────────────────────┐
│                    PRODUCTION SETUP                         │
│                                                              │
│  ┌──────────────┐         ┌──────────────┐                  │
│  │  Flutter App │         │   Web Client │                  │
│  │ (App Store)  │         │  (Firebase)  │                  │
│  └──────┬───────┘         └──────┬───────┘                  │
│         │                        │                          │
│         └────────────┬───────────┘                          │
│                      │                                      │
│                      ▼                                      │
│         ┌─────────────────────────┐                         │
│         │   Load Balancer / CDN   │                         │
│         │   (Cloudflare, AWS)     │                         │
│         └────────────┬────────────┘                         │
│                      │                                      │
│         ┌────────────▼────────────┐                         │
│         │  FastAPI Backend (x3)   │                         │
│         │  - Render / Railway     │                         │
│         │  - AWS Lambda / EC2     │                         │
│         └────────────┬────────────┘                         │
│                      │                                      │
│         ┌────────────▼────────────┐                         │
│         │  Redis Cache + DB       │                         │
│         │  - Session memory       │                         │
│         │  - Conversation history │                         │
│         └────────────┬────────────┘                         │
│                      │                                      │
│         ┌────────────▼────────────┐                         │
│         │  Ollama Inference       │                         │
│         │  - Self-hosted GPU      │                         │
│         │  - OR managed API       │                         │
│         │    (Replicate, HF)      │                         │
│         └────────────┬────────────┘                         │
│                      │                                      │
│         ┌────────────▼────────────┐                         │
│         │  Real External APIs     │                         │
│         │  - Booking.com          │                         │
│         │  - Skyscanner           │                         │
│         │  - Stripe (payments)    │                         │
│         └─────────────────────────┘                         │
└─────────────────────────────────────────────────────────────┘
```

---

## Scaling Strategy

1. **Horizontal Scaling**: Deploy multiple backend instances behind load balancer
2. **Caching**: Redis for session storage and conversation history
3. **Database**: PostgreSQL/MongoDB for persistent data
4. **LLM Optimization**: Use smaller models for faster inference, or GPU acceleration
5. **Frontend CDN**: Serve Flutter app from global CDN

---

## Security Considerations

- ✅ CORS enabled for development (restrict in production)
- ✅ Session validation before processing
- ✅ Input validation via Pydantic models
- ✅ Rate limiting (implement in production)
- ✅ Authentication (add JWT tokens)
- ⚠️ TLS/HTTPS (required for production)
- ⚠️ API key management (use environment variables)
