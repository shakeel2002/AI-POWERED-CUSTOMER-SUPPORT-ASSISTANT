# Deployment Guide - Production Setup

## Quick Deployment Checklist

- [ ] Backend deployed to cloud platform
- [ ] Ollama running on GPU instance or using managed inference API
- [ ] Database configured (PostgreSQL/MongoDB)
- [ ] Redis cache set up
- [ ] Environment variables configured
- [ ] HTTPS/TLS enabled
- [ ] Rate limiting implemented
- [ ] Authentication added
- [ ] Monitoring and logging enabled
- [ ] Flutter app built for app stores

---

## Backend Deployment Options

### 1. **Render.com** (Recommended - Free Tier Available)

**Step 1: Create Account**

- Go to https://render.com
- Sign up with GitHub

**Step 2: Prepare Backend**

- Push code to GitHub repository
- Ensure `requirements.txt` exists in `/backend`
- Create `render.yaml`:

```yaml
services:
  - type: web
    name: ai-customer-support-backend
    env: python
    plan: free
    buildCommand: pip install -r requirements.txt
    startCommand: uvicorn app:app --host 0.0.0.0 --port $PORT
    envVars:
      - key: OLLAMA_URL
        value: https://your-ollama-service.com/api/generate
      - key: DATABASE_URL
        value: postgresql://...
```

**Step 3: Deploy**

- Click "New +" → "Web Service"
- Select your GitHub repo
- Render automatically deploys on push

**Step 4: Get Backend URL**

- Render provides: `https://ai-customer-support-backend.onrender.com`

### 2. **Railway.app** (Alternative)

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Deploy
railway up
```

### 3. **AWS Lambda + API Gateway**

**Using Zappa:**

```bash
# Install
pip install zappa

# Init
zappa init

# Deploy
zappa deploy production

# Update
zappa update production
```

**`zappa_settings.json`:**

```json
{
  "production": {
    "app_function": "app.app",
    "aws_region": "us-east-1",
    "runtime": "python3.11",
    "s3_bucket": "zappa-deployments-bucket"
  }
}
```

### 4. **Docker Deployment**

**Create `Dockerfile` in `/backend`:**

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Create `docker-compose.yml`:**

```yaml
version: "3.8"

services:
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - OLLAMA_URL=http://ollama:11434/api/generate
      - DATABASE_URL=postgresql://user:pass@db:5432/app
    depends_on:
      - ollama
      - db
      - redis

  ollama:
    image: ollama/ollama:latest
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
    # GPU support (uncomment for NVIDIA GPU)
    # runtime: nvidia
    # deploy:
    #   resources:
    #     reservations:
    #       devices:
    #         - driver: nvidia
    #           count: 1
    #           capabilities: [gpu]

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_PASSWORD=secure_password
      - POSTGRES_DB=ai_support
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  ollama_data:
  postgres_data:
  redis_data:
```

**Deploy:**

```bash
docker-compose up -d
```

---

## Ollama Deployment

### Option 1: Self-Hosted GPU Server

**AWS EC2 (p3.2xlarge with NVIDIA GPU):**

```bash
#!/bin/bash

# Install NVIDIA drivers
sudo apt-get update
sudo apt-get install -y nvidia-driver-525

# Install Ollama
curl https://ollama.ai/install.sh | sh

# Pull model
ollama pull qwen2.5:1.5b

# Start service (systemd)
systemctl start ollama
systemctl enable ollama

# Open port 11434
sudo ufw allow 11434
```

### Option 2: Managed Inference APIs

**Using Replicate:**

```python
import replicate

def classify_intent(message):
    output = replicate.run(
        "zsxkzsx/mistral-7b-instruct-v0.1",
        input={"prompt": message}
    )
    return output
```

**Using HuggingFace Inference API:**

```python
from huggingface_hub import InferenceClient

client = InferenceClient(api_key="hf_...")

def classify_intent(message):
    response = client.text_generation(message)
    return response
