# PANOR Project Setup Guide

## Quick Start (5 Minutes)

### Prerequisites
- **Backend**: Python 3.10+, PostgreSQL 14+, Firebase CLI
- **Mobile**: Flutter 3.10+, Android SDK, Xcode (for iOS build)
- **Tools**: Docker, Docker Compose, Git, VS Code

### One-Command Setup

```bash
# Clone repository
git clone https://github.com/PANOR-AI/PANOR-APP.git
cd PANOR-APP

# Run setup script
./scripts/setup.sh

# Verify installation
./scripts/verify.sh
```

---

## Detailed Setup

### 1. Backend Setup (FastAPI)

#### Step 1: Clone & Navigate
```bash
cd backend
```

#### Step 2: Python Environment
```bash
# Create virtual environment
python -m venv venv

# Activate
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip
```

#### Step 3: Install Dependencies
```bash
pip install -r requirements.txt
```

#### Step 4: Environment Configuration
```bash
# Copy template
cp .env.example .env

# Edit .env with your values
# nano .env
```

**Sample `.backend/.env`**:
```env
# PostgreSQL
DATABASE_URL=postgresql://panor_user:panor_password@localhost:5432/panor_db

# Firestore
GOOGLE_APPLICATION_CREDENTIALS=./firebase-key.json
FIRESTORE_PROJECT_ID=panor-production

# Gemini AI
GEMINI_API_KEY=your_gemini_api_key_here

# JWT
SECRET_KEY=your_secret_key_min_32_chars_long
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=120

# NADRA
NADRA_API_KEY=your_nadra_key
NADRA_API_URL=https://api.nadra.gov.pk/v1

# Environment
DEBUG=False
LOG_LEVEL=INFO
ENVIRONMENT=production
```

#### Step 5: Database Setup
```bash
# Create PostgreSQL database
createdb panor_db

# Run migrations
alembic upgrade head

# Seed initial data
python scripts/seed_db.py
```

#### Step 6: Firebase Setup
```bash
# Download Firebase service account key
# Place at: backend/firebase-key.json

# Initialize Firestore
firebase init firestore
firebase deploy --only firestore:rules
```

#### Step 7: Run Backend
```bash
# Development server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Production server
gunicorn app.main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker
```

**Verify**:
```bash
curl http://localhost:8000/health
# Response: {"status": "healthy", "version": "1.0.0"}
```

---

### 2. Mobile Setup (Flutter)

#### Step 1: Flutter & Dependencies
```bash
cd flutter_app

# Get Flutter packages
flutter pub get

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs
```

#### Step 2: Android Configuration
```bash
# Android Gradle wrapper
cd android
./gradlew clean
./gradlew dependencies
cd ..

# Update compileSdkVersion to 34
# File: android/app/build.gradle
```

**Sample `android/app/build.gradle` changes**:
```gradle
android {
    compileSdkVersion 34
    ndkVersion "25.1.8937393"
    
    defaultConfig {
        applicationId "com.panor.app"
        minSdkVersion 24  // Android 7.0
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

#### Step 3: Firebase Configuration
```bash
# Generate google-services.json
# Place at: android/app/google-services.json

# For iOS (optional)
# Place GoogleService-Info.plist at ios/Runner/
```

#### Step 4: Run Flutter App
```bash
# Connected device
flutter run

# Specific device
flutter run -d emulator-5554

# Release mode
flutter run --release
```

**Verify**:
- App launches with splash screen
- "PANOR Health" title visible
- Login screen accessible

---

### 3. Docker Compose Setup (Full Stack)

#### Single Command Deployment
```bash
# At project root
docker-compose up -d

# Verify services
docker-compose ps

# View logs
docker-compose logs -f backend
docker-compose logs -f postgres
docker-compose logs -f firebase
```

**`docker-compose.yml`**:
```yaml
version: '3.9'

