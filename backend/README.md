# PANOR — Patient-Augmented Network for Operational Reasoning

> **Google Antigravity Agentic Clinical Intelligence Platform**

PANOR is a **production-grade multi-agent healthcare intelligence platform** powered by Google Antigravity orchestration. It runs **7 specialized clinical AI agents** to provide intake intelligence, differential diagnosis, drug-safety checking, lab coordination, epidemiology monitoring, follow-up scheduling, and SOAP note generation — all in a single consultation workflow.

---

## Architecture

```
┌──────────────┐     ┌──────────────────────────────────────────────┐
│  Flutter App  │────▶│  Nginx (:80) → FastAPI (:8000)              │
│  (Web/Mobile) │     │                                              │
└──────────────┘     │  ┌────────────────────────────────────────┐  │
                      │  │  7-Agent Antigravity Pipeline          │  │
                      │  │  Intake → Clinical → Drug Safety →    │  │
                      │  │  Lab Coord → Epi → Follow-Up → SOAP  │  │
                      │  └────────────────────────────────────────┘  │
                      │                                              │
                      │  PostgreSQL ←→ Redis ←→ Celery Workers      │
                      └──────────────────────────────────────────────┘
```

## Tech Stack

| Layer          | Technology                                  |
|----------------|---------------------------------------------|
| Frontend       | Flutter (Web + Mobile)                      |
| Backend        | FastAPI, Python 3.11+                       |
| Database       | PostgreSQL (prod) / SQLite (dev)            |
| ORM            | SQLAlchemy 2.x (async)                      |
| Auth           | JWT (access + refresh), bcrypt, RBAC        |
| AI             | Google Antigravity / Vertex AI / Gemini     |
| AI Fallback    | Clinical Rule Engine + Mock Emulator        |
| Task Queue     | Celery + Redis                              |
| Reverse Proxy  | Nginx                                       |
| Containerization| Docker Compose                             |
| Testing        | Pytest (12 tests)                           |

## Quick Start (Local Development)

```bash
# 1. Backend
cd backend
pip install -r requirements.txt
python seed_db.py                    # Create tables & seed data
python -m uvicorn app.main:app --reload --port 8000

# 2. Flutter
cd flutter_app
flutter pub get
flutter run -d chrome
```

**Default credentials:**
| Role          | Email              | Password |
|---------------|--------------------|----------|
| Patient       | patient@panor.com  | password |
| Doctor        | doctor@panor.com   | password |
| Administrator | admin@panor.com    | password |

## Docker Deployment

```bash
cd backend
docker compose up --build
```

This starts: `postgres`, `redis`, `api`, `celery_worker`, `celery_beat`, `nginx`

## API Endpoints (37 routes)

| Group            | Endpoints                                                    |
|------------------|--------------------------------------------------------------|
| **Auth**         | register, login, me, verify-otp, verify-pin                 |
| **Dashboard**    | patient/dashboard, doctor/dashboard, admin/dashboard         |
| **Appointments** | create, list (role-filtered)                                 |
| **Health Records**| log vitals, get vitals history, create lab reports          |
| **AI Assistant** | /consultation (7-agent pipeline), /chat (conversational)     |
| **Patients**     | profile, prescriptions, lab-reports, medications             |
| **Doctors**      | profile, patient list, patient detail, public doctor list    |
| **Admin**        | users, deactivate user, doctors, patients, audit-logs, analytics |
| **Notifications**| list, mark-read, mark-all-read                              |
| **Health**       | /, /health                                                   |

Full interactive docs: **http://localhost:8000/docs**

## 7-Agent Clinical Pipeline

| Agent | Name                      | Responsibility                              |
|-------|---------------------------|---------------------------------------------|
| 01    | Intake Intelligence       | Urdu/English symptom parsing & extraction   |
| 02    | Clinical Reasoning        | Differential diagnosis & risk scoring       |
| 03    | Drug Safety Guardian      | Contraindication detection (blocks NSAIDs for diabetics) |
| 04    | Lab Coordination          | STAT ECG/Troponin ordering                  |
| 05    | Epidemiology Intelligence | Outbreak cluster detection                  |
| 06    | Follow-Up Monitoring      | 48h compliance & deterioration triggers     |
| 07    | Verification & Safety     | Hallucination prevention & SOAP generation  |

## Environment Variables

Copy `.env.example` to `.env` and customize:

```
SECRET_KEY=your-secret-key
DATABASE_URL=sqlite+aiosqlite:///./panor.db
REDIS_URL=redis://localhost:6379/0
MOCK_AI=True
```

Set `MOCK_AI=False` + configure `GOOGLE_APPLICATION_CREDENTIALS` to use real Vertex AI.

## License

MIT
