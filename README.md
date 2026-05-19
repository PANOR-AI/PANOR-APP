# PANOR — Patient-Augmented Network for Operational Reasoning
### *Agentic Clinical Intelligence Platform Powered by Google Antigravity*
---
**Submission Platform:** Google AI Seekho Hackathon 2026  
**Platform Focus:** Multilingual, Multimodal, Agentic Clinical Intelligence System  
**Core Technologies:** Google Antigravity, Vertex AI, Gemini, FastAPI, Flutter

---

## 🌟 Executive Summary (For Everyone)

**What is PANOR?**
Imagine entering a hospital where the system already knows your entire medical history across every clinic you've ever visited, understands your symptoms in any language you speak (Urdu, Punjabi, English), immediately warns the doctor if you are having a hidden emergency (like an impending cardiac event), alerts the pharmacist if your new prescription might clash with your old pills, and drafts the doctor’s post-consultation paperwork in under 3 seconds. 

That is **PANOR** (Patient-Augmented Network for Operational Reasoning).

In high-volume clinics where doctors only have 3 to 4 minutes per patient, it is impossible for a human to manually cross-reference historical reports, check for drug interactions, and write exhaustive clinical summaries. PANOR solves this by deploying **Seven Specialized AI Agents** coordinated by **Google Antigravity** to act as a 24/7 clinical co-pilot.

---

## 🛠️ The Core Problems We Solve

| Failure Mode | The Real-World Impact | How PANOR Fixes It |
| :--- | :--- | :--- |
| **Cross-Prescriber Blindness** | Doctors cannot see prescriptions from other clinics. Duplicate or conflicting drugs are prescribed, risking patient health. | **Drug Safety Agent (Agent 03)** automatically compares new prescriptions against all prior meds and hard-blocks conflicts. |
| **Context Collapse at Labs** | Labs receive test requests without clinical reasoning, delaying critical tests. | **Lab Coordination Agent (Agent 04)** attaches clinical intent and STAT/Urgent/Routine priority labels to every order. |
| **Consultation Time Squeeze** | Doctors process 60-100 patients daily. There is no time to type clinical SOAP notes. | **Verification Agent (Agent 07)** auto-generates structured clinical SOAP notes in under 3 seconds. |
| **Delayed Epidemiology Detection** | Disease clusters (like dengue or typhoid) are only noticed after hospitals are already overwhelmed. | **Epidemiology Agent (Agent 05)** aggregates anonymized symptoms to forecast outbreaks 48-72 hours in advance. |

---

## 🤖 The Seven AI Agents (Google Antigravity Orchestrated)

PANOR does not use a single "chatbot". Instead, it orchestrates **7 dedicated digital specialists**:

1. **Intake Intelligence Agent (Agent 01):** Translates patient inputs (voice recordings, prescription photos, PDF reports, or typed text in Roman Urdu/English) into a clean, standardized clinical summary.
2. **Clinical Reasoning Agent (Agent 02):** Analyzes symptoms against patient history, generates ranked diagnoses, and runs a silent emergency screening to trigger RED alerts for cardiac or respiratory crises.
3. **Drug Safety Guardian (Agent 03):** Runs a security check on every proposed medication against active prescriptions and chronic conditions. It blocks dangerous mixes and suggests safe alternatives.
4. **Laboratory Coordination Agent (Agent 04):** Translates diagnosis reasoning into clear lab orders with clinical reasoning and urgency labels (STAT, Urgent, Routine).
5. **Epidemiology Intelligence Agent (Agent 05):** Runs regional outbreak forecasting using anonymized spatial-temporal clustering.
6. **Follow-Up Monitoring Agent (Agent 06):** Schedules automated 48-hour recovery check-ins, tracks medication compliance, and alerts doctors if a patient deteriorates.
7. **Verification & Safety Agent (Agent 07):** Evaluates overall confidence thresholds, handles contradiction analysis, and generates the final clinical **SOAP Draft** (Subjective, Objective, Assessment, Plan) for the physician.

---

## 💻 Tech Stack (The Engine Rooms)

### Frontend (User Interface)
- **Framework:** Flutter (Cross-platform Web/Mobile)
- **Typography:** Google Fonts (Inter)
- **State Management & Network:** HTTP Services with JWT Bearer Token caching via Shared Preferences.

