<<<<<<< HEAD
# 🏥 PANOR API — FastAPI Backend Engine

Welcome to the backend engine of **PANOR (Patient-Augmented Network for Operational Reasoning)**. This directory contains the asynchronous, high-performance RESTful API powering the multi-agent clinical orchestration workspace. 

---

## 📂 Backend Directory Structure

```txt
backend/
├── app/
│   ├── main.py              # Application initialization & lifespan setup
│   ├── database.py          # Database session handling & schema initialization
│   ├── security.py          # JWT authentication, hashing, and password validation
│   ├── models/              # SQLite Database schemas (User, Patient, Consultation, etc.)
│   ├── routes/              # Modular controller endpoints (Auth, Doctor, Patient, etc.)
│   └── schemas/             # Pydantic DTO (Data Transfer Object) validators
├── seed_db.py               # Pre-seeded clinical records and diagnostic logs database seed
├── requirements.txt         # Core Python framework dependency definitions
└── Dockerfile               # Production container deployment configuration
```

---

## ⚡ Zero-to-Live Backend Quickstart Guide (Non-Tech & Tech)

Follow these simple, numbered steps to launch the backend API server on your computer.

### 1. Open Terminal or Command Prompt
Open a new terminal window on your machine and navigate to this backend directory:
```bash
cd d:\PANOR\PANOR-APP\backend
```

### 2. Set Up a Virtual Environment (Isolated sandbox)
Creating a virtual environment ensures that the project's dependencies do not clash with other programs on your system. Run the command matching your operating system:

*   **Windows (Command Prompt):**
    ```cmd
    python -m venv venv
    ```
*   **Windows (PowerShell):**
    ```powershell
    python -m venv venv
    ```
*   **Mac / Linux:**
    ```bash
    python3 -m venv venv
    ```

### 3. Activate the Virtual Environment
Activating the environment points your command line to the isolated sandbox. Run the command matching your setup:

*   **Windows (Command Prompt):**
    ```cmd
    .\venv\Scripts\activate.bat
    ```
*   **Windows (PowerShell):**
    ```powershell
    .\venv\Scripts\activate.ps1
    ```
*   **Mac / Linux:**
    ```bash
    source venv/bin/activate
    ```
*(You will see a parenthesis `(venv)` appear on the far left of your command prompt, indicating successful activation!)*

### 4. Install Dependencies
Install the required software packages using Python's package manager (`pip`):
```bash
pip install -r requirements.txt
```
*(This will automatically download and install FastAPI, Uvicorn, SQLAlchemy, database bridges, and encryption security libraries.)*

### 5. Seed the Local Database
Generate the database file and pre-populate it with mock doctors, patient profiles, and medical records:
```bash
python seed_db.py
```
> [!NOTE]
> Upon success, you will see `Database seeded with test users!` printed to your screen. A local SQLite file named `panor.db` will be created inside this folder.

### 6. Spin Up the Live Backend Server
Launch the asynchronous web server:
```bash
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```
> [!TIP]
> Setting `--host 0.0.0.0` is essential as it allows external physical devices (such as your smartphone) connected to your local Wi-Fi to establish communication lines with the backend API!

---

## 🔗 Interactive API Testing Room

Once the server is running, open your web browser and navigate to:
**[http://localhost:8000/docs](http://localhost:8000/docs)**

This opens the interactive **Swagger API Console**. From here, you can click on any endpoint, tap **"Try it out"**, input query parameters, and execute live API queries directly!

---

## 👮 Security & Authentication Workflow

The backend uses production-ready enterprise safety and privacy mechanisms:
1.  **Session Authorization**: Uses native `JOSE` cryptographic tokens to encrypt user state as JWTs (JSON Web Tokens).
2.  **Password Safety**: Implements `bcrypt` hash salting. Cleartext passwords are never stored in the database.
3.  **Cross-Origin Policy (CORS)**: Pre-routed to allow remote Flutter web clients to establish secure handshakes from any port.
=======
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
>>>>>>> afc318a (PANOR updates)