```

**Using Together AI:**

```python
import together

def classify_intent(message):
    output = together.Complete.create(
        prompt=message,
        model="togethercomputer/Mistral-7B-Instruct-v0.2"
    )
    return output
```

---

## Database Setup

### PostgreSQL (Recommended)

**Local:**

```bash
# macOS
brew install postgresql
brew services start postgresql

# Linux
sudo apt-get install postgresql postgresql-contrib
sudo systemctl start postgresql

# Create database
createdb ai_customer_support
```

**In Python:**

```python
from sqlalchemy import create_engine

engine = create_engine('postgresql://user:password@localhost/ai_customer_support')
```

### MongoDB

**Atlas Cloud:**

- Go to https://mongodb.com/cloud/atlas
- Create cluster
- Get connection string
- Set environment variable

```python
from pymongo import MongoClient

client = MongoClient(os.getenv('MONGODB_URI'))
db = client['ai_customer_support']
conversations = db['conversations']
```

---

## Redis Setup

**Local:**

```bash
# macOS
brew install redis
brew services start redis

# Linux
sudo apt-get install redis-server
sudo systemctl start redis-server
```

**Cloud (Redis Cloud):**

```python
import redis

redis_client = redis.Redis(
    host=os.getenv('REDIS_HOST'),
    port=os.getenv('REDIS_PORT'),
    password=os.getenv('REDIS_PASSWORD'),
    decode_responses=True
)
```

---

## Environment Variables

Create `.env` file:

```env
# Ollama
OLLAMA_URL=http://localhost:11434/api/generate

# Database
DATABASE_URL=postgresql://user:password@localhost/ai_customer_support

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# FastAPI
DEBUG=False
SECRET_KEY=your-secret-key-here

# CORS
ALLOWED_ORIGINS=https://yourdomain.com,https://app.yourdomain.com

# APIs (if using external services)
BOOKING_API_KEY=xxx
STRIPE_API_KEY=xxx
```

**Load in Python:**

```python
from dotenv import load_dotenv
import os

load_dotenv()

OLLAMA_URL = os.getenv('OLLAMA_URL')
DATABASE_URL = os.getenv('DATABASE_URL')
```

---

## Updated Backend Code for Production

**`backend/app.py` (Production Ready):**

```python
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import os
from dotenv import load_dotenv
import redis
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

load_dotenv()

# Initialize database
DATABASE_URL = os.getenv('DATABASE_URL')
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Initialize Redis
redis_client = redis.Redis(
    host=os.getenv('REDIS_HOST', 'localhost'),
    port=int(os.getenv('REDIS_PORT', 6379)),
    password=os.getenv('REDIS_PASSWORD'),
    decode_responses=True
)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print("✅ Application started")
    yield
    # Shutdown
    redis_client.close()
    print("❌ Application shutdown")

app = FastAPI(
    title="AI Customer Support Assistant",
    version="1.0.0",
    lifespan=lifespan
)

# CORS Configuration
allowed_origins = os.getenv('ALLOWED_ORIGINS', 'http://localhost:3000').split(',')
app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Import routes
from routes.chat import router as chat_router

app.include_router(chat_router, prefix="/api", tags=["chat"])

@app.get("/")
def root():
    return {"message": "AI Customer Support Backend - Production Ready"}

@app.get("/health")
def health():
    return {
        "status": "healthy",
        "version": "1.0.0"
    }
```

---

## Authentication (JWT)

**Install:**

```bash
pip install python-jose passlib bcrypt
```

**Implementation:**

```python
from fastapi import Depends, HTTPException, status
from jose import JWTError, jwt
from datetime import datetime, timedelta

SECRET_KEY = os.getenv('SECRET_KEY')
ALGORITHM = "HS256"