### Backend (Core Processing)
- **Framework:** FastAPI (Python 3.11+) - high-performance asynchronous runtime.
- **Database:** SQLite (local development with `aiosqlite`) & PostgreSQL (production-ready).
- **Security:** Raw `bcrypt` password encryption & JWT (JSON Web Tokens) Session Management.
- **Orchestration Layer:** Google Antigravity trace schemas + Vertex AI (Gemini Pro models).

---

## 🚀 Easy Step-by-Step Setup Guide (For Non-Tech & Tech Alike)

Follow these simple steps to get both the **Backend Engine** and the **Frontend Web Portal** running on your local machine.

### Prerequisites
Make sure you have [Python](https://www.python.org/downloads/) (version 3.10 or higher) and [Flutter](https://docs.flutter.dev/get-started/install) installed on your machine.

---

### Step 1: Boot Up the Backend API

1. Open your terminal/command prompt and navigate to the project directory:
   ```bash
   cd d:\PANOR\PANOR-APP\backend
   ```
2. Create a virtual environment (this keeps the project dependencies isolated and clean):
   ```bash
   python -m venv venv
   ```
3. Activate the virtual environment:
   - **Windows (Command Prompt):**
     ```cmd
     .\venv\Scripts\activate.bat
     ```
   - **Windows (PowerShell):**
     ```powershell
     .\venv\Scripts\activate.ps1
     ```
   - **Mac/Linux:**
     ```bash
     source venv/bin/activate
     ```
4. Install all required dependencies with one command:
   ```bash
   pip install fastapi uvicorn sqlalchemy aiosqlite python-jose[cryptography] bcrypt pydantic email-validator python-multipart
   ```
5. Seed the database with the pre-configured mock users (Patient, Doctor, Admin):
   ```bash
   python seed_db.py
   ```
   *You should see the message: `Database seeded with test users!`*
6. Start the local server:
   ```bash
   python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
   ```
   *Your backend is now live at `http://localhost:8000`! You can visit `http://localhost:8000/docs` to see the live interactive API room.*

---

### Step 2: Boot Up the Frontend Web Portal

Open a **new, separate terminal window** and run these commands:

1. Navigate to the frontend directory:
   ```bash
   cd d:\PANOR\PANOR-APP\flutter_app
   ```
2. Build the optimized web application:
   ```bash
   flutter build web
   ```
3. Spin up a simple local server to display the build:
   ```bash
   python -m http.server 8081 --directory build/web
   ```
4. Open your favorite web browser and go to:
   **[http://localhost:8081](http://localhost:8081)**

---

## 🧑‍⚕️ How to Use & Test (Interactive Demo Scenarios)

Once you open the portal, the **Splash Screen** will load and transition to the **Role Selection** screen. Try logging in with the pre-seeded accounts:

### 1. Test as a Doctor (Dr. Amit Verma)
- **Role to Select:** Doctor
- **Email:** `doctor@panor.com`
- **Password:** `password`
- **What to Observe:** The app connects directly to the FastAPI server, validates your login, returns a JWT token, and dynamically loads the **Doctor Dashboard**. You will see:
  - Total active patients (12) and today's appointments (5).
  - An interactive appointment list displaying live database records (Rahul Sharma at 10:00 AM, Priya Patel at 11:15 AM).

### 2. Test as a Patient (Rahul Sharma)
- **Role to Select:** Patient
- **Email:** `patient@panor.com`
- **Password:** `password`
- **What to Observe:** The system authenticates and loads the **Patient Health Portal**. You will view your recorded vitals (Blood Pressure: `120/80`, Heart Rate: `72 bpm`) and upcoming clinical appointments fetched in real-time from the backend.

### 3. Test as an Administrator
- **Role to Select:** Administrator
- **Email:** `admin@panor.com`
- **Password:** `password`
- **What to Observe:** Displays the **Operational Control Center**. You will see live statistics of total users, patient/doctor ratios, and a feed of recent activities occurring within the network.

---

## 🛡️ Clinical Safety Policies (Our Human-In-The-Loop Promise)
To ensure highest standards of medical safety, PANOR integrates strict compliance safeguards:
- **Emergency Hard Stops:** If a patient submits high-risk terms (chest pain, dyspnea), the system halts automated operations and triggers an orange/red visual banner, prompting human triage.
- **Drug-Safety Hard-Block:** Standard blocks (e.g. clashing medications) cannot be bypassed unless a physician explicitly reviews and logs a clinical override.
- **Draft SOAP Notes:** All SOAP note entries are editable drafts, requiring a physician's digital signature before committing to the append-only permanent timeline.