services:
  # PostgreSQL Database
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: panor_user
      POSTGRES_PASSWORD: panor_password
      POSTGRES_DB: panor_db
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U panor_user -d panor_db"]
      interval: 10s
      timeout: 5s
      retries: 5

  # FastAPI Backend
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    environment:
      DATABASE_URL: postgresql://panor_user:panor_password@postgres:5432/panor_db
      GOOGLE_APPLICATION_CREDENTIALS: /app/firebase-key.json
      GEMINI_API_KEY: ${GEMINI_API_KEY}
      SECRET_KEY: ${SECRET_KEY}
    ports:
      - "8000:8000"
    depends_on:
      postgres:
        condition: service_healthy
    volumes:
      - ./backend:/app
      - ./firebase-key.json:/app/firebase-key.json
    command: uvicorn app.main:app --host 0.0.0.0 --port 8000

  # Redis (Caching)
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Nginx Reverse Proxy
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./certificates:/etc/nginx/certificates
    depends_on:
      - backend
    command: nginx -g 'daemon off;'

volumes:
  postgres_data:
```

---

## Environment Variables Setup

### Backend Environment (`backend/.env`)

```env
# ====== DATABASE ======
DATABASE_URL=postgresql://panor_user:panor_password@localhost:5432/panor_db
DATABASE_POOL_SIZE=20
DATABASE_POOL_RECYCLE=3600

# ====== FIREBASE ======
GOOGLE_APPLICATION_CREDENTIALS=./firebase-key.json
FIRESTORE_PROJECT_ID=panor-production
FIRESTORE_COLLECTION_PREFIX=prod_

# ====== GEMINI AI ======
GEMINI_API_KEY=AIzaSy...  # Get from Google AI Studio
GEMINI_MODEL=gemini-pro
GEMINI_TIMEOUT_SECONDS=30

# ====== JWT ======
SECRET_KEY=your_super_secret_key_min_32_characters_long
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=120
REFRESH_TOKEN_EXPIRE_DAYS=7

# ====== NADRA ======
NADRA_API_KEY=your_nadra_key
NADRA_API_URL=https://api.nadra.gov.pk/v1
NADRA_TIMEOUT=10

# ====== APPLICATION ======
DEBUG=False
LOG_LEVEL=INFO
ENVIRONMENT=production
CORS_ORIGINS=["https://panor.app", "http://localhost:8000"]
API_TITLE=PANOR Clinical Intelligence
API_VERSION=1.0.0

# ====== SMTP (Notifications) ======
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your_email@gmail.com
SMTP_PASSWORD=your_app_password
SMTP_FROM=noreply@panor.app

# ====== TWILIO (SMS OTP) ======
TWILIO_ACCOUNT_SID=your_account_sid
TWILIO_AUTH_TOKEN=your_auth_token
TWILIO_PHONE_NUMBER=+1234567890

# ====== SECURITY ======
ENCRYPTION_SALT=your_fixed_salt_32_characters
ENCRYPTION_KEY=your_encryption_master_key
SSL_CERT_PATH=./certificates/server.crt
SSL_KEY_PATH=./certificates/server.key

# ====== MONITORING ======
SENTRY_DSN=https://your-sentry-dsn
DATADOG_API_KEY=your_datadog_key
```

### Flutter Environment (`flutter_app/.env`)

```env
# ====== API ======
API_BASE_URL=https://api.panor.app/api/v1
API_TIMEOUT_SECONDS=30

# ====== FIREBASE ======
FIREBASE_PROJECT_ID=panor-production
FIREBASE_API_KEY=your_firebase_api_key

# ====== FEATURES ======
ENABLE_OFFLINE_MODE=true
ENABLE_VOICE_INPUT=true
ENABLE_OCR=true
ENABLE_AI_CHAT=true

# ====== LOGGING ======
LOG_LEVEL=info
ENABLE_CRASH_REPORTING=true
```

---

## Verification Checklist

### Backend
- [ ] `python app/main.py` runs without errors
- [ ] Health endpoint returns 200: `curl http://localhost:8000/health`
- [ ] Database migrations applied: `alembic current`
- [ ] Firestore collections visible in Firebase Console
- [ ] Gemini API responding: Test with `python -c "import google.generativeai; ..."`