def create_access_token(data: dict, expires_delta: timedelta = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(hours=24)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def verify_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        session_id: str = payload.get("sub")
        if session_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        return session_id
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
```

---

## Rate Limiting

**Install:**

```bash
pip install slowapi
```

**Implementation:**

```python
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter

@app.post("/chat")
@limiter.limit("10/minute")
async def chat(request: Request, body: ChatRequest):
    # Your code here
    pass
```

---

## Monitoring & Logging

**Using Prometheus + Grafana:**

```python
from prometheus_client import Counter, Histogram
import time

request_count = Counter('requests_total', 'Total requests', ['method', 'endpoint'])
request_duration = Histogram('request_duration_seconds', 'Request duration')

@app.middleware("http")
async def add_metrics(request: Request, call_next):
    start = time.time()
    response = await call_next(request)
    duration = time.time() - start

    request_count.labels(method=request.method, endpoint=request.url.path).inc()
    request_duration.observe(duration)

    return response
```

**Using DataDog:**

```python
from ddtrace import patch_all

patch_all()
```

---

## Flutter App Deployment

### Android

**Build APK:**

```bash
flutter build apk --release
```

**Upload to Play Store:**

1. Generate keystore
2. Create Play Console account
3. Upload APK
4. Set environment to `http://your-backend.com`

### iOS

**Build IPA:**

```bash
flutter build ios --release
```

**Upload to App Store:**

1. Create App Store Connect account
2. Use Xcode to upload
3. Set environment to `http://your-backend.com`

### Web

**Build Web:**

```bash
flutter build web --release
```

**Deploy to Firebase:**

```bash
npm install -g firebase-tools
firebase login
firebase init hosting
firebase deploy
```

---

## Scaling Strategy

### Load Balancing

- Use AWS ELB / Nginx / HAProxy
- Deploy 3+ backend instances
- Distribute across availability zones

### Caching

- Redis for session storage
- CloudFlare for CDN caching
- Browser caching for static assets

### Database

- Read replicas for scaling reads
- Connection pooling (PgBouncer)
- Regular backups (automated)

### Monitoring

- Use DataDog, New Relic, or Prometheus
- Alert on error rates, latency, CPU
- Track model inference time

---

## Disaster Recovery

**Backup Strategy:**

```bash
# Daily database backups
0 2 * * * pg_dump $DATABASE_URL > backups/db-$(date +\%Y\%m\%d).sql

# Store in S3
aws s3 cp backups/ s3://backup-bucket/ --recursive
```

**High Availability:**

- Multi-region deployment
- Database replication
- Automatic failover

---

## Security Checklist

- ✅ HTTPS/TLS enabled
- ✅ JWT authentication
- ✅ Rate limiting
- ✅ Input validation
- ✅ SQL injection prevention (ORM)
- ✅ CORS properly configured
- ✅ Secrets in environment variables
- ✅ Regular security updates
- ✅ DDoS protection (CloudFlare)
- ✅ Data encryption at rest

---

## Cost Estimation

| Service          | Cost             | Notes               |
| ---------------- | ---------------- | ------------------- |
| Render Backend   | Free-$12/mo      | Free tier available |
| PostgreSQL       | $15-50/mo        | Cloud hosted        |
| Redis            | $15-50/mo        | Managed service     |
| Ollama GPU (AWS) | $100-500/mo      | EC2 p3 instance     |
| Firebase Hosting | Free-$25/mo      | Flutter web app     |
| CDN (Cloudflare) | Free-$20/mo      | DDoS + caching      |
| **Total**        | **~$200-700/mo** | Production setup    |

---

## Support & Troubleshooting

### Common Deployment Issues

| Issue                     | Solution                                  |
| ------------------------- | ----------------------------------------- |
| Backend won't start       | Check environment variables in logs       |
| Model not loading         | Verify OLLAMA_URL is accessible           |
| Database connection error | Check DATABASE_URL and network access     |
| 502 Bad Gateway           | Restart backend service                   |
| High latency              | Check GPU utilization, scale horizontally |

---

**Happy Deploying! 🚀**
