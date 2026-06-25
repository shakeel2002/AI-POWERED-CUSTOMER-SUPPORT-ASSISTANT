# API Testing Guide - cURL & Postman Examples

## Prerequisites

Before testing, ensure:

1. ✅ Ollama is running: `ollama serve`
2. ✅ Backend is running: `uvicorn app:app --host 0.0.0.0 --port 8000`
3. ✅ Ollama model is downloaded: `ollama pull qwen2.5:1.5b`

---

## Health Check

### **GET /** - Backend Status

**cURL:**

```bash
curl -X GET http://localhost:8000/
```

**Expected Response:**

```json
{
  "message": "Backend Running Successfully"
}
```

---

## Main Chat Endpoint

### **POST /chat** - Send Message & Get Response

---

## Test Case 1: Hotel Search

### cURL Command:

```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "user-demo-1",
    "message": "I want to book a hotel in Dubai"
  }'
```

### Request JSON:

```json
{
  "session_id": "user-demo-1",
  "message": "I want to book a hotel in Dubai"
}
```

### Expected Response:

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
    },
    {
      "id": 3,
      "name": "Luxury Marina",
      "price": 220,
      "rating": 4.8
    },
    {
      "id": 4,
      "name": "Emerates Palace",
      "price": 120,
      "rating": 4.5
    },
    {
      "id": 5,
      "name": "Palm Restaurant",
      "price": 90,
      "rating": 4.2
    },
    {
      "id": 6,
      "name": "Marina Hotel",
      "price": 220,
      "rating": 4.8
    }
  ],
  "memory": {
    "session_id": "user-demo-1",
    "conversation_history": [
      {
        "role": "user",
        "message": "I want to book a hotel in Dubai"
      }
    ]
  }
}
```

---

## Test Case 2: Flight Search

### cURL Command:

```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "user-demo-1",
    "message": "Show me flights to London"
  }'
```

### Expected Response:

```json
{
  "success": true,
  "intent": "flight_search",
  "ui_type": "flight_page",
  "message": "Flights Found",
  "data": [
    {
      "airline": "Emirates",
      "price": 450,
      "from": "Dubai",
      "to": "London"
    },
    {
      "airline": "Etihad",
      "price": 420,
      "from": "Dubai",
      "to": "London"
    },
    {
      "airline": "Qatar Airways",
      "price": 400,
      "from": "Dubai",
      "to": "London"
    }
  ],
  "memory": {
    "session_id": "user-demo-1",
    "conversation_history": [
      {
        "role": "user",
        "message": "I want to book a hotel in Dubai"
      },
      {
        "role": "user",
        "message": "Show me flights to London"
      }
    ]
  }
}
```

---

## Test Case 3: Order Tracking

### cURL Command:

```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "user-demo-1",
    "message": "Where is my order?"
  }'
```

### Expected Response:

```json
{
  "success": true,
  "intent": "order_tracking",
  "ui_type": "tracking_page",
  "message": "Order Status Retrieved",
  "data": {
    "order_id": "ORD-12345",
    "status": "In Transit",
    "eta": "2024-01-20",
    "tracking_number": "TRK-98765"
  },
  "memory": {...}
}
```

---

## Test Case 4: Refund Request

### cURL Command:

```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "user-demo-1",
    "message": "I want a refund for my recent purchase"
  }'
```

### Expected Response:

```json
{
  "success": true,
  "intent": "refund_request",
  "ui_type": "refund_page",
  "message": "Refund Processed",
  "data": {
    "refund_id": "REF-54321",
    "status": "Approved",
    "amount": 99.99,
    "estimated_time": "5-7 business days"
  },
  "memory": {...}
}
```

---

## Test Case 5: Complaint Filing

### cURL Command:

```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "user-demo-1",
    "message": "I have a complaint about my service"
  }'
```

### Expected Response:

```json
{
  "success": true,
  "intent": "complaint",
  "ui_type": "complaint_page",
  "message": "Complaint Registered",
  "data": {
    "ticket_id": "TKT-78901",
    "status": "Open",
    "created_at": "2024-01-15",
    "category": "Service Quality"
  },
  "memory": {...}
}
```

---

## Test Case 6: Escalation

### cURL Command:

```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "user-demo-1",
    "message": "I need to talk to a manager"
  }'
```

### Expected Response:

```json
{
  "success": true,
  "intent": "escalation",
  "ui_type": "escalation_page",
  "message": "Issue Escalated",
  "data": {
    "ticket_id": "TKT-78901",
    "escalated_to": "Manager",
    "assigned_agent": "John Smith",
    "expected_response": "30 minutes"
  },
  "memory": {...}
}
```

---

## Test Case 7: Unknown Intent

### cURL Command:

```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "user-demo-1",
    "message": "What is the weather today?"
  }'
```

### Expected Response:

```json
{
  "success": true,
  "intent": "unknown",
  "ui_type": "text",
  "message": "I did not understand your request. Please try again.",
  "data": [],
  "memory": {...}
}
```

---

## Postman Setup

### 1. Create New Request

- **Method**: POST
- **URL**: `http://localhost:8000/chat`

### 2. Headers Tab

| Key            | Value              |
| -------------- | ------------------ |
| `Content-Type` | `application/json` |

### 3. Body Tab (raw, JSON)

```json
{
  "session_id": "postman-test-user",
  "message": "Show me hotels in Dubai"
}
```

### 4. Click Send

You should see a 200 OK response with the chat response JSON.

### 5. Save Collection

- Click **Save** (top right)
- Collection Name: `AI Customer Support API`
- Request Name: `Chat - Hotel Search`
- Environment: Create a new environment with:
  - Key: `base_url`
  - Value: `http://localhost:8000`