### Flutter
- [ ] `flutter pub get` completes without errors
- [ ] Android/iOS SDK paths configured: `flutter doctor`
- [ ] App runs on emulator: `flutter run`
- [ ] API connection test passes (Settings → Developer → Test API)
- [ ] Local cache initializes: Hive boxes created

### Docker
- [ ] All services health: `docker-compose ps` (all show "Up")
- [ ] PostgreSQL accessible: `psql -h localhost -U panor_user -d panor_db -c "SELECT 1"`
- [ ] Redis pings: `redis-cli ping`
- [ ] Backend API responds: `curl http://localhost:8000/health`

---

## Development Workflow

### Daily Development Startup
```bash
# Terminal 1: Database & Services
docker-compose up -d postgres redis
sleep 5

# Terminal 2: Backend API
cd backend
source venv/bin/activate
uvicorn app.main:app --reload

# Terminal 3: Flutter App
cd flutter_app
flutter run -d emulator-5554
```

### Making Changes

#### Backend Changes
```bash
# 1. Edit code
# 2. Uvicorn auto-reloads (--reload flag)
# 3. Test API: curl http://localhost:8000/api/v1/...
```

#### Flutter Changes
```bash
# 1. Edit widget code
# 2. Hot reload: Press 'r' in terminal
# 3. Hot restart: Press 'R' in terminal (full rebuild)
```

#### Database Schema Changes
```bash
# 1. Edit SQLAlchemy models (backend/app/models/)
# 2. Create migration:
alembic revision --autogenerate -m "Add new_table"

# 3. Review migration file
# 4. Apply:
alembic upgrade head
```

---

## Troubleshooting

### Backend Issues

**Issue**: `ModuleNotFoundError: No module named 'app'`
```bash
# Solution: Ensure you're running from backend directory
cd backend
python -m uvicorn app.main:app --reload
```

**Issue**: `psycopg2.OperationalError: connection failed`
```bash
# Solution: Verify PostgreSQL is running and credentials are correct
psql -h localhost -U panor_user -d panor_db -c "SELECT 1"
# If fails, check DATABASE_URL in .env
```

**Issue**: `Firebase credentials not found`
```bash
# Solution: Ensure google-services.json is in backend/ directory
ls -la backend/firebase-key.json
# If missing, download from Firebase Console
```

### Flutter Issues

**Issue**: `Android SDK not found`
```bash
flutter config --android-sdk-path /path/to/android-sdk
flutter doctor --android-licenses
```

**Issue**: `App crashes on startup`
```bash
# Check logs
flutter run -v

# Clear app cache
flutter clean
flutter pub get
```

---

## Production Deployment

### Backend Deployment (Google Cloud Run)

```bash
# Build Docker image
docker build -t gcr.io/panor-production/backend:1.0.0 ./backend

# Push to Cloud Registry
docker push gcr.io/panor-production/backend:1.0.0

# Deploy to Cloud Run
gcloud run deploy panor-backend \
  --image gcr.io/panor-production/backend:1.0.0 \
  --platform managed \
  --region us-central1 \
  --set-env-vars DATABASE_URL=postgresql://... \
  --memory 1Gi \
  --cpu 2 \
  --allow-unauthenticated
```

### Flutter APK Build

```bash
# Build APK (optimized for low-end devices)
flutter build apk --release --obfuscate --split-per-abi

# Output location
# build/app/outputs/apk/release/app-arm64-v8a-release.apk
# build/app/outputs/apk/release/app-armeabi-v7a-release.apk
```

---

## Support & Documentation

- **API Documentation**: http://localhost:8000/docs (Swagger)
- **ReDoc**: http://localhost:8000/redoc
- **Database Schema**: [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md)
- **Architecture**: [PANOR_IMPLEMENTATION_SPEC.md](PANOR_IMPLEMENTATION_SPEC.md)
- **Security**: [SECURITY_FRAMEWORK.md](SECURITY_FRAMEWORK.md)

---

**Status**: Setup guide complete  
**Estimated Setup Time**: 20-30 minutes  
**Support Channel**: GitHub Issues