### 6. Environment Variable Usage

Replace hardcoded URL:

```
{{base_url}}/chat
```

---

## Batch Testing Script (Bash)

**Save as `test_api.sh`:**

```bash
#!/bin/bash

BASE_URL="http://localhost:8000"
SESSION_ID="batch-test-$(date +%s)"

echo "🚀 Starting API tests..."
echo "Session ID: $SESSION_ID"
echo ""

# Test 1: Health Check
echo "1️⃣ Health Check..."
curl -s -X GET "$BASE_URL/" | jq '.'
echo -e "\n"

# Test 2: Hotel Search
echo "2️⃣ Hotel Search..."
curl -s -X POST "$BASE_URL/chat" \
  -H "Content-Type: application/json" \
  -d "{
    \"session_id\": \"$SESSION_ID\",
    \"message\": \"I need a hotel in Dubai\"
  }" | jq '.'
echo -e "\n"

# Test 3: Flight Search
echo "3️⃣ Flight Search..."
curl -s -X POST "$BASE_URL/chat" \
  -H "Content-Type: application/json" \
  -d "{
    \"session_id\": \"$SESSION_ID\",
    \"message\": \"Show me flights to London\"
  }" | jq '.'
echo -e "\n"

# Test 4: Order Tracking
echo "4️⃣ Order Tracking..."
curl -s -X POST "$BASE_URL/chat" \
  -H "Content-Type: application/json" \
  -d "{
    \"session_id\": \"$SESSION_ID\",
    \"message\": \"Where is my order?\"
  }" | jq '.'
echo -e "\n"

# Test 5: Refund
echo "5️⃣ Refund Request..."
curl -s -X POST "$BASE_URL/chat" \
  -H "Content-Type: application/json" \
  -d "{
    \"session_id\": \"$SESSION_ID\",
    \"message\": \"I want a refund\"
  }" | jq '.'
echo -e "\n"

echo "✅ All tests completed!"
```

**Run it:**

```bash
chmod +x test_api.sh
./test_api.sh
```

---

## Python Testing Script

**Save as `test_api.py`:**

```python
import requests
import json
from datetime import datetime

BASE_URL = "http://localhost:8000"
SESSION_ID = f"python-test-{datetime.now().timestamp()}"

def test_api(message, test_name):
    """Test a single API call"""
    print(f"\n🧪 Testing: {test_name}")
    print(f"📤 Message: {message}")

    response = requests.post(
        f"{BASE_URL}/chat",
        json={
            "session_id": SESSION_ID,
            "message": message
        },
        headers={"Content-Type": "application/json"}
    )

    print(f"✅ Status: {response.status_code}")
    print(f"📥 Response:")
    print(json.dumps(response.json(), indent=2))

    return response.json()

if __name__ == "__main__":
    print("🚀 Starting API tests...")
    print(f"Session: {SESSION_ID}\n")

    # Test cases
    test_api("I need a hotel in Dubai", "Hotel Search")
    test_api("Show me flights to London", "Flight Search")
    test_api("Where is my order?", "Order Tracking")
    test_api("I want a refund", "Refund Request")
    test_api("I have a complaint", "Complaint")
    test_api("I need to talk to a manager", "Escalation")
    test_api("What is the weather?", "Unknown Intent")

    print("\n✅ All tests completed!")
```

**Run it:**

```bash
pip install requests
python test_api.py
```

---

## Response Status Codes

| Code | Status               | Meaning                                 |
| ---- | -------------------- | --------------------------------------- |
| 200  | OK                   | Request successful                      |
| 422  | Unprocessable Entity | Invalid request format (missing fields) |
| 500  | Server Error         | Backend or Ollama error                 |

---

## Debugging Tips

### Check if Ollama is Running:

```bash
curl http://localhost:11434/api/tags
```

Should return available models.

### Check if Backend is Running:

```bash
curl http://localhost:8000/
```

Should return health check message.

### View Backend Logs:

```bash
# Terminal running uvicorn shows requests
# Look for POST /chat in output
```

### Enable Request Logging:

Add to `app.py`:

```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

### Test Ollama Directly:

```bash
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen2.5:1.5b",
    "prompt": "Say hello",
    "stream": false
  }'
```

---

## Performance Testing

### Load Test with Apache Bench:

```bash
ab -n 100 -c 10 -p request.json -T application/json http://localhost:8000/chat
```

### Load Test with Locust:

**Save as `locustfile.py`:**

```python
from locust import HttpUser, task, between
import json

class ChatUser(HttpUser):
    wait_time = between(1, 3)

    @task
    def chat_hotel(self):
        self.client.post(
            "/chat",
            json={
                "session_id": "load-test",
                "message": "Show me hotels"
            }
        )

if __name__ == "__main__":
    # Run with: locust -f locustfile.py --host=http://localhost:8000
    pass
```

---

## Common Issues & Solutions

| Issue                | Solution                                         |
| -------------------- | ------------------------------------------------ |
| `Connection refused` | Ensure backend is running on port 8000           |
| `Empty response`     | Check Ollama is running and model is downloaded  |
| `Invalid JSON`       | Check message doesn't contain special characters |
| `Slow response`      | Qwen2.5 takes 10-30s first inference; normal     |
| `Model not found`    | Run `ollama pull qwen2.5:1.5b`                   |

---

## Integration with Your App

### Flutter Integration:

```dart
// In api_service.dart
Future<ChatResponse> sendMessage(String sessionId, String message) async {
  final response = await http.post(
    Uri.parse('$baseUrl/chat'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'session_id': sessionId,
      'message': message,
    }),
  );

  if (response.statusCode == 200) {
    return ChatResponse.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to send message');
  }
}
```

---

**Happy Testing! 🎉**
